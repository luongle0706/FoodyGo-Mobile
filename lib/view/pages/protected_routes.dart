import 'package:flutter/material.dart';
import 'package:foodygo/view/components/bottom_navigation.dart';
import 'package:foodygo/view/theme.dart';

class ProtectedRoutes extends StatelessWidget {
  final Widget child;

  const ProtectedRoutes({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          bottomNavigationBar: FoodyGoNavigationBar(),
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.background,
          body: child),
    );
  }
}
