import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/category_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/category_repostory.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic>? _categories;
  bool _isLoading = true;
  final AppLogger logger = AppLogger.instance;
  final SecureStorage storage = SecureStorage.instance;
  final CategoryRepostory categoryRepostory = CategoryRepostory.instance;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    String? userData = await storage.get(key: 'user');
    SavedUser? user =
        userData != null ? SavedUser.fromJson(json.decode(userData)) : null;
    if (user != null) {
      if (!(await loadCategories(user))) {
        logger.error('Failed to get categories');
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      logger.info('Failed to get user');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> loadCategories(SavedUser user) async {
    Map<String, dynamic>? response =
        await categoryRepostory.loadCategories(accessToken: user.token);
    if (response != null && response['data'] != null) {
      setState(() {
        _categories = response['data'];
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
            title: Text(
              'Danh mục',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        title: Text(
          'Danh mục',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: _categories?.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _categories?[index]['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_categories?[index]['description']),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              GoRouter.of(context).push("/protected/add-edit-category", extra: CategoryDto.fromJson(_categories?[index]));
            },
          );
        },
      ),
    );
  }
}
