import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:foodygo/utils/injection.dart';
import 'package:foodygo/view/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<SavedUser>? _userFuture;

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
    String? savedUser = await locator<FlutterSecureStorage>().read(key: 'user');
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
              print(snapshot.error);
              return Column(
                children: [
                  OutlinedButton(
                    onPressed: () => locator<AuthService>().signOut(context),
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
                    onPressed: () => locator<AuthService>().signOut(context),
                    child: Text("Sign out"),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
