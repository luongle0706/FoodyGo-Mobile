import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // Đặt màu nền chính là xanh lá
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // PHẦN HÌNH ẢNH & CHẤM TRÒN
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Nền trắng
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), // Bo góc dưới
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(bottom: 40, top: 150), // Thêm khoảng cách cho đẹp
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 250,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      Image.asset(
                        'lib/view/images/welcome_images/food01.jpg',
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        'lib/view/images/welcome_images/food02.jpg',
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        'lib/view/images/welcome_images/food03.png',
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 40),
                      width: _currentPage == index ? 10 : 8,
                      height: _currentPage == index ? 10 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Colors.green : Colors.grey,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 30),
                Text(
                  "Search for favorite food\nnear you",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Discover foods from over 3250 restaurants.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),

          // login / register
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.green, // Nền xanh lá
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), // Bo góc trên
                topRight: Radius.circular(5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: BorderSide(color: Colors.white),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          GoRouter.of(context).push('/register');
                        },
                        child: Text("Sign Up",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.green),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          GoRouter.of(context).push('/login');
                        },
                        child:
                        Text("Sign In", style: TextStyle(color: Colors.green)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
