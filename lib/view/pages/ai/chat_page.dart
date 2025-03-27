import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:foodygo/dto/user_dto.dart';
import 'package:foodygo/repository/restaurant_repository.dart';
import 'package:foodygo/utils/app_logger.dart';
import 'package:foodygo/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:foodygo/repository/user_repository.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _storage = SecureStorage.instance;
  final _logger = AppLogger.instance;

  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _restaurants;
  SavedUser? _user;

  bool _isTyping = false;
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    init();
  }

  void init() async {
    String? userString = await _storage.get(key: 'user');
    SavedUser? userData =
        userString != null ? SavedUser.fromJson(json.decode(userString)) : null;
    if (userData != null) {
      final userInfo = await UserRepository.instance.getUserInfo(
        userData.userId,
        userData.token,
      );

      final restaurants =
          await RestaurantRepository.instance.loadRestaurants(userData.token);

      _logger.debug(userData.toString());
      _logger.debug(userInfo.toString());
      _logger.debug(restaurants.toString());
      setState(() {
        _user = userData;
        _restaurants = restaurants;
        _userInfo = userInfo;
      });
    }
  }

  Future<void> _loadMessages() async {
    final stored = await _storage.get(key: 'chat_history');
    if (stored != null) {
      final List decoded = jsonDecode(stored);
      setState(() {
        _messages = decoded
            .map<Map<String, String>>((e) => {
                  'role': e['role'].toString(),
                  'content': e['content'].toString()
                })
            .toList();
      });
    }
  }

  Future<void> _saveMessages() async {
    await _storage.put(
      key: 'chat_history',
      value: jsonEncode(_messages),
    );
  }

  Future<void> _clearChat() async {
    await _storage.delete(key: 'chat_history');
    setState(() {
      _messages.clear();
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isTyping = true;
    });

    _controller.clear();
    await _saveMessages();

    try {
      if (_user == null) return;
      String systemPrompt = 'Bạn là Trợ lý Foodygo.';
      systemPrompt = '''
        (Trả lời dưới format markdown .md)
        Bạn là Trợ lý Foodygo. Hãy giúp người dùng lựa chọn món ăn phù hợp.
        Khách hàng: ${_userInfo?['fullName'] ?? 'Không rõ'}
        Toà nhà: ${_userInfo?['buildingName'] ?? 'Không rõ'}

        Danh sách nhà hàng: ${_restaurants.toString()}
        ''';
      _logger.info('System prompts: $systemPrompt');

      final List<Map<String, String>> chatWithSystem = [
        {'role': 'system', 'content': systemPrompt},
        ..._messages,
      ];

      _logger.info("Calling API...");
      final response = await http
          .post(
            Uri.parse('https://ai.theanh0804.duckdns.org/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'gemma3:4b',
              'messages': chatWithSystem,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);
      final reply =
          data['message']['content'] ?? '⚠️ Không nhận được phản hồi.';

      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _isTyping = false;
      });

      await _saveMessages();
    } on TimeoutException {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '⏰ Hệ thống phản hồi quá chậm. Vui lòng thử lại sau.',
        });
        _isTyping = false;
      });
    } catch (e) {
      _logger.error(e.toString());
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '❌ Lỗi: ${e.toString()}',
        });
        _isTyping = false;
      });
    }
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.orangeAccent.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: MarkdownBody(
          data: content,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          title: const Text('Trợ lý Foodygo 🤖'),
          backgroundColor: Colors.orange.shade300,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Xoá cuộc trò chuyện',
              onPressed: _clearChat,
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return _buildMessageBubble('Đang nhập...', false);
                  }
                  final msg = _messages[index];
                  return _buildMessageBubble(
                    msg['content'] ?? '',
                    msg['role'] == 'user',
                  );
                },
              ),
            ),
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CircularProgressIndicator(color: Colors.orange.shade400),
              ),
            const Divider(height: 1),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn... 🍽️',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
