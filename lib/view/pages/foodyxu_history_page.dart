import 'package:flutter/material.dart';
import 'package:foodygo/dto/transaction_item.dart';
import 'package:foodygo/view/components/transaction_card.dart';
import 'package:go_router/go_router.dart';

class FoodyXuHistoryPage extends StatelessWidget {
  final List<TransactionItem> transactions = [
    TransactionItem("Thanh toán đơn hàng", "- 50 FoodyXu", "04/12/2023 11:32",
        Icons.payment),
    TransactionItem(
        "Mua điểm", "+ 50 FoodyXu", "04/12/2023 11:32", Icons.attach_money),
    TransactionItem(
        "Chuyển điểm", "- 50 FoodyXu", "04/12/2023 11:32", Icons.swap_horiz),
    TransactionItem(
        "Rút tiền", "- 5000 FoodyXu", "04/12/2023 11:32", Icons.money_off),
    TransactionItem(
        "Nhận điểm", "+ 50 FoodyXu", "04/12/2023 11:32", Icons.swap_horiz),
  ];

  FoodyXuHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lịch sử điểm FoodyXu"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              context.go('/protected/wallet/transaction-detail');
            },
            child: TransactionCard(transaction: transactions[index]),
          );
        },
      ),
    );
  }
}
