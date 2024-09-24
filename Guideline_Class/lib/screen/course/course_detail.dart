import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String courseId;
  final double price;

  const CourseDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.courseId,
    required this.price,
  });

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final TextEditingController _scholarshipController = TextEditingController();
  final TextEditingController _feePaidController = TextEditingController();
  String modeOfPayment = 'Cash';
  String? requestStatus;
  bool isLoading = true;
  Timer? _countdownTimer;
  Duration? _countdownDuration;

  @override
  void initState() {
    super.initState();
    _checkRequestStatus();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkRequestStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final requestSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(user.uid)
          .get();

      if (requestSnapshot.exists) {
        setState(() {
          requestStatus = requestSnapshot['status'];
          if (requestStatus == 'denied') {
            final deniedAt =
                (requestSnapshot['deniedAt'] as Timestamp).toDate();
            final currentTime = DateTime.now();
            final diff = currentTime.difference(deniedAt);
            if (diff.inHours < 3) {
              _countdownDuration = const Duration(hours: 3) - diff;
              _startCountdownTimer();
            } else {
              setState(() {
                requestStatus = null;
              });
            }
          }
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownDuration!.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          requestStatus = null;
        });
      } else {
        setState(() {
          _countdownDuration = _countdownDuration! - const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _registerUser() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ask for Scholarship for ${widget.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Price: \₹${widget.price}'),
            TextField(
              controller: _scholarshipController,
              decoration:
                  const InputDecoration(labelText: 'Scholarship Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _feePaidController,
              decoration: const InputDecoration(labelText: 'Fee Paid Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: modeOfPayment,
              items: ['Cash']
                  .map((mode) =>
                      DropdownMenuItem(value: mode, child: Text(mode)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  modeOfPayment = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Mode of Payment'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final scholarshipAmount =
                  int.tryParse(_scholarshipController.text) ?? -1;
              final feePaidAmount = int.tryParse(_feePaidController.text) ?? -1;

              if (scholarshipAmount < 0 ||
                  scholarshipAmount > widget.price ||
                  feePaidAmount < 0 ||
                  feePaidAmount > widget.price ||
                  (feePaidAmount + scholarshipAmount) > widget.price) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Scholarship amount should be less than or equal to price and greater than 0')),
                );
                return;
              }

              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final studentDoc = await FirebaseFirestore.instance
                    .collection('students')
                    .doc(user.uid)
                    .get();
                final fullName = studentDoc['fullName'];

                await FirebaseFirestore.instance
                    .collection('requests')
                    .doc(user.uid)
                    .set({
                  'courseId': widget.courseId,
                  'courseName': widget.title,
                  'studentId': user.uid,
                  'studentName': fullName,
                  'status': 'pending',
                  'price': widget.price,
                  'amount': scholarshipAmount,
                  'feePaid': feePaidAmount,
                  'modeOfPayment': modeOfPayment,
                });

                await FirebaseFirestore.instance
                    .collection('students')
                    .doc(user.uid)
                    .update({
                  'totalFees': widget.price,
                  'feePaid': feePaidAmount,
                  'scholarship': scholarshipAmount,
                  'feeDue': widget.price - (feePaidAmount + scholarshipAmount),
                });

                setState(() {
                  requestStatus = 'pending';
                });

                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Confirm Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: requestStatus == null || requestStatus == 'denied'
          ? _registerUser
          : null,
      label: Text(
        requestStatus == null
            ? 'Ask for Scholarship'
            : requestStatus == 'pending'
                ? 'Request Pending'
                : requestStatus == 'approved'
                    ? 'Scholarship Approved'
                    : _countdownDuration != null
                        ? 'Wait ₹${_formatDuration(_countdownDuration!)}'
                        : 'Request Denied, Try Again',
      ),
      icon: const Icon(Icons.school),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: GoogleFonts.poppins(fontSize: 16.0),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Price: \₹${widget.price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontSize: 16.0),
                  ),
                ],
              ),
            ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
