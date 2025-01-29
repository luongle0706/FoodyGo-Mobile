import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                child: Text('Login'),
                onPressed: () {
                  GoRouter.of(context).pushNamed('login');
                },
              ),
              ElevatedButton(
                child: Text('Profile'),
                onPressed: () {
                  GoRouter.of(context).pushNamed('profile');
                },
              ),
              ElevatedButton(
                child: Text('Register'),
                onPressed: () {
                  GoRouter.of(context).pushNamed('register');
                },
              ),
            ],
          ),
        ));
  }
}
