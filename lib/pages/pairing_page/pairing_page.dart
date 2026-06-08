import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/core/app_text_style.dart';
import 'package:rf_example/providers/rfid_providers.dart';
import 'package:rf_example/widgets/feedback_toast.dart';

/// 配對裝置頁：連線狀態視覺化（含脈衝動畫）+ 單一 toggle 按鈕（連線 ↔ 斷線）
class PairingPage extends ConsumerWidget {
  const PairingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectState = ref.watch(effectiveConnectStateProvider);
    final status = ref.watch(deviceStatusProvider);
    final isConnecting = connectState == RfidConnectState.connecting;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text(
          '配對裝置',
          style: AppTextStyle.appBarTitle.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 連線狀態 Logo（含脈衝動畫）────────────────────────
            _ConnectionLogo(state: connectState),
            SizedBox(height: 28.h),

            // ── 標籤 ──────────────────────────────────────────────
            _SectionLabel(label: 'EventChannel', sublabel: '連線狀態'),
            SizedBox(height: 10.h),

            // ── 連線狀態卡 ───────────────────────────────────────
            _SectionCard(
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: connectState.color.withValues(alpha: 0.20),
                        ),
                      ),
                      Container(
                        width: 9.w,
                        height: 9.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: connectState.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    connectState.label,
                    style: AppTextStyle.medium18.copyWith(
                      color: connectState.color,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: connectState.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                    child: Text(
                      connectState.isConnected ? 'LIVE' : 'OFFLINE',
                      style: AppTextStyle.regular12.copyWith(
                        color: connectState.color,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ── 電池 / 溫度 標籤 ──────────────────────────────────
            _SectionLabel(label: 'EventChannel', sublabel: '裝置狀態'),
            SizedBox(height: 10.h),

            // ── 電池 / 溫度卡 ────────────────────────────────────
            _SectionCard(
              child: Column(
                children: [
                  _StatusItem(
                    icon: Icons.battery_charging_full_rounded,
                    label: '電池電量',
                    value: connectState.isConnected && status.battery != null
                        ? '${status.battery}%'
                        : '---',
                    color: connectState.isConnected
                        ? _batteryColor(status.battery)
                        : AppColors.textGreyIt,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: Divider(
                      height: 1,
                      color: AppColors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  _StatusItem(
                    icon: Icons.thermostat_rounded,
                    label: '裝置溫度',
                    value: connectState.isConnected && status.temperature != null
                        ? '${status.temperature!.toStringAsFixed(1)}°C'
                        : '---',
                    color: connectState.isConnected
                        ? AppColors.info
                        : AppColors.textGreyIt,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // ── 單一 Toggle 按鈕 ──────────────────────────────────
            _ActionButton(
              label: connectState.isConnected
                  ? '斷開連線'
                  : isConnecting
                      ? '連線中…'
                      : '建立連線',
              color: connectState.isConnected
                  ? AppColors.delete
                  : AppColors.primary,
              enabled: !isConnecting,
              isConnecting: isConnecting,
              onTap: () async {
                if (connectState.isConnected) {
                  await rfidDisconnect();
                } else {
                  ref
                      .read(connectInFlightProvider.notifier)
                      .setInFlight(true);
                  await Future.delayed(const Duration(milliseconds: 1500));
                  try {
                    await rfidConnectFlow();
                  } catch (e) {
                    if (context.mounted) {
                      showErrorToast(context, message: '連線失敗：$e');
                    }
                  } finally {
                    ref
                        .read(connectInFlightProvider.notifier)
                        .setInFlight(false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _batteryColor(int? battery) {
    if (battery == null) return AppColors.midGrey;
    if (battery > 50) return AppColors.green;
    if (battery > 20) return AppColors.secondary;
    return AppColors.delete;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connection Logo（含連線中脈衝動畫）
// ─────────────────────────────────────────────────────────────────────────────

class _ConnectionLogo extends StatefulWidget {
  final RfidConnectState state;
  const _ConnectionLogo({required this.state});

  @override
  State<_ConnectionLogo> createState() => _ConnectionLogoState();
}

class _ConnectionLogoState extends State<_ConnectionLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(_ConnectionLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.state == RfidConnectState.connecting) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isConnected = state.isConnected;
    final isConnecting = state == RfidConnectState.connecting;

    final glowColor = isConnected
        ? AppColors.green
        : isConnecting
            ? AppColors.info
            : AppColors.midGrey;

    final icon = isConnected
        ? Icons.bluetooth_connected_rounded
        : isConnecting
            ? Icons.bluetooth_searching_rounded
            : Icons.bluetooth_disabled_rounded;

    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) {
              final scale = _pulse.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // 最外圈光暈（脈衝）
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 136.w,
                      height: 136.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: glowColor.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  // 外圈（脈衝）
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 108.w,
                      height: 108.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: glowColor.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  // 中圈
                  Container(
                    width: 82.w,
                    height: 82.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glowColor.withValues(alpha: 0.18),
                    ),
                  ),
                  // 內圓 icon（不縮放）
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glowColor,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: AppColors.white, size: 30.w),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),
          Text(
            state.label,
            style: AppTextStyle.medium18.copyWith(color: glowColor),
          ),
          SizedBox(height: 4.h),
          Text(
            isConnected
                ? 'RFID 讀取器已就緒'
                : isConnecting
                    ? '正在建立連線中...'
                    : '請按下方按鈕連線',
            style: AppTextStyle.regular12.copyWith(
              color: AppColors.textGreyIt,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final String sublabel;

  const _SectionLabel({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Text(
            label,
            style: AppTextStyle.regular12.copyWith(
              color: AppColors.primaryLight,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          sublabel,
          style: AppTextStyle.medium16.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.deepGrey,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Icon(icon, color: color, size: 22.w),
        ),
        SizedBox(width: 14.w),
        Text(
          label,
          style: AppTextStyle.regular14.copyWith(color: AppColors.textGreyIt),
        ),
        const Spacer(),
        Text(value, style: AppTextStyle.medium24.copyWith(color: color)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool enabled;
  final bool isConnecting;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
    this.isConnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            gradient: enabled && !isConnecting
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withValues(alpha: 0.75),
                    ],
                  )
                : null,
            color: enabled && !isConnecting ? null : AppColors.deepGrey,
            borderRadius: BorderRadius.circular(14.w),
            boxShadow: enabled && !isConnecting
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
            border: enabled && !isConnecting
                ? null
                : Border.all(
                    color: AppColors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
          ),
          child: Center(
            child: isConnecting
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        label,
                        style: AppTextStyle.medium18.copyWith(
                          color: AppColors.textGreyIt,
                        ),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: AppTextStyle.medium18.copyWith(
                      color: enabled ? AppColors.white : AppColors.textGreyIt,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
