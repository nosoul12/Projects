import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 16, 80, 93),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Our Faculty',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildFacultyCard(
                'Mr. Aakash Gupta',
                'Bachelor of Dental Surgery \n+918770025258',
                'assets/images/teacher1.jpg'),
            _buildFacultyCard(
                'Anurag Sharma',
                'M.Sc in chemistry\n +918717889208',
                'assets/images/teacher2.jpg'),
            _buildFacultyCard('Er.Ravi Kumar', 'PhD in Maths\n+917903162679',
                'assets/images/logo.png'),
            _buildFacultyCard(
                'Er.Roshan Kumar',
                'B.tech in Electronics and \nCommunication\n+91 72473 39987',
                'assets/images/logo.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyCard(
      String name, String qualification, String imageaddress) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(imageaddress))),
              width: 80,
              height: 80,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  qualification,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
