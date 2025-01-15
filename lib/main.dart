import 'package:flutter/material.dart';
import 'package:foodygo/projects/routes/app_route_config.dart';

void main() {
  runApp(
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: MyAppRouter().router,
    ),
  );
}
