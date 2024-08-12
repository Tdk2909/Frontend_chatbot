import 'package:flutter/material.dart';
import 'package:nienproject/controllers/userController.dart';
import 'package:nienproject/screens/loginPage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông tin sinh viên',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await UserController.signOut(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20), // Spacing between widgets
            CircleAvatar(
              radius: 70, // Desired size for the image
              foregroundImage:
                  NetworkImage(UserController.user?.photoURL ?? ''),
            ),
            const SizedBox(height: 20),
            Text(
              UserController.user?.displayName ?? '',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 10),
            Text(
              UserController.user?.email ?? '',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            // Widget to display the user's birth date using FutureBuilder
            FutureBuilder<DateTime?>(
              future: UserController.getBirthday(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final birthDate = snapshot.data;
                  if (birthDate != null) {
                    final formattedBirthDate =
                        '${birthDate.day}/${birthDate.month}/${birthDate.year}';
                    return ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Ngày sinh'),
                      subtitle: Text(formattedBirthDate),
                    );
                  } else {
                    return ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Ngày sinh'),
                      subtitle: Text('Ngày sinh không có sẵn'),
                    );
                  }
                }
              },
            ),
            // Add other information and customize as desired
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('Số điện thoại'),
              subtitle: Text('+123 456 789'),
            ),
            // Add a button to allow users to edit their profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle event when user presses edit button
                },
                child: const Text('Chỉnh Sửa Hồ Sơ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
