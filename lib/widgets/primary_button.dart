// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:rf_example/core/app_colors.dart';
// import 'package:rf_example/core/app_text_style.dart';

// /// 首頁操作按鈕
// ///
// /// Figma 規格：
// /// - 按鈕大小：342 × 84
// /// - Icon：36 × 36
// /// - Icon 與文字間距：12
// /// - 文字大小：24
// class PrimaryButton extends StatelessWidget {
//   final String label;

//   /// 可以是 [Icon]、[Image.asset] 等任何 widget；
//   /// 內部鎖成 36×36（Figma 規格），Icon 不寫 size/color 也會自動套用。
//   final Widget icon;

//   final VoidCallback? onTap;

//   final Color backgroundColor;

//   final Color foregroundColor;

//   final double borderRadius;

//   const PrimaryButton({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.backgroundColor,
//     this.onTap,
//     this.foregroundColor = AppColors.white,
//     this.borderRadius = 12,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 342.w,
//         height: 84.h,
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(borderRadius.w),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 36.sp,
//               height: 36.sp,
//               child: IconTheme(
//                 data: IconThemeData(size: 36.sp, color: foregroundColor),
//                 child: icon,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Text(
//               label,
//               style: AppTextStyle.medium24.copyWith(color: AppColors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
