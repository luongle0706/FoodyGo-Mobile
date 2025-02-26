import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WalletHomepage extends StatelessWidget {
  const WalletHomepage({super.key});

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                  children: const [
                    Text(
                      'Chào Tấn Lộc Phạm !',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '💰 140 FoodyXu',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black54)
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
                  subtitle: 'Chuyển điểm FoodyXu cho bạn bè và người thân',
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
