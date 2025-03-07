import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/dto/wallet_dto.dart';
import 'package:foodygo/repository/wallet_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: const Text(
          'Chuyển điểm',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CHỌN NGƯỜI NHẬN',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        hintText: 'Số điện thoại người nhận',
                        suffixIcon: Icon(Icons.contacts),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('SỐ FOODYXU CẦN CHUYỂN',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                            'Số dư: ${_balance.toInt()} FoodyXu', // Display balance as integer
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '$_points FoodyXu', // Already displaying as integer
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                                '${_points * 1000} đ', // No need for toInt() since _points is already int
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: _points
                              .toDouble(), // Convert int to double for Slider
                          min: 0,
                          max: _balance,
                          divisions: _balance > 100 ? 100 : _balance.toInt(),
                          label: _points
                              .toString(), // Display integer value in label
                          onChanged: (value) {
                            setState(() {
                              _points =
                                  value.toInt(); // Convert slider value to int
                            });
                          },
                        ),
                        const Text(
                            'Số FoodyXu cần chuyển không được vượt quá số hiện có.',
                            style: TextStyle(color: Colors.grey)),
                        const Text('(1.000đ = 1 FoodyXu)',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Lời nhắn',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1),
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
                        ? const Center(child: CircularProgressIndicator())
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                  color: Colors.black, width: 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: Colors.white,
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
              'Bạn đã chuyển thành công $_points FoodyXu (${_points * 1000}đ) đến ${_phoneController.text}',
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
