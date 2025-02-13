import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  String _getCurrentPath(BuildContext context) {
    return GoRouterState.of(context).matchedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Text(_getCurrentPath(context)),
      ),
    ));
  }
}
