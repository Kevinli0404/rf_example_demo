// RFID channel 定義、連線狀態 enum、相關 provider。

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rf_example/core/app_colors.dart';

// Channel 名稱需與 Kotlin RfidPlugin.kt 的常數保持一致
const cmdChannel = MethodChannel('rfid_test/commands');
const stateChannel = EventChannel('rfid_test/connection_state');
const tagChannel = EventChannel('rfid_test/tag_read');
const statusChannel = EventChannel('rfid_test/device_status');

enum RfidConnectState {
  disconnected,
  connecting,
  connected,
  unknown;

  factory RfidConnectState.fromString(String s) {
    switch (s) {
      case 'Connected':
        return RfidConnectState.connected;
      case 'Connecting':
        return RfidConnectState.connecting;
      case 'Disconnected':
        return RfidConnectState.disconnected;
      default:
        return RfidConnectState.unknown;
    }
  }

  String get label {
    switch (this) {
      case RfidConnectState.connected:
        return '已連線';
      case RfidConnectState.connecting:
        return '連線中';
      case RfidConnectState.disconnected:
        return '未連線';
      case RfidConnectState.unknown:
        return '未知';
    }
  }

  Color get color {
    switch (this) {
      case RfidConnectState.connected:
        return AppColors.green;
      case RfidConnectState.connecting:
        return AppColors.info;
      case RfidConnectState.disconnected:
        return AppColors.delete;
      case RfidConnectState.unknown:
        return AppColors.midGrey;
    }
  }

  bool get isConnected => this == RfidConnectState.connected;
}

final connectStateProvider = StreamProvider<RfidConnectState>((ref) {
  return stateChannel.receiveBroadcastStream().map(
    (event) => RfidConnectState.fromString(event.toString()),
  );
});

/// 連線流程執行中旗標
class ConnectInFlightNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setInFlight(bool value) => state = value;
}

final connectInFlightProvider = NotifierProvider<ConnectInFlightNotifier, bool>(
  ConnectInFlightNotifier.new,
);

/// 連線狀態 provider，連線流程中強制顯示 connecting
final effectiveConnectStateProvider = Provider<RfidConnectState>((ref) {
  if (ref.watch(connectInFlightProvider)) {
    return RfidConnectState.connecting;
  }
  return ref.watch(connectStateProvider).value ?? RfidConnectState.disconnected;
});


class DeviceStatus {
  final int? battery;
  final double? temperature;
  const DeviceStatus({this.battery, this.temperature});

  DeviceStatus copyWith({int? battery, double? temperature}) => DeviceStatus(
    battery: battery ?? this.battery,
    temperature: temperature ?? this.temperature,
  );
}

class DeviceStatusNotifier extends Notifier<DeviceStatus> {
  StreamSubscription<dynamic>? _sub;

  @override
  DeviceStatus build() {
    _sub = statusChannel.receiveBroadcastStream().listen((event) {
      if (event is! Map) return;
      final type = event['type'] as String?;
      final value = event['value'];
      switch (type) {
        case 'battery':
          final v = (value as num?)?.toInt();
          if (v != null) state = state.copyWith(battery: v);
          break;
        case 'temperature':
          final v = (value as num?)?.toDouble();
          if (v != null) state = state.copyWith(temperature: v);
          break;
      }
    });
    ref.onDispose(() => _sub?.cancel());
    return const DeviceStatus();
  }
}

final deviceStatusProvider =
    NotifierProvider<DeviceStatusNotifier, DeviceStatus>(
      DeviceStatusNotifier.new,
    );

/// RFID 連線流程（initialize → connect）
class RfidConnectStepLog {
  final String step;
  final String? message;
  final bool ok;
  const RfidConnectStepLog(this.step, this.message, this.ok);
}

Future<List<RfidConnectStepLog>> rfidConnectFlow() async {
  final logs = <RfidConnectStepLog>[];

  // initialize
  try {
    final res = await cmdChannel.invokeMethod<String>('initialize');
    logs.add(RfidConnectStepLog('initialize', res, true));
  } on PlatformException catch (e) {
    logs.add(RfidConnectStepLog('initialize', '${e.code}: ${e.message}', false));
    rethrow;
  }

  // connect
  try {
    final res = await cmdChannel.invokeMethod<String>('connect');
    logs.add(RfidConnectStepLog('connect', res, true));
  } on PlatformException catch (e) {
    logs.add(RfidConnectStepLog('connect', '${e.code}: ${e.message}', false));
    rethrow;
  }

  return logs;
}

/// 斷線
Future<String?> rfidDisconnect() async {
  return cmdChannel.invokeMethod<String>('disconnect');
}

/// 觸發震動
void rfidVibrate({int durationMs = 100}) {
  // ignore: discarded_futures
  cmdChannel.invokeMethod<void>('vibrate', {'durationMs': durationMs});
}

/// 播放錯誤警示音
void rfidBeep({int durationMs = 200}) {
  // ignore: discarded_futures
  cmdChannel.invokeMethod<void>('beep', {'durationMs': durationMs});
}
