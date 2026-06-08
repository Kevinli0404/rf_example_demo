import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_text_style.dart';
import 'package:rf_example/providers/rfid_providers.dart';

/// 連線狀態徽章
class StatusLight extends ConsumerWidget {
  final EdgeInsetsGeometry padding;

  const StatusLight({
    super.key,
    this.padding = const EdgeInsets.only(right: 14),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(effectiveConnectStateProvider);

    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 光暈圓點
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.color.withValues(alpha: 0.25),
                ),
              ),
              Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.color,
                ),
              ),
            ],
          ),
          SizedBox(width: 6.w),
          Text(
            state.label,
            style: AppTextStyle.regular12.copyWith(color: state.color),
          ),
        ],
      ),
    );
  }
}
