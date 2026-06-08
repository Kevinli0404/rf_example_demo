import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 全域錯誤上報（Flutter framework 層 + 未捕獲的 async 例外）
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'rf_example',
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
