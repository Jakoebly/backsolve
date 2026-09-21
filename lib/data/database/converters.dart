import 'dart:convert';

import 'package:backsolve_domain/backsolve_domain.dart';
import 'package:drift/drift.dart';

/// Stores a category's level history as a JSON array of
/// `{"at": "<ISO-8601>", "level": 3}` objects (data-model.md §2, R-05).
/// Entries are sorted ascending by `at` on read.
class LevelHistoryConverter extends TypeConverter<List<LevelChange>, String> {
  const LevelHistoryConverter();

  @override
  List<LevelChange> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    final history = [
      for (final entry in decoded.cast<Map<String, dynamic>>())
        LevelChange(
          at: DateTime.parse(entry['at'] as String),
          level: DifficultyLevel.fromNumber(entry['level'] as int),
        ),
    ]..sort((a, b) => a.at.compareTo(b.at));
    return List.unmodifiable(history);
  }

  @override
  String toSql(List<LevelChange> value) => jsonEncode([
    for (final change in value)
      {'at': change.at.toIso8601String(), 'level': change.level.number},
  ]);
}

/// Stores a list of strings (category ids) as a JSON array.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      List.unmodifiable((jsonDecode(fromDb) as List<dynamic>).cast<String>());

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
