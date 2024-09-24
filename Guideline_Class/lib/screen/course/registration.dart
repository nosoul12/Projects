import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:student_1/const/colors.dart';

class CourseFileDisplayScreen extends StatefulWidget {
  final String selectedCourseId;
  final String selectedCourseName;

  const CourseFileDisplayScreen({
    super.key,
    required this.selectedCourseId,
    required this.selectedCourseName,
  });

  @override
  _CourseFileDisplayScreenState createState() =>
      _CourseFileDisplayScreenState();
}

class _CourseFileDisplayScreenState extends State<CourseFileDisplayScreen> {
  String? _selectedCourseId;
  String? _selectedCourseName;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  Map<String, List<Map<String, dynamic>>> resources = {
    'videos': [],
    'pdf': [],
    'questions': []
  };
  Map<String, double> downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.selectedCourseId;
    _selectedCourseName = widget.selectedCourseName;
    _loadResources();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await _getPermission();
    setState(() {
      _permissionStatus = status;
    });
  }

  Future<PermissionStatus> _getPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return PermissionStatus.granted;
      } else {
        return Permission.manageExternalStorage.status;
      }
    } else if (Platform.isIOS) {
      return Permission.photos.status;
    }
    return PermissionStatus.denied;
  }

  Future<void> _requestPermission() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.manageExternalStorage.request();
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = PermissionStatus.denied;
    }

    setState(() {
      _permissionStatus = status;
    });

    _showPermissionStatus(status);
  }

  void _showPermissionStatus(PermissionStatus status) {
    String message;
    if (status.isGranted) {
      message = 'Permission granted';
    } else if (status.isDenied) {
      message = 'Permission denied';
    } else if (status.isPermanentlyDenied) {
      message =
          'Permission permanently denied. Please enable it from settings.';
    } else {
      message = 'Permission status: $status';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadResources() async {
    if (_selectedCourseId == null) return;

    try {
      QuerySnapshot videosSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourseId)
          .collection('videos')
          .get();

      QuerySnapshot pdfSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourseId)
          .collection('pdf')
          .get();

      QuerySnapshot questionsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourseId)
          .collection('questions')
          .get();

      if (mounted) {
        setState(() {
          resources['videos'] = videosSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          resources['pdf'] = pdfSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          resources['questions'] = questionsSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      print('Error loading resources: $e');
    }
  }

  Future<void> _downloadAndOpenFile(String url, String fileName) async {
    try {
      if (_permissionStatus.isDenied) _requestPermission();
      if (_permissionStatus.isGranted) {
        Dio dio = Dio();
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/$fileName';

        setState(() {
          downloadProgress[fileName] = 0;
        });

        await dio.download(url, filePath, onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress[fileName] = received / total;
            });
          }
        });
        final file = File(filePath);
        if (await File(filePath).exists()) {
          OpenFile.open(filePath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File does not exist at $filePath')),
          );
        }
        setState(() {
          downloadProgress.remove(fileName);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Error downloading or opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading or opening file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Course Material',
        onNotificationTap: () {
          // Handle notification tap
          print("Notification tapped");
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Resources:',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildResourceSection(
                'Videos',
                AppColors.primaryColor,
                resources['videos'] ?? [],
              ),
              const SizedBox(height: 10),
              _buildResourceSection(
                'PDFs',
                AppColors.accentColor,
                resources['pdf'] ?? [],
              ),
              const SizedBox(height: 10),
              _buildResourceSection(
                'Questions',
                Colors.red,
                resources['questions'] ?? [],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceSection(
      String title, Color color, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'No $title available',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                )
              : AnimationLimiter(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final itemName = item['name'] ?? 'Unknown';
                      final itemUrl = item['url'] ?? '';

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Card(
                              color: color,
                              child: InkWell(
                                onTap: () async {
                                  // Call the function to download and open the file
                                  await _downloadAndOpenFile(itemUrl, itemName);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 200,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Text(
                                            itemName,
                                            style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        if (downloadProgress
                                            .containsKey(itemName))
                                          Positioned(
                                            bottom: 8,
                                            left: 8,
                                            right: 8,
                                            child: LinearProgressIndicator(
                                              value: downloadProgress[itemName],
                                              backgroundColor:
                                                  Colors.white.withOpacity(0.5),
                                              valueColor:
                                                  const AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onNotificationTap;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: onNotificationTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
