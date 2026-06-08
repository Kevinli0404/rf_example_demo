import 'package:flutter/material.dart';

/// 搜尋關鍵字管理，整合 [TextEditingController] 並處理中文 IME 組字期間不觸發 rebuild
class SearchKeywordController extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  String _keyword = '';

  /// 當前已確認的搜尋關鍵字（空字串表示無搜尋條件）
  String get keyword => _keyword;

  /// 是否有有效的搜尋條件（用來切換搜尋框右側 icon × / 放大鏡）
  bool get hasKeyword => _keyword.isNotEmpty;

  SearchKeywordController() {
    textController.addListener(_onTextChange);
  }

  void _onTextChange() {
    final value = textController.value;

    // 組字進行中（尚未確認）先不更新，避免中斷 IME 選字
    if (value.composing.isValid && !value.composing.isCollapsed) return;

    final newKeyword = value.text.trim();
    if (newKeyword == _keyword) return;

    _keyword = newKeyword;
    notifyListeners();
  }

  /// 清空輸入框（會走 listener 把 keyword 也歸零）
  void clear() => textController.clear();

  /// 任一欄位包含 keyword（大小寫不分）即回傳 true，keyword 為空則全部顯示
  bool matchesAny(Iterable<String> fields) {
    if (_keyword.isEmpty) return true;
    final k = _keyword.toLowerCase();
    return fields.any((f) => f.toLowerCase().contains(k));
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChange);
    textController.dispose();
    super.dispose();
  }
}
