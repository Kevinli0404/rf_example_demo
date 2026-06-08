class EpcRules {
  final List<String> prefixes;
  const EpcRules(this.prefixes);

  static const EpcRules empty = EpcRules([]);
  static const EpcRules defaults = EpcRules(['E280', '1234', '5741']);

  bool matches(String epc) {
    if (prefixes.isEmpty) return false;
    final upper = epc.toUpperCase();
    for (final p in prefixes) {
      if (p.isEmpty) continue;
      if (upper.startsWith(p)) return true;
    }
    return false;
  }

  factory EpcRules.fromString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return empty;
    final parts = raw
        .split(RegExp(r'[,\r\n]'))
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toList();
    return EpcRules(parts);
  }

  String toStorageString() => prefixes.join('\n');
}

const String kUnknownDeviceIdPrefix = '__unknown_';
bool isUnknownDeviceId(String id) => id.startsWith(kUnknownDeviceIdPrefix);
