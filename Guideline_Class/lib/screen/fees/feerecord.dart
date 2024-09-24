import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchPaymentHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    try {
      QuerySnapshot feeRecordsSnapshot = await FirebaseFirestore.instance
          .collection('feeRequests')
          .where('studentId', isEqualTo: user.uid)
          .get();

      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();

      double totalFee = studentDoc.data().toString().contains('totalFees')
          ? studentDoc.get('totalFees')
          : 0.0;
      double feePaid = studentDoc.data().toString().contains('feePaid')
          ? studentDoc.get('feePaid')
          : 0.0;

      return feeRecordsSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['feeDue'] = totalFee - feePaid;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching payment history: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPaymentHistory(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred!'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No payment records found.'));
          }

          final paymentRecords = snapshot.data!;
          return ListView.builder(
            itemCount: paymentRecords.length,
            itemBuilder: (ctx, index) {
              final record = paymentRecords[index];
              return ListTile(
                title: Text('Paid: ₹${record['amount']}'),
                subtitle: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format((record['timestamp'] as Timestamp).toDate())}',
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Status: ${record['status']}'),
                    Text('Due: ₹${record['feeDue']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
