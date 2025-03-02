import 'package:flutter/material.dart';
import 'package:foodygo/view/components/hub/hub_app_bar.dart';
import 'package:foodygo/view/theme.dart';

class HubHomeWrapper extends StatelessWidget {
  final Widget child;

  const HubHomeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(500), child: HubAppBar()),
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: child,
    );
  }
}
