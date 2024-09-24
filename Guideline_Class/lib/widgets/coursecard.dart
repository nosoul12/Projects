import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_1/screen/course/course_detail.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const CourseCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  Future<Map<String, dynamic>> _fetchCourseDetails(String title) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('name', isEqualTo: title)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final courseDoc = querySnapshot.docs.first;
      return {
        'courseId': courseDoc.id,
        'price': courseDoc['price'],
      };
    } else {
      return {
        'courseId': 'N/A',
        'price': 0.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final courseDetails = await _fetchCourseDetails(title);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              price: courseDetails['price'],
              courseId: courseDetails['courseId'],
              title: title,
              description: description,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade200,
                    const Color.fromARGB(255, 2, 10, 20),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
