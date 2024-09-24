import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_1/screen/course/registration.dart';

import 'course_detail.dart'; // Assuming this is the correct path

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allCourses = [];
  List<Map<String, dynamic>> _filteredCourses = [];
  bool isLoading = true;
  String? requestStatus;
  String appliedCourseName = '';
  String _courseID = '';
  bool hasApplied = false;

  @override
  void initState() {
    super.initState();
    _checkStudentRequestStatus();
    _fetchCourses();
    _searchController.addListener(_filterCourses);
  }

  Future<void> _checkStudentRequestStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final requestSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(user.uid)
          .get();

      if (requestSnapshot.exists) {
        setState(() {
          requestStatus = requestSnapshot['status'];
          appliedCourseName = requestSnapshot['courseName'];
          _courseID = requestSnapshot['courseId'];
        });
      }
    }
  }

  void _fetchCourses() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('courses').get();
    setState(() {
      _allCourses = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'title': doc['name'],
                'description': doc['description'],
                'price': doc['price'],
              })
          .toList();
      _filteredCourses = _allCourses;
    });
    setState(() {
      isLoading = false;
    });
  }

  void _filterCourses() {
    setState(() {
      _filteredCourses = _allCourses
          .where((course) =>
              course['title']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              course['description']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Courses')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (requestStatus == 'pending') {
      return Scaffold(
        appBar: AppBar(title: const Text('Courses')),
        body: Center(
          child: Text(
            'You have already applied for the course "$appliedCourseName". Please wait for the request to be processed.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      );
    }

    if (requestStatus == 'approved') {
      return CourseFileDisplayScreen(
          selectedCourseId: _courseID, selectedCourseName: appliedCourseName);
    }

    if (!hasApplied || requestStatus == 'denied') {
      return Scaffold(
        appBar: AppBar(title: const Text('Courses')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = _filteredCourses[index];
                    return ListTile(
                      title:
                          Text(course['title'], style: GoogleFonts.poppins()),
                      subtitle: Text(course['description'],
                          style: GoogleFonts.poppins()),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(
                              courseId: course['id'],
                              title: course['title'],
                              description: course['description'],
                              price: course['price'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default case, should not be reached
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: const Center(child: Text('Something went wrong')),
    );
  }
}
