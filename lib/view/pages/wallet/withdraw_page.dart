import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/wallet_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:go_router/go_router.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _amountController = TextEditingController();
  double _amount = 0;
  bool _isProcessing = false;
  final walletRepository = WalletRepository.instance;
  final logger = AppLogger.instance;
  final storage = SecureStorage.instance;

  // Convert VND to FoodyXu (1000 VND = 1 FoodyXu)
  double get _foodyXuAmount => _amount / 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Background color
      appBar: AppBar(
        backgroundColor: Colors.grey[400], // App bar color
        title: const Text(
          'Rút tiền',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập số tiền cần rút',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _amount = double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      const Text(
                        'đ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, color: Colors.black),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng xu sẽ trừ',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_foodyXuAmount.toStringAsFixed(0)} FoodyXu',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '(1.000đ = 1 FoodyXu)',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_amount < 1000) {
                          _showErrorMessage(
                              'Vui lòng nhập số tiền hợp lệ (tối thiểu 1.000đ)!');
                        } else if (_amount % 1000 != 0) {
                          _showErrorMessage(
                              'Vui lòng nhập số tiền là bội số của 1.000đ!');
                        } else {
                          _processWithdrawal();
                        }
                      },
                      child: const Text(
                        'Thực hiện rút tiền về ví',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _processWithdrawal() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get user from storage
      String? userData = await storage.get(key: 'user');
      if (userData == null) {
        _showErrorMessage(
            'Không thể xác thực người dùng. Vui lòng đăng nhập lại!');
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      SavedUser savedUser = SavedUser.fromJson(json.decode(userData));

      // Send withdrawal request
      bool success = await walletRepository.withdrawFromWallet(
          savedUser, _foodyXuAmount // Convert VND to FoodyXu
          );

      if (success) {
        // Navigate to success page or show success message
        _showWithdrawalSuccess();
      } else {
        _showErrorMessage(
            'Không thể thực hiện rút tiền. Vui lòng thử lại sau!');
      }
    } catch (e) {
      logger.error("Error during withdrawal: $e");
      _showErrorMessage('Đã xảy ra lỗi. Vui lòng thử lại sau!');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showWithdrawalSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thành công'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn đã rút thành công ${_foodyXuAmount.toStringAsFixed(0)} FoodyXu (${_amount.toStringAsFixed(0)}đ)',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and go back to wallet page with refresh flag
              Navigator.of(context).pop();

              // Return to WalletHomepage with refresh flag
              GoRouter.of(context)
                  .pop(true); // Pass true to indicate a refresh is needed
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
