import 'package:flutter/material.dart';
import 'package:foodygo/view/components/bottom_navigation.dart';

class ProtectedRoutes extends StatelessWidget {
  final Widget child;

  const ProtectedRoutes({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: FoodyGoNavigationBar(),
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.green,
        body: child);
  }
}
