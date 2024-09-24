import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:student_1/module/student.dart';
import 'package:student_1/screen/route.dart';
import 'package:student_1/widgets/media_picker.dart';

class DetailInputScreen extends StatefulWidget {
  const DetailInputScreen({super.key});

  @override
  _DetailInputScreenState createState() => _DetailInputScreenState();
}

class _DetailInputScreenState extends State<DetailInputScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _student = Student(
    fullName: '',
    guardianName: '',
    studentClass: '',
    subject: '',
    board: '',
    coachingCenter: '',
    joiningDate: DateTime.now(),
    phoneNumber: '',
    parentsNumber: '',
    feePaid: 0.0,
    feeDue: 0.0,
    totalFees: 0.0,
    scholarship: 0.0,
  );
  String? _selectedClass;
  String? _selectedCourse;
  String? _selectedCoachingCenter;
  String? _selectedBoard;
  File? _pickedImage;

  final List<String> _classes = [
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12'
  ];
  final List<String> _courses = ['PCM', 'PCB', 'JEE MAIN', 'NEET', 'COMMERCE'];
  final List<String> _coachingCenters = ['Karond', 'Shardanagar', 'Etkedi'];
  final List<String> _boards = [
    'CBSE',
    'ICSE',
  ];

  void _pickImage(File pickedImage) {
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _pickedImage != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Store the image in Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user.uid}.jpg');
        await ref.putFile(_pickedImage!);
        final url = await ref.getDownloadURL();

        // Add student data along with image URL to Firestore
        final studentData = _student.toMap();
        studentData['image_url'] = url;
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .set(studentData);

        // Store the image URL in the new collection
        await FirebaseFirestore.instance
            .collection('user_images')
            .doc(user.uid)
            .set({'image_url': url});

        // Create an initial fee record
        final feeRecord = {
          'description':
              '${_student.fullName} joined on ${_student.joiningDate}',
          'amount': 0.0,
          'date': _student.joiningDate.toIso8601String(),
          'feeDue': _student.feeDue,
        };

        // Add the fee record to the FeeRecords sub-collection
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .collection('FeeRecords')
            .add(feeRecord);

        // Update the profileCompleted flag
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .update({'profileCompleted': true});

        Navigator.of(context).pop(); // Dismiss the progress indicator
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a profile image.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tell Us About You',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 10, 14),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/finalbg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            UserImagePicker(onpickimage: _pickImage),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedClass,
                                hint: Text(
                                  'Select Class',
                                  style: GoogleFonts.poppins(),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedClass = newValue;
                                  });
                                },
                                items: _classes.map((className) {
                                  return DropdownMenuItem(
                                    value: className,
                                    child: Text(
                                      className,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                validator: (value) => value == null
                                    ? 'Please select a class.'
                                    : null,
                                onSaved: (value) {
                                  _student.studentClass = value!;
                                },
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedCourse,
                                hint: Text(
                                  'Select Course',
                                  style: GoogleFonts.poppins(),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedCourse = newValue;
                                  });
                                },
                                items: _courses.map((course) {
                                  return DropdownMenuItem(
                                    value: course,
                                    child: Text(
                                      course,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                validator: (value) =>
                                    value == null ? 'Select Course' : null,
                                onSaved: (value) {
                                  _student.subject = value!;
                                },
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedCoachingCenter,
                                hint: Text(
                                  'Coaching Center',
                                  style: GoogleFonts.poppins(),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedCoachingCenter = newValue;
                                  });
                                },
                                items: _coachingCenters.map((center) {
                                  return DropdownMenuItem(
                                    value: center,
                                    child: Text(
                                      center,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                validator: (value) => value == null
                                    ? 'select coaching center.'
                                    : null,
                                onSaved: (value) {
                                  _student.coachingCenter = value!;
                                },
                              ),
                              DropdownButtonFormField<String>(
                                value: _selectedBoard,
                                hint: Text(
                                  'Select Board',
                                  style: GoogleFonts.poppins(),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedBoard = newValue;
                                  });
                                },
                                items: _boards.map((board) {
                                  return DropdownMenuItem(
                                    value: board,
                                    child: Text(
                                      board,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                validator: (value) => value == null
                                    ? 'Please select a board.'
                                    : null,
                                onSaved: (value) {
                                  _student.board = value!;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    key: const ValueKey('fullName'),
                    decoration: InputDecoration(
                      labelText: 'Your Full Name',
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a full name.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _student.fullName = value!;
                    },
                  ),
                  TextFormField(
                    key: const ValueKey('guardianName'),
                    decoration: InputDecoration(
                      labelText: 'Guardian Name',
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a guardian name.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _student.guardianName = value!;
                    },
                  ),
                  TextFormField(
                    key: const ValueKey('phoneNumber'),
                    decoration: InputDecoration(
                      labelText: 'Student Number',
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty ||
                          value.length != 10 ||
                          !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid 10-digit phone number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _student.phoneNumber = '+91${value!}';
                    },
                  ),
                  TextFormField(
                    key: const ValueKey('parentsNumber'),
                    decoration: InputDecoration(
                      labelText: 'Parent Number',
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty ||
                          value.length != 10 ||
                          !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid 10-digit phone number.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _student.parentsNumber = '+91${value!}';
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, right: 100),
                    child: TextFormField(
                      key: const ValueKey('joiningDate'),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Joining Date',
                        labelStyle: GoogleFonts.poppins(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('dd-MM-yyyy')
                            .format(_student.joiningDate),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null &&
                            pickedDate != _student.joiningDate) {
                          setState(() {
                            _student.joiningDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _trySubmit,
                    style: ElevatedButton.styleFrom(
                      iconColor: const Color.fromARGB(255, 5, 10, 14),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
