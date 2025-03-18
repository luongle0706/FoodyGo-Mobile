import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/wallet_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Rút tiền',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                            hintText: 'Nhập số tiền',
                            hintStyle: TextStyle(color: Colors.black38),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text),
                      ),
                    ],
                  ),
                  Divider(
                      thickness: 1,
                      color: AppColors.secondary.withOpacity(0.5)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng xu sẽ trừ',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        '${_foodyXuAmount.toStringAsFixed(0)} FoodyXu',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(1.000đ = 1 FoodyXu)',
                    style: TextStyle(
                        fontSize: 12, color: Colors.black54.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: _isProcessing
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
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
                            color: Colors.white),
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
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
        title: const Text(
          'Thành công',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn đã rút thành công ${_foodyXuAmount.toStringAsFixed(0)} FoodyXu (${_amount.toStringAsFixed(0)}đ)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
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
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text(
              'Đóng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
