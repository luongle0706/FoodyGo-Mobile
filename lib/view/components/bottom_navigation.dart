import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class FoodyGoNavigationBar extends StatefulWidget {
  const FoodyGoNavigationBar({super.key});

  @override
  State<FoodyGoNavigationBar> createState() => _FoodyGoNavigationBarState();
}

class _FoodyGoNavigationBarState extends State<FoodyGoNavigationBar> {
  final storage = SecureStorage.instance;
  SavedUser? user;
  bool isLoading = true;

  Future<void> loadUser() async {
    String? data = await storage.get(key: 'user');
    if (data != null) {
      setState(() {
        user = SavedUser.fromJson(json.decode(data));
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Column _getNavComp(
      BuildContext context, String path, String icon, String name) {
    String imagePath = GoRouterState.of(context).matchedLocation.contains(path)
        ? 'assets/icons/${icon}1.png'
        : 'assets/icons/${icon}2.png';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            GoRouter.of(context).go(path);
          },
          icon: Image.asset(
            imagePath,
            width: 28,
            height: 28,
          ),
        ),
        Text(
          name,
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Row(
            children: [
              CircularProgressIndicator(),
              _getNavComp(context, '/protected/user', 'user', 'Tài khoản'),
            ],
          ), // Show loading indicator
        ),
      );
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: const Border(
          top: BorderSide(
            color: Colors.black,
            width: 0.3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: user?.role == 'ROLE_SELLER'
              ? [
                  _getNavComp(context, '/protected/restaurant-home', 'house',
                      'Trang chủ'),
                  _getNavComp(context, '/protected/restaurant-foodygo', 'fork',
                      'FoodyGo'),
                  _getNavComp(
                      context, '/protected/notification', 'bell', 'Thông báo'),
                  _getNavComp(context, '/protected/user', 'user', 'Tài khoản'),
                ]
              : user?.role == 'ROLE_STAFF'
                  ? [
                      _getNavComp(context, '/protected/staff-home', 'house',
                          'Trang chủ'),
                      _getNavComp(context, '/protected/notification', 'bell',
                          'Thông báo'),
                      _getNavComp(
                          context, '/protected/user', 'user', 'Tài khoản'),
                    ]
                  : [
                      _getNavComp(
                          context, '/protected/home', 'fork', 'Trang chủ'),
                      _getNavComp(context, '/protected/order-list-customer',
                          'paper', 'Đơn hàng'),
                      _getNavComp(context, '/protected/notification', 'bell',
                          'Thông báo'),
                      _getNavComp(
                          context, '/protected/user', 'user', 'Tài khoản'),
                    ]),
    );
  }
}
