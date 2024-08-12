import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nienproject/controllers/userController.dart';
import 'package:nienproject/private_pages/loginAdmin.dart'; // Import tệp loginAdmin.dart
import 'package:nienproject/screens/chatroompage_user.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CarouselController _controller = CarouselController();

  final List<Map<String, dynamic>> _functions = [
    {
      "icon": Icons.calendar_today,
      "label": "Lịch học",
      "color": Colors.lightGreen,
      "size": 50
    },
    {
      "icon": Icons.analytics,
      "label": "Tư vấn",
      "color": Colors.purple,
      "size": 50
    },
    {
      "icon": Icons.book,
      "label": "Khóa học",
      "color": Colors.orange,
      "size": 50
    },
    {
      "icon": Icons.star,
      "label": "Thành tích",
      "color": Colors.yellow,
      "size": 50
    },
    {
      "icon": Icons.chat,
      "label": "Khảo sát",
      "color": Colors.blueGrey,
      "size": 50
    },
    {
      "icon": Icons.fitness_center,
      "label": "Rèn luyện",
      "color": Colors.pink,
      "size": 50
    },
    {
      "icon": Icons.attach_money,
      "label": "Công nợ",
      "color": Colors.blue,
      "size": 50
    },
    {
      "icon": Icons.check_circle,
      "label": "Điểm danh",
      "color": Colors.green,
      "size": 50
    },
  ];

  final List<String> _carouselImages = [
    "assets/images/1.png",
    "assets/images/2.jpg",
    "assets/images/3.png",
    "assets/images/4.png", // Đảm bảo rằng đường dẫn đến ảnh cuối cùng là 4.png
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: AppBar(
            backgroundColor: Colors.blue,
            elevation: 0,
            title: Text(
              'Xin chào ${UserController.user?.displayName ?? ''}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'loginAdmin') {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LoginAdminScreen(),
                    ));
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'loginAdmin',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Đăng nhập với tư cách admin'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(_functions.length, (index) {
                  return InkWell(
                    onTap: () {
                      // Navigate to ChatRoomPage when "chat với nhân viên" is tapped
                      if (_functions[index]["label"] == "Tư vấn") {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatRoomPageUser(),
                        ));
                      }
                      // Add other navigation logic if needed
                    },
                    child: Card(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              _functions[index]["icon"],
                              color: _functions[index]["color"],
                            ),
                            Text(_functions[index]["label"]),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/bg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CarouselSlider(
                          carouselController: _controller,
                          options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: true,
                            enlargeFactor: 0.3,
                            viewportFraction: 1,
                          ),
                          items: _carouselImages.map((imagePath) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 15,
                  bottom: 15,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 30, color: Colors.white),
                    onPressed: () => _controller.previousPage(),
                  ),
                ),
                Positioned(
                  right: 15,
                  bottom: 15,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        size: 30, color: Colors.white),
                    onPressed: () => _controller.nextPage(),
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
