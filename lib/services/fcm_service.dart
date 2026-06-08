import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';

// 背景訊息 handler，必須是 top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log('[FCM] background: ${message.messageId}');
}

/// FCM 初始化與訊息處理
class FcmService {
  FcmService._();

  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init({
    void Function(RemoteMessage message)? onForegroundMessage,
    void Function(RemoteMessage message)? onNotificationTap,
  }) async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 請求通知權限
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    dev.log('[FCM] permission: ${settings.authorizationStatus}');

    // 取得 token
    final token = await _messaging.getToken();
    dev.log('[FCM] token: $token');

    _messaging.onTokenRefresh.listen((t) => dev.log('[FCM] token refreshed: $t'));

    // 前景訊息
    FirebaseMessaging.onMessage.listen((message) {
      onForegroundMessage?.call(message);
    });

    // 背景通知點擊
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap?.call(message);
    });

    // 終止狀態通知點擊
    final initial = await _messaging.getInitialMessage();
    if (initial != null) onNotificationTap?.call(initial);
  }

  static Future<String?> getToken() => _messaging.getToken();
}
