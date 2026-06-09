import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/core/app_text_style.dart';

/// 成功 toast — 頂部綠色，帶打勾 icon
void showSuccessToast(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 2),
}) {
  _showToast(
    context,
    duration: duration,
    child: _SuccessToast(message: message),
  );
}

/// 錯誤 toast — 頂部紅色
void showErrorToast(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  _showToast(
    context,
    duration: duration,
    child: _ErrorToast(message: message),
  );
}

void _showToast(
  BuildContext context, {
  required Widget child,
  required Duration duration,
  double bottomOffset = 116,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: bottomOffset.h,
      left: 0,
      right: 0,
      child: Center(
        child: Material(color: Colors.transparent, child: child),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(duration, () {
    if (entry.mounted) entry.remove();
  });
}

class _SuccessToast extends StatelessWidget {
  final String message;
  const _SuccessToast({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 298.w,
      height: 42.h,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: AppColors.green, width: 1),
      ),
      child: Text(
        message,
        style: AppTextStyle.regular14.copyWith(
          color: AppColors.green,
          height: 1,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ErrorToast extends StatelessWidget {
  final String message;
  const _ErrorToast({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 298.w,
      height: 42.h,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.delete.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: AppColors.delete, width: 1),
      ),
      child: Text(
        message,
        style: AppTextStyle.regular14.copyWith(
          color: AppColors.delete,
          height: 1,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
