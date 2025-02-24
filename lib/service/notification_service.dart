import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final Map<String, AndroidNotificationChannel> _channels = {
  'delivery': AndroidNotificationChannel(
      'delivery_channel', 'Delivery Notifications',
      description: 'Notifications for delivery updates',
      importance: Importance.high),
  'chat': AndroidNotificationChannel(
    'chat_channel',
    'Chat Messages',
    description: 'Notifications for new chat messages',
    importance: Importance.max, // Max for chat messages
  ),
  'general': AndroidNotificationChannel(
    'general_channel',
    'General Notifications',
    description: 'Other general notifications',
    importance: Importance.defaultImportance, // Normal notifications
  ),
};

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _requestPermission();
    await _setupMessageHandlers();

    final token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false);

    print("Permission status: ${settings.authorizationStatus}");
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      for (var channel in _channels.values) {
        await androidImplementation.deleteNotificationChannel(channel.id);
      }

      for (var channel in _channels.values) {
        await androidImplementation.createNotificationChannel(channel);
      }
    }

    const initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    // final InitializationSettingsDarwin = DarwinInitializationSettings(
    //     onDidReceiveLocalNotification: (id, title, body, payload) async {});

    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (details) {});

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      String type = message.data['type'] ?? 'general';
      AndroidNotificationChannel channel =
          _channels[type] ?? _channels['general']!;

      // Generate a unique ID for each notification
      int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _localNotifications.show(
          notificationId,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description,
                  importance: Importance.max,
                  priority: Priority.max,
                  fullScreenIntent: true,
                  playSound: true,
                  sound: RawResourceAndroidNotificationSound(
                      'notification_sound.mp3'.split('.').first),
                  icon: '@mipmap/ic_launcher')));
    }
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {}
  }
}
