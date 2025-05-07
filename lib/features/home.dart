import 'package:flutter/material.dart';
import 'package:fitpro/auth/login_screen.dart';
import 'package:fitpro/features/activity_logger.dart'; // Import the ActivityLogger screen
import 'package:fitpro/features/profile.dart'; // Import the ProfilePage screen
import 'package:fitpro/features/education.dart'; // Import the EducationPage screen
//import 'package:fitpro/features/booking.dart'; // Import the BookingPage screen

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false, // Disable default back
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildCard(context, 'Activity', Icons.directions_run),
            _buildCard(context, 'Booking', Icons.calendar_today),
            _buildCard(context, 'Profile', Icons.person),
            _buildCard(context, 'Education', Icons.school),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          if (title == 'Activity') {
            // Navigate to ActivityLogger when "Activity" is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccelerationDistance(),
              ),
            );
          } else if (title == 'Profile') {
            // Navigate to ProfilePage when "Profile" is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } 
          else if (title == 'Education') {
            // Navigate to ProfilePage when "Profile" is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EducationPage()),
            );
          }
          // else if (title == 'Booking') {
          //   // Navigate to ProfilePage when "Profile" is clicked
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => const BookingPage()),
          //   );
          // }
          else {
            // Handle other card taps (if needed)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title feature is not implemented yet.')),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
