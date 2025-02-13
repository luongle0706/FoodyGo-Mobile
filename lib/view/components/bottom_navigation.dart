import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FoodyGoNavigationBar extends StatelessWidget {
  const FoodyGoNavigationBar({super.key});

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
            width: 36,
            height: 36,
          ),
        ),
        Text(
          name,
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _getNavComp(context, '/protected/home', 'fork', 'Trang chủ'),
          _getNavComp(context, '/protected/order', 'paper', 'Đơn hàng'),
          _getNavComp(context, '/protected/wallet', 'wallet', 'Ví'),
          _getNavComp(context, '/protected/notification', 'bell', 'Thông báo'),
          _getNavComp(context, '/protected/user', 'user', 'Tài khoản'),
        ],
      ),
    );
  }
}
