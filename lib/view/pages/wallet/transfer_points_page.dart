import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/dto/wallet_dto.dart';
import 'package:foodygo/repository/wallet_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:foodygo/view/theme.dart';
import 'package:go_router/go_router.dart';

class TransferPointsPage extends StatefulWidget {
  const TransferPointsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransferPointsPageState createState() => _TransferPointsPageState();
}

class _TransferPointsPageState extends State<TransferPointsPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  int _points = 0; // Changed from double to int
  double _balance = 0;
  WalletDto? _wallet;
  bool _isLoading = true;
  bool _isProcessing = false;
  final walletRepository = WalletRepository.instance;
  final logger = AppLogger.instance;
  final storage = SecureStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      // Get user from storage
      String? userData = await storage.get(key: 'user');
      if (userData == null) {
        _showErrorMessage(
            'Không thể xác thực người dùng. Vui lòng đăng nhập lại!');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      SavedUser savedUser = SavedUser.fromJson(json.decode(userData));

      // Fetch wallet balance
      _wallet = await walletRepository.loadWalletBalance(savedUser);

      if (_wallet != null) {
        setState(() {
          _balance = _wallet!.balance;
          _isLoading = false;
        });
      } else {
        _showErrorMessage('Không thể tải thông tin ví. Vui lòng thử lại sau!');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.error("Error loading wallet balance: $e");
      _showErrorMessage('Đã xảy ra lỗi. Vui lòng thử lại sau!');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Chuyển điểm',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CHỌN NGƯỜI NHẬN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      )),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.secondary.withOpacity(0.5),
                          width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        hintText: 'Số điện thoại người nhận',
                        suffixIcon:
                            Icon(Icons.contacts, color: AppColors.primary),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('SỐ FOODYXU CẦN CHUYỂN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      )),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: AppColors.secondary.withOpacity(0.5),
                          width: 1),
                      borderRadius: BorderRadius.circular(12),
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
                      children: [
                        Text(
                            'Số dư: ${_balance.toInt()} FoodyXu', // Display balance as integer
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '$_points FoodyXu', // Already displaying as integer
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary)),
                            Text(
                                '${_points * 1000} đ', // No need for toInt() since _points is already int
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.primary,
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withOpacity(0.2),
                            valueIndicatorColor: AppColors.primary,
                          ),
                          child: Slider(
                            value: _points
                                .toDouble(), // Convert int to double for Slider
                            min: 0,
                            max: _balance,
                            divisions: _balance > 100 ? 100 : _balance.toInt(),
                            label: _points
                                .toString(), // Display integer value in label
                            onChanged: (value) {
                              setState(() {
                                _points = value
                                    .toInt(); // Convert slider value to int
                              });
                            },
                          ),
                        ),
                        Text(
                            'Số FoodyXu cần chuyển không được vượt quá số hiện có.',
                            style: TextStyle(color: Colors.grey.shade600)),
                        Text('(1.000đ = 1 FoodyXu)',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Lời nhắn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      )),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.secondary.withOpacity(0.5),
                          width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        hintText: 'Nhập lời nhắn',
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: _isProcessing
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary))
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            onPressed: () {
                              if (_phoneController.text.isEmpty) {
                                _showErrorMessage(
                                    'Vui lòng nhập số điện thoại người nhận!');
                              } else if (_points <= 0) {
                                _showErrorMessage(
                                    'Vui lòng nhập số FoodyXu cần chuyển!');
                              } else {
                                _processTransfer();
                              }
                            },
                            child: const Text(
                              'Chuyển điểm',
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

  Future<void> _processTransfer() async {
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

      // Send transfer request
      bool success = await walletRepository.transferPoints(
        savedUser,
        _phoneController.text,
        _points.toDouble(), // Convert to double for API if needed
        _messageController.text,
      );

      if (success) {
        // Show success message
        _showTransferSuccess();
      } else {
        _showErrorMessage(
            'Không thể thực hiện chuyển điểm. Vui lòng thử lại sau!');
      }
    } catch (e) {
      logger.error("Error during transfer: $e");
      _showErrorMessage('Đã xảy ra lỗi. Vui lòng thử lại sau!');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showTransferSuccess() {
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
              'Bạn đã chuyển thành công $_points FoodyXu (${_points * 1000}đ) đến ${_phoneController.text}',
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
