import 'package:flutter/material.dart';

/// 搜尋關鍵字管理，支援中文 IME
class SearchKeywordController extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  String _keyword = '';

  String get keyword => _keyword;
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

  void clear() => textController.clear();

  // 任一欄位包含 keyword 即回傳 true
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
