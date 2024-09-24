import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentFeePaymentScreen extends StatefulWidget {
  const StudentFeePaymentScreen({super.key});

  @override
  _StudentFeePaymentScreenState createState() =>
      _StudentFeePaymentScreenState();
}

class _StudentFeePaymentScreenState extends State<StudentFeePaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  String modeOfPayment = 'Cash';
  String? selectedCourse;
  List<DropdownMenuItem<String>> courseItems = [];
  bool isRequestPending = false;
  double totalFee = 0.0;
  double feePaid = 0.0;

  @override
  void initState() {
    super.initState();
    _loadApprovedCourses();
    _checkPendingRequests();
  }

  void _loadApprovedCourses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final approvedCoursesSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('studentId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'approved')
          .get();

      final courses = approvedCoursesSnapshot.docs
          .map((doc) {
            if (doc.exists && doc.data().containsKey('courseName')) {
              return DropdownMenuItem<String>(
                value: doc.id,
                child: Text(doc['courseName']),
              );
            } else {
              return null;
            }
          })
          .whereType<DropdownMenuItem<String>>()
          .toList();

      setState(() {
        courseItems = courses;
      });
    }
  }

  void _checkPendingRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final pendingRequestSnapshot = await FirebaseFirestore.instance
          .collection('feeRequests')
          .where('studentId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();

      if (studentDoc.exists) {
        setState(() {
          isRequestPending = pendingRequestSnapshot.docs.isNotEmpty;
          totalFee = (studentDoc['totalFees'] ?? 0).toDouble();
          feePaid = (studentDoc['feePaid'] ?? 0).toDouble();
        });
      }
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pay Fees'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCourse,
              items: courseItems,
              onChanged: (value) {
                setState(() {
                  selectedCourse = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Select Course'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Mode of Payment'),
              enabled: false,
              controller: TextEditingController(text: modeOfPayment),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: _payFee,
            child: const Text('Submit Payment Request'),
          ),
        ],
      ),
    );
  }

  void _payFee() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount > 0 &&
        selectedCourse != null &&
        !isRequestPending &&
        (feePaid + amount <= totalFee)) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .get();
        if (studentDoc.exists && studentDoc.data()!.containsKey('fullName')) {
          final fullName = studentDoc['fullName'];

          await FirebaseFirestore.instance.collection('feeRequests').add({
            'studentId': user.uid,
            'studentName': fullName,
            'status': 'pending',
            'amount': amount,
            'modeOfPayment': modeOfPayment,
            'courseId': selectedCourse,
            'courseName': courseItems
                .firstWhere((item) => item.value == selectedCourse)
                .child
                .toString(),
            'timestamp': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fee payment request submitted')),
          );

          Navigator.of(context).pop();
          setState(() {
            isRequestPending = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Student full name not found')),
          );
        }
      }
    } else {
      String errorMessage = 'Please ensure:';
      if (selectedCourse == null) errorMessage += '\n- Course is selected';
      if (amount <= 0) errorMessage += '\n- Amount is greater than 0';
      if (isRequestPending) errorMessage += '\n- No pending requests';
      if (feePaid + amount > totalFee) {
        errorMessage += '\n- Amount does not exceed total fee';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Fees'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: !isRequestPending ? _showPaymentDialog : null,
              child: const Text('Pay Fees'),
            ),
            if (isRequestPending)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'You have a pending payment request.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
