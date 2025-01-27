import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/utils/injection.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.username});

  final String? username;

  Future<SavedUser> get user async {
    String? savedUser = await locator<FlutterSecureStorage>().read(key: 'user');
    if (savedUser == null) {
      throw Exception('User not found!');
    }
    return SavedUser.fromJson(json.decode(savedUser));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder(
          future: user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error!'));
            }
            final user = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Username: ${user.email}'),
                  Text('Token: ${user.token}'),
                ],
              ),
            );
          }),
    );
  }
}
