import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<SavedUser>? _userFuture;
  final authService = AuthService.instance;
  final logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      _userFuture = _fetchUser();
    });
  }

  Future<SavedUser> _fetchUser() async {
    String? savedUser = await SecureStorage.instance.get(key: 'user');
    if (savedUser == null) {
      throw Exception('User not found!');
    }
    Map<String, dynamic> userMap = json.decode(savedUser);
    return SavedUser(
        email: userMap['email'],
        token: userMap['token'],
        fullName: userMap['fullName']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              logger.error(snapshot.error.toString());
              return Column(
                children: [
                  OutlinedButton(
                    onPressed: () => authService.signOut(context),
                    child: Text("Sign out"),
                  ),
                  Center(child: Text('Error!')),
                ],
              );
            }
            final user = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Email: ${user.email}'),
                  Text('Full Name: ${user.fullName}'),
                  Text('Token: ${user.token}'),
                  OutlinedButton(
                    onPressed: () => authService.signOut(context),
                    child: Text("Sign out"),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
