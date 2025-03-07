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

      // Open the payment URL in a WebView
      // ignore: duplicate_ignore
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            paymentUrl: paymentUrl,
            onPaymentComplete: (bool success) {
              Navigator.of(context).pop(); // Return to TopupPage
              Navigator.of(context)
                  .pop(success); // Return to Wallet page with result
            },
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
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });

            // Check if the URL is the return URL from payment gateway
            if (url.contains('/api/v1/payment/vn-pay-callback') ||
                url.contains('/api/v1/payment/momo-callback')) {
              _logger.info("Payment callback detected: $url");

              // Open this URL in the browser instead of handling it in WebView
              _openCallbackInBrowser(url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            _logger.error("WebView error: ${error.description}");
          },
          // Navigation delegate to decide which URLs to handle in WebView vs external browser
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // If this is a callback URL, open it in browser
            if (url.contains('/api/v1/payment/vn-pay-callback') ||
                url.contains('/api/v1/payment/momo-callback')) {
              _logger.info("Intercepted callback navigation: $url");
              _openCallbackInBrowser(url);
              return NavigationDecision.prevent;
            }

            // Allow all other URLs to load in WebView
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _openCallbackInBrowser(String url) async {
    _logger.info("Opening payment callback in browser: $url");

    try {
      // Check for success parameter in URL
      bool isSuccess =
          url.contains('vnp_ResponseCode=00') || url.contains('resultCode=0');

      // Try to launch the URL in browser
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Show success or failure message
        if (isSuccess) {
          _handlePaymentSuccess();
        } else {
          _handlePaymentFailure(url);
        }
      } else {
        _logger.error("Could not launch URL: $url");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở trình duyệt.')),
        );
      }
    } catch (e) {
      _logger.error("Error opening URL in browser: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi mở trình duyệt: $e')),
      );
    }
  }

  void _handlePaymentSuccess() {
    // Navigate back to the wallet page with success result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thanh toán thành công! Ví của bạn đã được cập nhật.'),
      ),
    );

    // Return to wallet page after a short delay
    Future.delayed(Duration(seconds: 2), () {
      if (widget.onPaymentComplete != null) {
        widget.onPaymentComplete!(true);
      } else {
        // Navigate back if no callback provided
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Return to TopupPage
        // ignore: use_build_context_synchronously
        Navigator.of(context)
            .pop(true); // Return to Wallet page with refresh flag
      }
    });
  }

  void _handlePaymentFailure(String url) {
    String errorMsg = 'Thanh toán không thành công.';

    // Extract error message from URL if available
    if (url.contains('message=')) {
      try {
        final uri = Uri.parse(url);
        final message = uri.queryParameters['message'];
        if (message != null && message.isNotEmpty) {
          errorMsg = message;
        }
      } catch (e) {
        _logger.error("Error parsing callback URL: $e");
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMsg)),
    );

    Future.delayed(Duration(seconds: 2), () {
      if (widget.onPaymentComplete != null) {
        widget.onPaymentComplete!(false);
      } else {
        // Navigate back if no callback provided
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Return to TopupPage
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
          // Add an open-in-browser button
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () async {
              final currentUrl = await _controller.currentUrl();
              if (currentUrl != null) {
                _openCallbackInBrowser(currentUrl);
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
