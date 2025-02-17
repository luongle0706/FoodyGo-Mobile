import 'package:flutter/material.dart';
import 'package:foodygo/view/components/wallet_option_card.dart';
import 'package:go_router/go_router.dart';

class WalletHomepage extends StatelessWidget {
  const WalletHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FoodyPay'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.go('/protected/wallet/transaction-history');
            },
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chào Tấn Lộc Phạm !',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('💰 140 FoodyXu', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16)
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                WalletOptionCard(
                    icon: Icons.money,
                    title: 'Mua điểm',
                    subtitle:
                        'Mua điểm FoodyXu dễ dàng thông qua các hình thức thanh toán',
                    onTap: () {
                      GoRouter.of(context).go('/protected/wallet/topup');
                    }),
                WalletOptionCard(
                    icon: Icons.swap_horiz,
                    title: 'Chuyển điểm',
                    subtitle: 'Chuyển điểm FoodyXu cho bạn bè và người thân',
                    onTap: () {
                      GoRouter.of(context).go('/protected/wallet/transfer');
                    }),
                WalletOptionCard(
                    icon: Icons.attach_money,
                    title: 'Rút tiền',
                    subtitle:
                        'Rút tiền từ FoodyPay dễ dàng thông qua các hình thức thanh toán',
                    onTap: () {
                      GoRouter.of(context).go('/protected/wallet/withdraw');
                    }),
                WalletOptionCard(
                    icon: Icons.history,
                    title: 'Lịch sử thanh toán',
                    subtitle: 'Xem lại lịch sử thanh toán các đơn hàng',
                    onTap: () {
                      GoRouter.of(context)
                          .go('/protected/wallet/transaction-history');
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
