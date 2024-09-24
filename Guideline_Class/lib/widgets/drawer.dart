import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_1/const/colors.dart';
import 'package:student_1/screen/about%20us/aboutscreen.dart';
import 'package:student_1/screen/auth_screen.dart';
import 'package:student_1/screen/fees/feePayment.dart';
import 'package:student_1/screen/fees/feerecord.dart';
import 'package:student_1/screen/help&contact/contactscreen.dart';
import 'package:student_1/screen/help&contact/helpscreen.dart';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic> userData;

  const CustomDrawer({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userData['username'] ?? 'Username',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              userData['email'] ?? 'user@example.com',
              style: GoogleFonts.lato(
                fontSize: 16,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  userData['image_url'] ?? 'https://example.com/profile-pic'),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 9, 28, 31),
                  Color.fromARGB(237, 2, 64, 64)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildAnimatedTile(
                  context,
                  icon: Icons.payment,
                  text: 'Pay Fees',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => const StudentFeePaymentScreen()),
                    );
                  },
                ),
                const Divider(),
                _buildAnimatedTile(
                  context,
                  icon: Icons.history,
                  text: 'Payment History',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const PaymentHistoryScreen()),
                    );
                  },
                ),
                const Divider(),
                _buildAnimatedTile(
                  context,
                  icon: Icons.group_sharp,
                  text: 'About us',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AboutUsScreen()),
                    );
                  },
                ),
                const Divider(),
                _buildAnimatedTile(
                  context,
                  icon: Icons.help,
                  text: 'Help ',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const HelpScreen()),
                    );
                  },
                ),
                const Divider(),
                _buildAnimatedTile(
                  context,
                  icon: Icons.help,
                  text: 'Contact Us',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ContactScreen()),
                    );
                  },
                ),
                const Divider(),
                _buildAnimatedTile(
                  context,
                  icon: Icons.exit_to_app,
                  text: 'Logout',
                  color: Colors.red,
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTile(BuildContext context,
      {required IconData icon,
      required String text,
      required Function onTap,
      Color? color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primaryColor),
        title: Text(
          text,
          style: GoogleFonts.lato(
              fontSize: 18, color: color ?? AppColors.textColor),
        ),
        onTap: () => onTap(),
      ),
    );
  }
}
