import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/service/auth_service.dart';
import 'package:foodygo/utils/injection.dart';

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
    return SavedUser.fromJson(json.decode(savedUser));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
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
              return Center(child: Text('Error!'));
            }
            final user = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Username: ${user.email}'),
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
