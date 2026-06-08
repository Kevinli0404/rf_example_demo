import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/pages/home_page.dart';
import 'package:rf_example/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 全域錯誤上報（Flutter framework 層 + 未捕獲的 async 例外）
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // FCM 初始化
  await FcmService.init(
    onForegroundMessage: (RemoteMessage message) {
      // 前景收到推播時，由 MyApp 的 GlobalKey 顯示 SnackBar
      final title = message.notification?.title ?? '新通知';
      final body = message.notification?.body ?? '';
      MyApp.showNotificationBanner(title: title, body: body);
    },
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  // 顯示前景推播 banner
  static void showNotificationBanner({
    required String title,
    required String body,
  }) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.deepGrey,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (body.isNotEmpty)
              Text(
                body,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'rf_example',
          navigatorKey: _navigatorKey,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.black,
              elevation: 0,
            ),
          ),
          home: child,
          debugShowCheckedModeBanner: false,
        );
      },
      child: const HomePage(),
    );
  }
}
