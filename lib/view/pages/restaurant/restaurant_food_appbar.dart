import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodygo/dto/restaurant_dto.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class RestaurantFoodAppbar extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final void Function({required int tabIndex}) setTab;
  final int selectedTab;

  const RestaurantFoodAppbar(
      {super.key,
      required this.title,
      required this.setTab,
      required this.selectedTab});

  @override
  State<RestaurantFoodAppbar> createState() => _RestaurantFoodAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(150);
}

class _RestaurantFoodAppbarState extends State<RestaurantFoodAppbar> {
  RestaurantDto? _restaurantDto;
  final RestaurantRepository _restaurantRepository =
      RestaurantRepository.instance;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    String? userString = await SecureStorage.instance.get(key: 'user');
    SavedUser? userData =
        userString != null ? SavedUser.fromJson(json.decode(userString)) : null;
    if (userData != null) {
      await fetchRestaurant(user: userData);
    }
  }

  Future<bool> fetchRestaurant({required SavedUser user}) async {
    RestaurantDto? fetchOrder = await _restaurantRepository.loadRestaurantById(
        user.token, user.restaurantId!);

    if (fetchOrder != null) {
      setState(() {
        _restaurantDto = fetchOrder;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 30),
          color: AppColors.primary, // Using the primary color from AppColors
          child: Column(
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _restaurantDto != null
                        ? Text(
                            _restaurantDto!.name,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : SizedBox(),
                    GestureDetector(
                      onTap: () {
                        GoRouter.of(context)
                            .push("/protected/open-hours-setting", extra: 1);
                      },
                      child: _restaurantDto != null
                          ? Row(
                              children: [
                                Icon(Icons.circle,
                                    size: 11,
                                    color: _restaurantDto!.available
                                        ? Colors.green
                                        : Colors.grey),
                                SizedBox(width: 5),
                                Text(
                                  _restaurantDto!.available
                                      ? "Mở cửa "
                                      : "Đóng cửa ",
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    color: _restaurantDto!.available
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    size: 15, color: Colors.white),
                              ],
                            )
                          : SizedBox(),
                    )
                  ],
                ),
              ),
              // Tab buttons container
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTabButton(context, "Đơn", 0),
                    const SizedBox(width: 10),
                    _buildTabButton(context, "Thực đơn", 1),
                    const SizedBox(width: 10),
                    _buildTabButton(context, "Báo cáo", 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(BuildContext context, String text, int tabIndex) {
    final bool isSelected = widget.selectedTab == tabIndex;

    return GestureDetector(
      onTap: () {
        widget.setTab(tabIndex: tabIndex);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.text
              : AppColors.secondary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.2 : 0.1),
              blurRadius: isSelected ? 6 : 4,
              offset: isSelected ? const Offset(0, 3) : const Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
