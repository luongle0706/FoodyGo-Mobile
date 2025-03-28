import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/dto/wallet_dto.dart';
import 'package:foodygo/repository/wallet_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:foodygo/view/theme.dart';

class WalletHomepage extends StatefulWidget {
  const WalletHomepage({super.key});

  @override
  State<WalletHomepage> createState() => _WalletHomepageState();
}

class _WalletHomepageState extends State<WalletHomepage> {
  SavedUser? user;
  WalletDto? wallet;
  bool isLoading = true;
  String? token;
  final walletRepository = WalletRepository.instance;
  final AppLogger logger = AppLogger.instance;
  final storage = SecureStorage.instance;

  @override
  void initState() {
    super.initState();
    logger.info('Wallet homepage init');
    loadUser();
  }

  Future<void> loadUser() async {
    setState(() {
      isLoading = true;
    });

    String? data = await storage.get(key: 'user');
    SavedUser? savedUser =
        data != null ? SavedUser.fromJson(json.decode(data)) : null;
    if (savedUser != null) {
      WalletDto? walletBalance =
          await walletRepository.loadWalletBalance(savedUser);
      if (walletBalance != null) {
        setState(() {
          wallet = walletBalance;
          user = savedUser;
          token = user?.token;
          isLoading = false;
        });
      } else {
        logger.info("Failed to load wallet balance!");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      logger.info("Failed to load user!");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToRoute(String route) async {
    final needsRefresh = await GoRouter.of(context).push<bool>(route);

    // If returned value is true, refresh the wallet balance
    if (needsRefresh == true) {
      logger.info('Transaction completed, refreshing wallet balance');
      loadUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FoodyPay',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Column(
              children: [
                GestureDetector(
                  onTap: () =>
                      _navigateToRoute('/protected/wallet/transaction-history'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chào ${user?.fullName ?? 'User'}!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '💰 ${wallet?.balance != null ? '${wallet!.balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} FoodyXu' : 'Đang tải...'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildOptionCard(
                          context,
                          icon: Icons.attach_money,
                          title: 'Mua điểm',
                          subtitle:
                              'Mua điểm FoodyXu dễ dàng thông qua các hình thức thanh toán',
                          route: '/protected/wallet/topup',
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.swap_horiz,
                          title: 'Chuyển điểm',
                          subtitle:
                              'Chuyển điểm FoodyXu cho bạn bè và người thân',
                          route: '/protected/wallet/transfer',
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.money_off,
                          title: 'Rút tiền',
                          subtitle:
                              'Rút tiền từ FoodyPay dễ dàng thông qua các hình thức thanh toán',
                          route: '/protected/wallet/withdraw',
                        ),
                        _buildOptionCard(
                          context,
                          icon: Icons.history,
                          title: 'Lịch sử thanh toán',
                          subtitle: 'Xem lại lịch sử thanh toán của ví',
                          route: '/protected/wallet/payment-history',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => _navigateToRoute(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
