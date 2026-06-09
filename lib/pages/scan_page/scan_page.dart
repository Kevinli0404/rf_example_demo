import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/core/app_text_style.dart';
import 'package:rf_example/core/epc_rules.dart';
import 'package:rf_example/core/search_keyword_controller.dart';
import 'package:rf_example/data/models/device.dart';
import 'package:rf_example/data/services/scan_export_service.dart';
import 'package:rf_example/providers/app_providers.dart';
import 'package:rf_example/providers/rfid_providers.dart';
import 'package:rf_example/pages/scan_page/dialog/save_file_dialog.dart';
import 'package:rf_example/widgets/feedback_toast.dart';
import 'package:rf_example/pages/scan_page/scan_session_controller.dart';

/// 掃描頁：模擬 RFID 掃描流程，支援搜尋過濾與掃描結果匯出
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  late final ScanSessionController _controller;
  final _search = SearchKeywordController();

  @override
  void initState() {
    super.initState();
    final repo = ref.read(deviceRepositoryProvider);

    _controller = ScanSessionController(
      repository: repo,
      isConnected: () =>
          ref.read(connectStateProvider).value?.isConnected ?? false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text(
          '掃描',
          style: AppTextStyle.appBarTitle.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_controller, _search]),
        builder: (context, _) {
          final allDevices = _controller.scannedDevices;
          final filtered =
              allDevices
                  .where(
                    (d) => _search.matchesAny([d.label, d.serialCode]),
                  )
                  .toList();

          return Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.deepGrey.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14.w),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildStatusBar(),
                    SizedBox(height: 8.h),
                    _buildSearchBar(),
                  ],
                ),
              ),
              Expanded(child: _buildDeviceList(filtered)),
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  // ── 頂部狀態列 ──────────────────────────────────────────────────────────

  Widget _buildStatusBar() {
    final connectState =
        ref.watch(connectStateProvider).value ?? RfidConnectState.disconnected;
    final count = _controller.totalCount;
    final scanning = _controller.scanning;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.deepGrey,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 連線狀態
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: connectState.color.withValues(alpha: 0.22),
                    ),
                  ),
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: connectState.color,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8.w),
              Text(
                connectState.label,
                style: AppTextStyle.regular14.copyWith(color: AppColors.white),
              ),
            ],
          ),
          // 掃描計數
          Row(
            children: [
              if (scanning) ...[
                SizedBox(
                  width: 13.w,
                  height: 13.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                '已掃描　',
                style: AppTextStyle.regular12.copyWith(
                  color: AppColors.textGreyIt,
                ),
              ),
              Text(
                '$count',
                style: AppTextStyle.medium16.copyWith(
                  color: scanning ? AppColors.primary : AppColors.white,
                ),
              ),
              Text(
                '　筆',
                style: AppTextStyle.regular12.copyWith(
                  color: AppColors.textGreyIt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 搜尋欄 ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.deepGrey,
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18.w, color: AppColors.textGreyIt),
          SizedBox(width: 8.w),
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
              child: Icon(Icons.close, color: AppColors.midGrey, size: 18.w),
            ),
        ],
      ),
    );
  }

  // ── 設備清單 ─────────────────────────────────────────────────────────────

  Widget _buildDeviceList(List<Device> devices) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.deepGrey,
                borderRadius: BorderRadius.circular(18.w),
              ),
              child: Icon(
                Icons.sensors_off_outlined,
                size: 36.w,
                color: AppColors.textGreyIt,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _controller.totalCount == 0 ? '尚無掃描紀錄' : '無符合搜尋條件的設備',
              style: AppTextStyle.medium16.copyWith(color: AppColors.white),
            ),
            SizedBox(height: 6.h),
            Text(
              _controller.totalCount == 0
                  ? '按下方按鈕開始掃描 RFID 標籤'
                  : '請嘗試其他關鍵字',
              style: AppTextStyle.regular12.copyWith(color: AppColors.textGreyIt),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      itemCount: devices.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) => _buildDeviceCard(devices[index], index),
    );
  }

  Widget _buildDeviceCard(Device device, int index) {
    final isUnknown = isUnknownDeviceId(device.uid);
    final accentColor = isUnknown ? AppColors.secondary : AppColors.primary;
    final epcShort = device.epc.length > 12
        ? '${device.epc.substring(0, 12)}…'
        : device.epc;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.deepGrey,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: isUnknown
              ? AppColors.secondary.withValues(alpha: 0.45)
              : AppColors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 序號圓圈
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyle.regular12.copyWith(color: accentColor),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // 設備資訊
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.label,
                  style: AppTextStyle.medium14.copyWith(
                    color: isUnknown ? AppColors.secondary : AppColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  device.serialCode,
                  style: AppTextStyle.regular12.copyWith(
                    color: AppColors.textGreyIt,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // EPC chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Text(
              epcShort,
              style: AppTextStyle.regular11.copyWith(
                color: AppColors.textGreyIt,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 底部按鈕列 ───────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final scanning = _controller.scanning;
    final toggling = _controller.toggling;
    final hasItems = _controller.totalCount > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border(
            top: BorderSide(
              color: AppColors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 清空按鈕
            if (hasItems && !scanning) ...[
              _buildIconButton(
                icon: Icons.delete_outline_rounded,
                color: AppColors.delete,
                onTap: _controller.clearAll,
              ),
              SizedBox(width: 10.w),
            ],
            // 匯出按鈕
            if (hasItems && !scanning) ...[
              _buildIconButton(
                icon: Icons.ios_share_rounded,
                color: AppColors.info,
                onTap: _export,
              ),
              SizedBox(width: 10.w),
            ],
            // 開始 / 停止按鈕
            Expanded(
              child: GestureDetector(
                onTap: toggling
                    ? null
                    : () async {
                        final err = await _controller.toggleScan();
                        if (err != null && mounted) {
                          showErrorToast(context, message: err);
                        }
                      },
                child: Container(
                  height: 54.h,
                  decoration: BoxDecoration(
                    gradient: scanning
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight.withValues(alpha: 0.8),
                            ],
                          ),
                    color: scanning ? AppColors.delete : null,
                    borderRadius: BorderRadius.circular(12.w),
                    boxShadow: scanning
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: toggling
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                scanning
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.white,
                                size: 22.w,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                scanning ? '停止掃描' : '開始掃描',
                                style: AppTextStyle.medium16.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 匯出 ─────────────────────────────────────────────────────────────────

  Future<void> _export() async {
    final devices = _controller.scannedDevices;
    if (devices.isEmpty) return;

    // 產生預設檔名供 dialog 顯示
    final preview = await ScanExportService.previewFilename();
    if (!mounted) return;

    // 顯示儲存 dialog，使用者可編輯檔名，驗證通過後才關閉
    final chosenFilename = await showSaveFileDialog(
      context,
      filenamePreview: preview,
      validate: ScanExportService.validateFilenameOnly,
    );
    if (chosenFilename == null) return; // 使用者取消
    if (!mounted) return;

    final savedPath = await ScanExportService.saveToExternalDir(
      devices: devices,
      scanTimes: _controller.scanTimes,
      preferredFilename: chosenFilename,
    );

    if (!mounted) return;

    if (savedPath != null) {
      showSuccessToast(context, message: '已儲存');
    } else {
      // 寫檔失敗（模擬器 / 無外部儲存）→ fallback 顯示 JSON
      _showJsonDialog(ScanExportService.buildJsonString(
        devices: devices,
        scanTimes: _controller.scanTimes,
      ));
    }
  }

  void _showJsonDialog(String json) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.deepGrey,
            title: Row(
              children: [
                Expanded(
                  child: Text('掃描結果 JSON', style: AppTextStyle.medium16),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 20.w, color: AppColors.midGrey),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: json));
                    showSuccessToast(
                      context,
                      message: '已複製到剪貼簿',
                      duration: const Duration(seconds: 1),
                    );
                  },
                  tooltip: '複製',
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 320.h,
              child: SingleChildScrollView(
                child: SelectableText(
                  json,
                  style: AppTextStyle.regular12.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.midGrey,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('關閉'),
              ),
            ],
          ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54.h,
        height: 54.h,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        ),
        child: Icon(icon, color: color, size: 22.w),
      ),
    );
  }
}
