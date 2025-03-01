import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/dto/wallet_dto.dart';
import 'package:foodygo/repository/wallet_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

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
    String? data = await storage.get(key: 'user');
    if (data != null) {
      setState(() {
        user = SavedUser.fromJson(json.decode(data));
        token = user?.token;
      });
      logger.info('User loaded: ${user?.fullName}');
      fetchWalletBalance();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchWalletBalance() async {
    logger.info('Fetching wallet balance...');
    WalletDto? walletBalance =
        await walletRepository.loadWalletBalance(token!, user!.userId);
    setState(() {
      logger.info('Wallet balance: ${walletBalance.balance}');
      wallet = walletBalance;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FoodyPay',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào ${user?.fullName ?? 'User'}!',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '💰 ${wallet?.balance != null && wallet!.balance > 0 ? '${wallet!.balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} FoodyXu' : 'Đang tải...'}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.black54),
                    ],
                  ),
                ),
                Expanded(
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
                        subtitle: 'Xem lại lịch sử thanh toán các đơn hàng',
                        route: '/protected/wallet/transaction-history',
                      ),
                    ],
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
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.black54),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
