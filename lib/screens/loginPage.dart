import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:nienproject/controllers/userController.dart';

import 'guestHome.dart'; // Import the guest page
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Image.asset('assets/images/nttu.png'),
              ),
              const Spacer(),
              Text(
                'Hỗ trợ tư vấn tuyển sinh',
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                child: Text(
                  "Bạn hỏi, chúng tôi trả lời với công nghệ AI hiện đại dựa trên nền tảng Chat GPT.",
                  textAlign: TextAlign.center,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () async {
                  try {
                    final user = await UserController.loginWithGoogle();
                    if (user != null && mounted) {
                      // Check if the user's email domain is @nttu.edu.vn
                      if (user.email != null &&
                          user.email!.endsWith('@nttu.edu.vn')) {
                        // If the email domain is @nttu.edu.vn, navigate to MyHomePage
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MyHomePage(),
                        ));
                      } else {
                        // If the email domain is not @nttu.edu.vn, navigate to GuestHomePage
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const GuestHomePage(),
                        ));
                      }
                    }
                  } on FirebaseAuthException catch (error) {
                    print(error.message);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        error.message ?? "Đã có lỗi xảy ra",
                      ),
                    ));
                  } catch (error) {
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        error.toString(),
                      ),
                    ));
                  }
                },
                icon: const Icon(IconlyLight.login),
                label: const Text("Tiếp tục với Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
