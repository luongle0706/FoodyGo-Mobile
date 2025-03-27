import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class FoodyGoNavigationBar extends StatefulWidget {
  const FoodyGoNavigationBar({super.key});

  @override
  State<FoodyGoNavigationBar> createState() => _FoodyGoNavigationBarState();
}

class _FoodyGoNavigationBarState extends State<FoodyGoNavigationBar> {
  final storage = SecureStorage.instance;
  final logger = AppLogger.instance;
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
      {required BuildContext context,
      required String path,
      required String icon,
      required String name,
      dynamic extra}) {
    String imagePath = GoRouterState.of(context).matchedLocation.contains(path)
        ? 'assets/icons/${icon}1.png'
        : 'assets/icons/${icon}2.png';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            GoRouter.of(context).go(path, extra: extra);
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
              _getNavComp(
                  context: context,
                  path: '/protected/user',
                  icon: 'user',
                  name: 'Tài khoản'),
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
                  _getNavComp(
                      context: context,
                      path: '/protected/restaurant-home',
                      icon: 'house',
                      name: 'Trang chủ'),
                  _getNavComp(
                      context: context,
                      path: '/protected/restaurant-foodygo',
                      icon: 'fork',
                      name: 'FoodyGo'),
                  _getNavComp(
                      context: context,
                      path: '/protected/notifications',
                      icon: 'bell',
                      name: 'Thông báo'),
                  _getNavComp(
                      context: context,
                      path: '/protected/user',
                      icon: 'user',
                      name: 'Tài khoản'),
                ]
              : user?.role == 'ROLE_STAFF'
                  ? [
                      _getNavComp(
                          context: context,
                          path: '/protected/staff-home',
                          icon: 'house',
                          name: 'Trang chủ'),
                      _getNavComp(
                          context: context,
                          path: '/protected/notifications',
                          icon: 'bell',
                          name: 'Thông báo'),
                      _getNavComp(
                          context: context,
                          path: '/protected/user',
                          icon: 'user',
                          name: 'Tài khoản'),
                    ]
                  : [
                      _getNavComp(
                          context: context,
                          path: '/protected/home',
                          icon: 'fork',
                          name: 'Trang chủ'),
                      _getNavComp(
                          context: context,
                          path: '/protected/order-list-customer',
                          icon: 'paper',
                          name: 'Đơn hàng',
                          extra: user?.customerId),
                      _getNavComp(
                          context: context,
                          path: '/protected/chat',
                          icon: 'chat',
                          name: 'Trợ lý'),
                      _getNavComp(
                          context: context,
                          path: '/protected/notifications',
                          icon: 'bell',
                          name: 'Thông báo'),
                      _getNavComp(
                          context: context,
                          path: '/protected/user',
                          icon: 'user',
                          name: 'Tài khoản'),
                    ]),
    );
  }
}
