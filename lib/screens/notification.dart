// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Chào mừng đến với Đại học!',
      'subtitle':
          'Cảm ơn bạn đã đăng ký. Chúng tôi rất vui mừng khi có bạn là một phần của cộng đồng của chúng tôi.',
      'time': '2 phút trước'
    },
    {
      'title': 'Cập nhật mới có sẵn',
      'subtitle':
          'Một phiên bản mới của nền tảng học tập của chúng tôi đã sẵn sàng để tải xuống. Lấy ngay các tính năng và cải tiến mới nhất.',
      'time': '1 giờ trước'
    },
    {
      'title': 'Bảo trì định kỳ',
      'subtitle':
          'Vui lòng lưu ý rằng sẽ có một bảo trì định kỳ vào đêm nay lúc nửa đêm. Mong bạn thông cảm về sự tạm thời không khả dụng trong thời gian này.',
      'time': '5 giờ trước'
    }
    // Add more notifications here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Thông báo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          var notification = _notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notification['title']),
            subtitle: Text(notification['subtitle']),
            trailing: Text(notification['time']),
            onTap: () {
              // Handle the tap event here, for example, navigate to the notification details page.
            },
          );
        },
      ),
    );
  }
}
