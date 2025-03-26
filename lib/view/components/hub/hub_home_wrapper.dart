import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/user_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/components/hub/hub_app_bar.dart';
import 'package:foodygo/view/theme.dart';
import 'dart:convert';

class HubHomeWrapper extends StatefulWidget {
  final Widget child;

  const HubHomeWrapper({super.key, required this.child});

  @override
  State<HubHomeWrapper> createState() => _HubHomeWrapperState();
}

class _HubHomeWrapperState extends State<HubHomeWrapper> {
  final _storage = SecureStorage.instance;
  final _userRepository = UserRepository.instance;
  final _logger = AppLogger.instance;

  bool _isLoading = true;
  String hubName = "Đang tải...";
  SavedUser? _user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> fetchUserDataById(int userId, String accessToken) async {
    try {
      final userData = await _userRepository.getUserById(userId, accessToken);
      _logger.info("User Data: $userData");

      if (userData != null) {
        setState(() {
          hubName = userData['hubName'] ?? "Hub Z";
          _isLoading = false;
        });
      } else {
        setState(() {
          hubName = "Hub Z";
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.error("Lỗi lấy dữ liệu hub: $e");
      setState(() {
        hubName = "Lỗi tải dữ liệu";
        _isLoading = false;
      });
    }
  }

  Future<void> loadUser() async {
    try {
      String? userData = await _storage.get(key: 'user');
      if (userData != null) {
        _user = SavedUser.fromJson(json.decode(userData));

        if (_user != null) {
          await fetchUserDataById(_user!.userId, _user!.token);
          return;
        }
      }
      _logger.info('Không tìm thấy thông tin user.');
    } catch (e) {
      _logger.error("Lỗi load user: $e");
    }

    setState(() {
      hubName = "Lỗi tải user";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(500),
          child: HubAppBar(
            hubName: hubName,
          )),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : widget.child,
    );
  }
}
