import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTextStyle {
  static const _family = 'Noto Sans TC';

  static TextStyle get homeTitle => TextStyle(
    fontFamily: _family,
    fontSize: 40.sp,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  static TextStyle get backLabel => TextStyle(
    fontFamily: _family,
    fontSize: 20.sp,
    fontWeight: FontWeight.w400,
    height: 24 / 20,
  );

  static TextStyle get appBarTitle => TextStyle(
    fontFamily: _family,
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.8.sp,
  );

  static TextStyle get medium16 => TextStyle(
    fontFamily: _family,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static TextStyle get medium18 => TextStyle(
    fontFamily: _family,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static TextStyle get medium24 => TextStyle(
    fontFamily: _family,
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.5.sp,
  );

  static TextStyle get bold => TextStyle(
    fontFamily: _family,
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    height: 24 / 14,
    letterSpacing: 0.5.sp,
  );

  static TextStyle get regular12 => TextStyle(
    fontFamily: _family,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  static TextStyle get regular14 => TextStyle(
    fontFamily: _family,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 24 / 14,
    letterSpacing: 0.5.sp,
  );

  static TextStyle get regular16 => TextStyle(
    fontFamily: _family,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    letterSpacing: 0.32.sp,
  );
}
