import 'package:flutter/material.dart';
import 'package:nienproject/controllers/userController.dart';
import 'package:nienproject/screens/chat_screen.dart';
import 'package:nienproject/screens/dashboard.dart';
import 'package:nienproject/screens/notification.dart';
import 'package:nienproject/screens/profile.dart';
import 'package:nienproject/screens/search.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? googleUid; // Thêm biến googleUid để lưu trữ uid từ UserController
  bool _isDialogShown =
      false; // Biến cờ kiểm tra xem dialog đã được hiển thị hay chưa

  @override
  void initState() {
    super.initState();
    _loadUid();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDialogOnce();
    });
  }

  void _loadUid() async {
    try {
      googleUid = await UserController.getGoogleUUID();
    } catch (error) {
      print('Error loading UID: $error');
    }
  }

  void _showDialogOnce() {
    if (googleUid != null && !_isDialogShown) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Thông báo'),
            content:
                const Text('Bạn đang đăng nhập với tư cách sinh viên.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Đóng'),
              ),
            ],
          );
        },
      );
      _isDialogShown = true;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToChatScreen() async {
    try {
      if (googleUid != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(userId: googleUid!)),
        );
      } else {
        // Handle case where uid is null
        print('Failed to get UID.');
      }
    } catch (error) {
      print('Error navigating to ChatScreen: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            DashboardScreen(), // Pass googleUid to DashboardScreen
            const NotificationsScreen(),
            const Placeholder(), // Placeholder for ChatScreen in the IndexedStack
            const SearchScreen(),
            const ProfileScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToChatScreen,
          child: const Icon(Icons.message),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _onItemTapped(1),
              ),
              const SizedBox(width: 48), // The placeholder for the center tab
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _onItemTapped(3),
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
