import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nienproject/controllers/userController.dart';
import 'package:nienproject/firebase_options.dart';
import 'package:nienproject/providers/chats_provider.dart';
import 'package:nienproject/screens/guestHome.dart';
import 'package:nienproject/screens/home.dart';
import 'package:nienproject/screens/loginPage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("Initializing Firebase...");
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully.");

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.lightBlue[800],
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem người dùng đã đăng nhập hay chưa
    if (UserController.user != null) {
      // Nếu đã đăng nhập, kiểm tra email của người dùng
      String? userEmail = UserController.user!.email;
      if (userEmail != null && userEmail.endsWith('@nttu.edu.vn')) {
        // Nếu email có tên miền @nttu.edu.vn, chuyển hướng đến MyHomePage
        return const MyHomePage();
      } else {
        // Nếu không có tên miền @nttu.edu.vn, chuyển hướng đến GuestPage
        return const GuestHomePage();
      }
    } else {
      // Nếu chưa đăng nhập, chuyển hướng đến trang đăng nhập
      return const LoginPage();
    }
  }
}
