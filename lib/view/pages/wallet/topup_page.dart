// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/wallet_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  double _points = 100;
  String _selectedPaymentMethod = '';
  bool _isLoading = false;
  final WalletRepository _walletRepository = WalletRepository.instance;
  final AppLogger _logger = AppLogger.instance;
  final storage = SecureStorage.instance;

  @override
  Widget build(BuildContext context) {
    // Build method remains unchanged
    return Scaffold(
      appBar: AppBar(
        title: Text('Mua điểm'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nhập số FoodyXu cần mua',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_points.toInt().toString(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('FoodyXu', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Slider(
                          value: _points,
                          min: 0,
                          max: 1000,
                          divisions: 1000,
                          label: _points.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              _points = value;
                            });
                          },
                        ),
                        Text('Tổng tiền: ${(1000 * _points).toInt()} đ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('(1.000đ = 1 FoodyXu)',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('PHƯƠNG THỨC THANH TOÁN',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  RadioListTile(
                    title: Row(
                      children: [
                        Image.asset('assets/images/vnpay_logo.png', height: 24),
                        SizedBox(width: 10),
                        Text('VNPAY'),
                      ],
                    ),
                    value: 'VNPAY',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: Row(
                      children: [
                        Image.asset('assets/images/momo_logo.png', height: 24),
                        SizedBox(width: 10),
                        Text('Momo'),
                      ],
                    ),
                    value: 'MOMO',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _processTopUp,
                      child: Text('Thực hiện mua điểm',
                          style: TextStyle(fontSize: 16)),
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

  Future<void> _processTopUp() async {
    if (_selectedPaymentMethod.isEmpty) {
      _showErrorMessage('Vui lòng chọn phương thức thanh toán!');
      return;
    }

    if (_points <= 0) {
      _showErrorMessage('Vui lòng chọn số điểm lớn hơn 0!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user from secure storage
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

      // Call the top-up API
      final paymentData = await _walletRepository.topUpWallet(
          savedUser, _points, _selectedPaymentMethod);

      if (paymentData == null) {
        throw Exception("Failed to process payment request");
      }

      // Extract payment URL for VNPAY or MOMO
      final paymentUrl = paymentData['paymentUrl'];
      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw Exception("Invalid payment URL received");
      }

      // Open the payment URL in a WebView using Navigator
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            paymentUrl: paymentUrl,
            // Remove this callback - we'll handle navigation directly in _handlePaymentSuccess
          ),
        ),
      );
    } catch (e) {
      _logger.error("Error in top-up process: $e");
      _showErrorMessage('Lỗi xử lý thanh toán: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// WebView page to handle payment
class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(bool success)? onPaymentComplete;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    this.onPaymentComplete,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool isLoading = true;
  final AppLogger _logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });

            // Check for callback URLs as early as possible
            if (url.contains('/api/v1/payment/vn-pay-callback') ||
                url.contains('/api/v1/payment/momo-callback')) {
              _logger.info("Payment callback detected on page start: $url");
              _handleCallbackUrl(url);
            }
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });

            // Also check for callback URLs when page finishes loading
            if (url.contains('/api/v1/payment/vn-pay-callback') ||
                url.contains('/api/v1/payment/momo-callback')) {
              _logger.info("Payment callback detected on page finish: $url");
              _handleCallbackUrl(url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            _logger.error("WebView error: ${error.description}");
          },
          // Navigation delegate to decide which URLs to handle
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // If this is a callback URL, handle it in the app
            if (url.contains('/api/v1/payment/vn-pay-callback') ||
                url.contains('/api/v1/payment/momo-callback')) {
              _logger.info("Intercepted callback navigation: $url");
              _handleCallbackUrl(url);
              // We'll allow the navigation to continue, as we've already handled the response
              // This is important because sometimes the payment gateway expects a response
              return NavigationDecision.navigate;
            }

            // Allow all other URLs to load in WebView
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _handleCallbackUrl(String url) async {
    _logger.info("Handling payment callback: $url");

    try {
      final Uri uri = Uri.parse(url);

      // For VNPAY
      if (url.contains('/api/v1/payment/vn-pay-callback')) {
        // Check for success parameter in URL (vnp_ResponseCode=00 indicates success)
        bool isSuccess = uri.queryParameters['vnp_ResponseCode'] == '00' &&
            uri.queryParameters['vnp_TransactionStatus'] == '00';

        if (isSuccess) {
          _handlePaymentSuccess();
        } else {
          String errorMsg = 'Thanh toán không thành công.';
          // Try to extract error message if available
          if (uri.queryParameters.containsKey('message')) {
            errorMsg = uri.queryParameters['message'] ?? errorMsg;
          }
          _handlePaymentFailure(errorMsg);
        }
      }
      // For MOMO
      else if (url.contains('/api/v1/payment/momo-callback')) {
        // Check for success parameter in URL (resultCode=0 indicates success for MOMO)
        bool isSuccess = uri.queryParameters['resultCode'] == '0';

        if (isSuccess) {
          _handlePaymentSuccess();
        } else {
          String errorMsg = 'Thanh toán không thành công.';
          if (uri.queryParameters.containsKey('message')) {
            errorMsg = uri.queryParameters['message'] ?? errorMsg;
          }
          _handlePaymentFailure(errorMsg);
        }
      }
    } catch (e) {
      _logger.error("Error parsing callback URL: $e");
      _handlePaymentFailure("Lỗi xử lý phản hồi thanh toán: $e");
    }
  }

  void _handlePaymentSuccess() {
    _logger.info("Payment successful");

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thanh toán thành công! Ví của bạn đã được cập nhật.'),
        duration: Duration(seconds: 2),
      ),
    );

    // Return to wallet page after a short delay
    Future.delayed(Duration(seconds: 0), () {
      if (widget.onPaymentComplete != null) {
        widget.onPaymentComplete!(true);
      } else {
        // Use GoRouter to navigate directly to the wallet page
        if (mounted) {
          // This will close all previous pages and go directly to wallet
          context.goNamed('protected_wallet');
        }
      }
    });
  }

  void _handlePaymentFailure(String errorMsg) {
    _logger.error("Payment failed: $errorMsg");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      if (widget.onPaymentComplete != null) {
        widget.onPaymentComplete!(false);
      } else {
        // Navigate back to the topup page
        if (mounted) {
          context.pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Add a refresh button to reload the WebView
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          // Update the open-in-browser button to use _handleCallbackUrl
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () async {
              final currentUrl = await _controller.currentUrl();
              if (currentUrl != null) {
                _handleCallbackUrl(currentUrl);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
