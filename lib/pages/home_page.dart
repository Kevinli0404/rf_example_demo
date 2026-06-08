import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/core/app_text_style.dart';
import 'package:rf_example/pages/check_file_page/check_file_page.dart';
import 'package:rf_example/pages/device_list_page/device_list_page.dart';
import 'package:rf_example/pages/pairing_page/pairing_page.dart';
import 'package:rf_example/pages/scan_page/scan_page.dart';
import 'package:rf_example/providers/rfid_providers.dart';
import 'package:rf_example/widgets/status_light.dart';

/// 首頁：2×2 功能按鈕 + 冷啟動自動連線
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static bool _didAutoConnect = false;

  @override
  void initState() {
    super.initState();
    if (!_didAutoConnect) {
      _didAutoConnect = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _autoConnect();
      });
    }
  }

  Future<void> _autoConnect() async {
    final current = ref.read(connectStateProvider).value;
    if (current == RfidConnectState.connected) return;

    ref.read(connectInFlightProvider.notifier).setInFlight(true);
    try {
      await rfidConnectFlow();
    } catch (_) {
    } finally {
      if (mounted) {
        try {
          ref.read(connectInFlightProvider.notifier).setInFlight(false);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        toolbarHeight: 50.h,
        actions: const [StatusLight()],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 8.h + 30),
              _buildLogoArea(),
              SizedBox(height: 44.h),
              _buildButtonGrid(context),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logo 區 ────────────────────────────────────────────────────────────────

  Widget _buildLogoArea() {
    final iconSize = 88.w.clamp(72.0, 120.0);
    return Column(
      children: [
        // 長按 logo 觸發 Crashlytics 測試崩潰（僅供驗證上報流程）
        GestureDetector(
          onLongPress: () => FirebaseCrashlytics.instance.crash(),
        child: Container(
          width: iconSize * 1.45,
          height: iconSize * 1.45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.20),
                AppColors.primary.withValues(alpha: 0.06),
                AppColors.transparent,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: Center(
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(iconSize * 0.28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.sensors, color: AppColors.white, size: 42.w),
            ),
          ),
        ),
        ), // GestureDetector
        SizedBox(height: 16.h),
        Text(
          'RFID',
          style: AppTextStyle.homeTitle.copyWith(
            color: AppColors.white,
            letterSpacing: 6,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Asset Management System',
          style: AppTextStyle.regular12.copyWith(
            color: AppColors.textGreyIt,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  // ── 2×2 按鈕格 ───────────────────────────────────────────────────────────

  Widget _buildButtonGrid(BuildContext context) {
    const gap = 14.0;
    final size = (342.w - gap.w) / 2;

    return SizedBox(
      width: 342.w,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPrimaryButton(
                label: '開始掃描',
                sublabel: 'Scan',
                icon: Icons.sensors,
                size: size,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanPage()),
                ),
              ),
              _buildSecondaryButton(
                label: '配對裝置',
                sublabel: 'Pairing',
                icon: Icons.bluetooth_searching,
                size: size,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PairingPage()),
                ),
              ),
            ],
          ),
          SizedBox(height: gap.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSecondaryButton(
                label: '同步設備',
                sublabel: 'Devices',
                icon: Icons.sync_alt,
                size: size,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceListPage()),
                ),
              ),
              _buildSecondaryButton(
                label: '查看檔案',
                sublabel: 'Files',
                icon: Icons.folder_open_rounded,
                size: size,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckFilePage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 主要按鈕（紫色漸層，帶 glow）
  Widget _buildPrimaryButton({
    required String label,
    required String sublabel,
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.40),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 右上角裝飾圓
            Positioned(
              top: -14.w,
              right: -14.w,
              child: Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            // 內容
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Icon(icon, size: 26.w, color: AppColors.white),
                  ),
                  const Spacer(),
                  Text(
                    label,
                    style: AppTextStyle.medium18.copyWith(color: AppColors.white),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    sublabel,
                    style: AppTextStyle.regular12.copyWith(
                      color: AppColors.white.withValues(alpha: 0.65),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 次要按鈕（深灰卡片，帶細邊框）
  Widget _buildSecondaryButton({
    required String label,
    required String sublabel,
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.deepGrey,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // 右上角裝飾圓
            Positioned(
              top: -12.w,
              right: -12.w,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.07),
                ),
              ),
            ),
            // 內容
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Icon(icon, size: 26.w, color: AppColors.primary),
                  ),
                  const Spacer(),
                  Text(
                    label,
                    style: AppTextStyle.medium18.copyWith(color: AppColors.white),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    sublabel,
                    style: AppTextStyle.regular12.copyWith(
                      color: AppColors.textGreyIt,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
