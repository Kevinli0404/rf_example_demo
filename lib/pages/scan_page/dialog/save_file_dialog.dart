import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/core/app_text_style.dart';

/// 掃描結果儲存 dialog：可編輯檔名，驗證通過後回傳檔名；取消回傳 null
Future<String?> showSaveFileDialog(
  BuildContext context, {
  String? filenamePreview,
  Future<String?> Function(String filename)? validate,
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    barrierDismissible: false,
    builder: (_) => _SaveFileDialog(
      initialFilename: filenamePreview,
      validate: validate,
    ),
  );
}

class _SaveFileDialog extends StatefulWidget {
  final String? initialFilename;
  final Future<String?> Function(String filename)? validate;

  const _SaveFileDialog({this.initialFilename, this.validate});

  @override
  State<_SaveFileDialog> createState() => _SaveFileDialogState();
}

class _SaveFileDialogState extends State<_SaveFileDialog> {
  late final TextEditingController _textController;
  String? _errorMessage;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    final display = (widget.initialFilename ?? '')
        .replaceAll(RegExp(r'\.txt$', caseSensitive: false), '');
    _textController = TextEditingController(text: display);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _onSaveTap() async {
    final text = _textController.text.trim();

    if (widget.validate != null) {
      setState(() => _isValidating = true);
      final error = await widget.validate!(text);
      if (!mounted) return;
      setState(() => _isValidating = false);
      if (error != null) {
        setState(() => _errorMessage = error);
        return;
      }
    }

    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題列
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9.w),
                  ),
                  child: Icon(
                    Icons.save_rounded,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '儲存檔案',
                  style: AppTextStyle.medium18.copyWith(color: AppColors.white),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.of(context).pop(null);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.midGrey,
                    size: 22.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Divider(height: 1, color: AppColors.white.withValues(alpha: 0.08)),
            SizedBox(height: 16.h),

            // 檔名輸入
            Text(
              '檔案名稱',
              style: AppTextStyle.regular14.copyWith(color: AppColors.textGreyIt),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _textController,
              style: AppTextStyle.regular14.copyWith(color: AppColors.white),
              cursorColor: AppColors.primary,
              onChanged: (_) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.black.withValues(alpha: 0.4),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w),
                  borderSide: BorderSide(
                    color: hasError
                        ? AppColors.delete
                        : AppColors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.delete : AppColors.primary,
                    width: 1,
                  ),
                ),
                hintText: 'YYYY-MM-DD_HHmmss',
                hintStyle: AppTextStyle.regular14.copyWith(
                  color: AppColors.textGreyIt,
                ),
                suffixText: '.txt',
                suffixStyle: AppTextStyle.regular14.copyWith(
                  color: AppColors.textGreyIt,
                ),
                suffixIcon: hasError
                    ? Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.delete,
                          size: 20.w,
                        ),
                      )
                    : null,
                suffixIconConstraints: BoxConstraints(maxHeight: 44.h),
              ),
            ),

            // 錯誤訊息
            if (hasError) ...[
              SizedBox(height: 6.h),
              Text(
                _errorMessage!,
                style: AppTextStyle.regular12.copyWith(color: AppColors.delete),
              ),
            ],
            SizedBox(height: 20.h),

            // 按鈕列
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: '取消',
                    icon: Icons.close_rounded,
                    color: AppColors.midGrey,
                    bgColor: AppColors.black.withValues(alpha: 0.3),
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.of(context).pop(null);
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DialogButton(
                    label: _isValidating ? '驗證中...' : '儲存',
                    icon: Icons.save_rounded,
                    color: AppColors.white,
                    bgColor: AppColors.primary,
                    loading: _isValidating,
                    onTap: _isValidating ? null : _onSaveTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool loading;
  final VoidCallback? onTap;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(icon, color: color, size: 18.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyle.medium16.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
