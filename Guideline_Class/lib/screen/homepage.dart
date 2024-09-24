import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_home/draggable_home.dart'; // Import draggable_home
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_1/const/colors.dart';
import 'package:student_1/screen/auth_screen.dart';
import 'package:student_1/widgets/drawer.dart';

class ReadOnlyHomeScreen extends StatelessWidget {
  const ReadOnlyHomeScreen({super.key});

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {};
    }
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error fetching user data')),
          );
        }

        final userData = snapshot.data!;
        return DraggableHome(
          title: Text(
            "Welcome to Guideline",
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          headerWidget: _headerWidget(context),
          body: [
            _buildBody(context),
          ],
          fullyStretchable: true,
          backgroundColor: AppColors.backgroundColor,
          appBarColor: AppColors.primaryColor,
          drawer: CustomDrawer(userData: userData),
        );
      },
    );
  }

  Widget _headerWidget(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg3.jpg'),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to Guideline",
              style: GoogleFonts.dosis(
                color: AppColors.whiteColor,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Explore the app to know more",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notices',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildSection('notice'),
          const SizedBox(height: 20),
          const Text(
            'Latest Achievements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildSection('latest_achievements'),
          const SizedBox(height: 20),
          const Text(
            'Previous Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildSection('previous_results'),
        ],
      ),
    );
  }

  Widget _buildSection(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        return Column(
          children: items.map((doc) {
            final item = doc.data() as Map<String, dynamic>;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: collection == 'latest_achievements'
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 4, 17, 7),
                            Color.fromARGB(255, 8, 74, 67)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.topRight,
                        )
                      : collection == 'previous_results'
                          ? const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 0, 0, 0),
                                Color.fromARGB(255, 4, 71, 57)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                            )
                          : const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 0, 0, 0),
                                Color.fromARGB(255, 4, 71, 57)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                            ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: Colors.white.withOpacity(0.3),
                      width: 50,
                      height: 50,
                      child: collection == "notice"
                          ? const Icon(Icons.notifications_active_sharp)
                          : collection == 'latest_achievements'
                              ? const Icon(Icons.celebration)
                              : collection == 'previous_results'
                                  ? const Icon(Icons.menu_book_rounded)
                                  : const Icon(Icons.ac_unit),
                    ),
                  ),
                  title: Text(
                    item['title'] ?? item['year'] ?? 'Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    item['description'] ?? 'Description',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
