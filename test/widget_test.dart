// rf_example — App-level smoke test
//
// 驗證 MyApp 能夠在 ProviderScope 下正常渲染 HomePage，不 crash。
//
// 技術背景：
//   - effectiveConnectStateProvider 依賴 EventChannel（rfid_test/connection_state）
//   - 測試環境沒有原生層，直接 override 為靜態值，避免 MissingPluginException
//   - rfid_test/commands MethodChannel 用 mock handler 攔截（HomePage 的 auto-connect）

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rf_example/main.dart';
import 'package:rf_example/providers/rfid_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock MethodChannel — 攔截 rfidConnectFlow() / rfidDisconnect() 等呼叫
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('rfid_test/commands'),
      (call) async => null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('rfid_test/commands'),
      null,
    );
  });

  testWidgets('App smoke test — HomePage renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // connectStateProvider 依賴 EventChannel (rfid_test/connection_state)
          // 測試環境沒有原生層，覆寫為靜態 stream 避免 MissingPluginException
          // _autoConnect() 讀到 disconnected → 不執行實際連線
          connectStateProvider.overrideWith(
            (ref) => Stream.value(RfidConnectState.disconnected),
          ),
          // effectiveConnectStateProvider 直接給靜態值，StatusLight 不再往上追蹤 stream
          effectiveConnectStateProvider.overrideWith(
            (ref) => RfidConnectState.disconnected,
          ),
        ],
        child: const MyApp(),
      ),
    );

    // 讓 ScreenUtilInit + Riverpod 完成初始化
    await tester.pump();

    // HomePage logo 區的 'RFID' 文字應存在於 widget tree 中
    expect(find.text('RFID'), findsOneWidget);
  });
}
