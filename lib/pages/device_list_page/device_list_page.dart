import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/core/app_text_style.dart';
import 'package:rf_example/core/search_keyword_controller.dart';
import 'package:rf_example/data/models/device.dart';
import 'package:rf_example/providers/app_providers.dart';
import 'package:rf_example/viewmodels/device_list_viewmodel.dart';
import 'package:rf_example/widgets/feedback_toast.dart';

/// 設備清單頁：從 JSON 匯入設備資料至本地 DB，支援搜尋與清空
class DeviceListPage extends ConsumerStatefulWidget {
  const DeviceListPage({super.key});

  @override
  ConsumerState<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends ConsumerState<DeviceListPage> {
  final _search = SearchKeywordController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ─── 匯入 ──────────────────────────────────────────────────────────────────

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
    );

    if (result == null || result.files.single.path == null) return; // 使用者取消

    final file = File(result.files.single.path!);
    final outcome = await ref
        .read(deviceListViewModelProvider.notifier)
        .importFromFile(file);

    if (!mounted) return;

    if (outcome.isSuccess) {
      showSuccessToast(context, message: '匯入成功：${outcome.importedCount} 筆設備');
    } else if (outcome.isError) {
      showErrorToast(context, message: outcome.errorMessage ?? '匯入失敗');
    }
  }

  // ─── 清空確認 ───────────────────────────────────────────────────────────────

  Future<void> _confirmClear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.deepGrey,
            title: Text('清空設備清單', style: AppTextStyle.medium16),
            content: Text('確定要清空所有設備資料嗎？', style: AppTextStyle.regular14),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('確定', style: TextStyle(color: AppColors.delete)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      ref.read(deviceListViewModelProvider.notifier).clearAll();
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(deviceListViewModelProvider);
    final allDevices = vmState.devices;

    final canDelete = allDevices.isNotEmpty && !vmState.isImporting;
    final canImport = !vmState.isImporting;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text(
          '同步設備',
          style: AppTextStyle.appBarTitle.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border(
            top: BorderSide(
              color: AppColors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Row(
              children: [
                // ── 清空按鈕 ──────────────────────────────────────────
                Expanded(
                  child: _BottomButton(
                    label: '清空資料',
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.delete,
                    enabled: canDelete,
                    onTap: _confirmClear,
                  ),
                ),
                SizedBox(width: 12.w),
                // ── 匯入按鈕 ──────────────────────────────────────────
                Expanded(
                  child: _BottomButton(
                    label: vmState.isImporting ? '匯入中…' : '匯入 JSON',
                    icon: Icons.upload_file_rounded,
                    color: AppColors.primary,
                    enabled: canImport,
                    loading: vmState.isImporting,
                    onTap: _pickAndImport,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListenableBuilder(
            listenable: _search,
            builder: (context, _) {
              final filtered =
                  allDevices
                      .where(
                        (d) => _search.matchesAny([d.label, d.serialCode]),
                      )
                      .toList();

              return Column(
                children: [
                  SizedBox(height: 14.h),
                  _buildSearchBar(),
                  SizedBox(height: 12.h),
                  _buildCountRow(vmState, filtered.length),
                  SizedBox(height: 12.h),
                  if (vmState.isImporting)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 48.w,
                              height: 48.w,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              '正在匯入...',
                              style: AppTextStyle.regular14.copyWith(
                                color: AppColors.textGreyIt,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (allDevices.isEmpty) ...[
                    const Spacer(),
                    _buildEmptyCard(),
                    const Spacer(),
                  ] else
                    Expanded(
                      child: _buildFilledCard(filtered),
                    ),
                  SizedBox(height: 8.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── 搜尋欄 ──────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.deepGrey,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textGreyIt, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _search.textController,
              style: AppTextStyle.regular14.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: '搜尋名稱 / 儀器編號',
                hintStyle: AppTextStyle.regular14.copyWith(
                  color: AppColors.textGreyIt,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_search.hasKeyword)
            GestureDetector(
              onTap: _search.clear,
              behavior: HitTestBehavior.opaque,
              child: Icon(Icons.close_rounded, color: AppColors.midGrey, size: 18.w),
            ),
        ],
      ),
    );
  }

  // ─── 計數列 ───────────────────────────────────────────────────────────────

  Widget _buildCountRow(DeviceListState state, int filteredCount) {
    return Row(
      children: [
        if (state.exportTime != null) ...[
          Icon(Icons.access_time_rounded, size: 13.w, color: AppColors.textGreyIt),
          SizedBox(width: 5.w),
          Text(
            _formatDate(state.exportTime!),
            style: AppTextStyle.regular12.copyWith(color: AppColors.textGreyIt),
          ),
        ],
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Text(
            '$filteredCount 筆設備',
            style: AppTextStyle.regular12.copyWith(color: AppColors.primaryLight),
          ),
        ),
      ],
    );
  }

  // ─── 空狀態 ───────────────────────────────────────────────────────────────

  Widget _buildEmptyCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.deepGrey,
              borderRadius: BorderRadius.circular(20.w),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 38.w,
              color: AppColors.textGreyIt,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            '尚無設備資料',
            style: AppTextStyle.medium18.copyWith(color: AppColors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            '按下方「匯入 JSON」選擇設備清單檔案',
            style: AppTextStyle.regular12.copyWith(color: AppColors.textGreyIt),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── 卡片清單 ─────────────────────────────────────────────────────────────

  Widget _buildFilledCard(List<Device> devices) {
    if (devices.isEmpty) {
      return Center(
        child: Text(
          '找不到符合的設備',
          style: AppTextStyle.regular14.copyWith(color: AppColors.textGreyIt),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 8.h),
      itemCount: devices.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (_, i) => _buildDeviceCard(i + 1, devices[i]),
    );
  }

  Widget _buildDeviceCard(int no, Device d) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.deepGrey,
        borderRadius: BorderRadius.circular(14.w),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ── 序號圓圈 ────────────────────────────────────────────
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                no.toString().padLeft(2, '0'),
                style: AppTextStyle.medium16.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          // ── 設備資訊 ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.label,
                  style: AppTextStyle.medium16.copyWith(color: AppColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Text(
                      '儀器編號',
                      style: AppTextStyle.regular12.copyWith(
                        color: AppColors.textGreyIt,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        d.serialCode,
                        style: AppTextStyle.regular12.copyWith(
                          color: AppColors.midGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 右側箭頭裝飾
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textGreyIt,
            size: 20.w,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}/${two(local.month)}/${two(local.day)}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom action button
// ─────────────────────────────────────────────────────────────────────────────

class _BottomButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _BottomButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = enabled && color == AppColors.primary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isPrimary
              ? null
              : enabled
                  ? color.withValues(alpha: 0.12)
                  : AppColors.deepGrey,
          borderRadius: BorderRadius.circular(12.w),
          border: isPrimary
              ? null
              : Border.all(
                  color: enabled
                      ? color.withValues(alpha: 0.5)
                      : AppColors.white.withValues(alpha: 0.10),
                  width: 1,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            else
              Icon(
                icon,
                color: enabled ? (isPrimary ? AppColors.white : color) : AppColors.textGreyIt,
                size: 20.w,
              ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyle.medium16.copyWith(
                color: enabled
                    ? (isPrimary ? AppColors.white : color)
                    : AppColors.textGreyIt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
