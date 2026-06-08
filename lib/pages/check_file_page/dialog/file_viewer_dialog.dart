import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/core/app_text_style.dart';

/// 掃描結果預覽 Dialog：卡片式設備清單，未知 EPC 以橘色標示
class FileViewerDialog extends StatelessWidget {
  final String fileName;
  final List<FileDeviceEntry> devices;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FileViewerDialog({
    super.key,
    required this.fileName,
    required this.devices,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 32.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: 640.h),
        decoration: BoxDecoration(
          color: AppColors.deepGrey,
          borderRadius: BorderRadius.circular(22.w),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildCountBar(),
            Flexible(
              fit: FlexFit.loose,
              child: _buildDeviceList(),
            ),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 8.w, 14.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.description_rounded,
              color: AppColors.white,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyle.medium16.copyWith(color: AppColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '掃描結果',
                  style: AppTextStyle.regular12.copyWith(
                    color: AppColors.textGreyIt,
                  ),
                ),
              ],
            ),
          ),
          // ── 編輯 / 刪除 icon buttons ──────────────────────────
          _HeaderIconBtn(
            icon: Icons.edit_outlined,
            color: AppColors.midGrey,
            bgColor: AppColors.black.withValues(alpha: 0.3),
            onTap: () {
              Navigator.of(context).pop();
              onEdit?.call();
            },
          ),
          SizedBox(width: 4.w),
          _HeaderIconBtn(
            icon: Icons.delete_outline_rounded,
            color: AppColors.delete,
            bgColor: AppColors.delete.withValues(alpha: 0.10),
            onTap: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
    );
  }

  // ─── 數量列 ───────────────────────────────────────────────────────────────

  Widget _buildCountBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Text(
            '設備清單',
            style: AppTextStyle.regular12.copyWith(color: AppColors.textGreyIt),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Text(
              '共 ${devices.length} 筆',
              style: AppTextStyle.regular12.copyWith(color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 設備卡片清單 ─────────────────────────────────────────────────────────

  Widget _buildDeviceList() {
    if (devices.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 48.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 40.w,
                color: AppColors.textGreyIt,
              ),
              SizedBox(height: 12.h),
              Text(
                '此檔案沒有設備資料',
                style: AppTextStyle.regular14.copyWith(color: AppColors.textGreyIt),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: devices.length,
      separatorBuilder: (_, _) => SizedBox(height: 6.h),
      itemBuilder: (_, i) => _buildDeviceCard(i + 1, devices[i]),
    );
  }

  Widget _buildDeviceCard(int no, FileDeviceEntry entry) {
    final isUnknown = entry.isUnknown;
    final accentColor = isUnknown ? AppColors.secondary : AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(
          color: isUnknown
              ? AppColors.secondary.withValues(alpha: 0.35)
              : AppColors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 序號圓圈
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.14),
            ),
            child: Center(
              child: Text(
                no.toString().padLeft(2, '0'),
                style: AppTextStyle.regular12.copyWith(color: accentColor),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // 設備名稱 + 儀器編號
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: AppTextStyle.medium16.copyWith(
                    color: isUnknown ? AppColors.secondary : AppColors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  entry.instrument,
                  style: AppTextStyle.regular12.copyWith(
                    color: isUnknown
                        ? AppColors.secondary.withValues(alpha: 0.65)
                        : AppColors.textGreyIt,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isUnknown) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Text(
                '未知',
                style: AppTextStyle.regular12.copyWith(
                  color: AppColors.secondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 關閉按鈕 ─────────────────────────────────────────────────────────────

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22.w),
            bottomRight: Radius.circular(22.w),
          ),
        ),
        child: Center(
          child: Text(
            '關閉',
            style: AppTextStyle.medium16.copyWith(color: AppColors.primaryLight),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(9.w),
        ),
        child: Icon(icon, color: color, size: 18.w),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper 型別 + show function
// ─────────────────────────────────────────────────────────────────────────────

/// Dialog 顯示用的設備 entry
class FileDeviceEntry {
  final String name;
  final String instrument;
  // true → DB 查無此 EPC，以橘色標示
  final bool isUnknown;

  const FileDeviceEntry({
    required this.name,
    required this.instrument,
    this.isUnknown = false,
  });
}

Future<void> showFileViewerDialog(
  BuildContext context, {
  required String fileName,
  required List<FileDeviceEntry> devices,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    barrierDismissible: true,
    builder: (_) => FileViewerDialog(
      fileName: fileName,
      devices: devices,
      onEdit: onEdit,
      onDelete: onDelete,
    ),
  );
}
