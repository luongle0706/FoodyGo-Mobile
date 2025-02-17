import 'package:flutter/material.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  String _getCurrentPath(BuildContext context) {
    return GoRouterState.of(context).matchedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _getCurrentPath(context),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ));
  }
}
