import 'session_config.dart';
import 'session_result.dart';

/// One persisted practice run (FR-028).
final class Session {
  const Session({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.config,
    required this.result,
  });

  /// Storage-assigned id.
  final int id;

  /// Local start time; every weekly and daily bucketing keys on this
  /// (FR-033, FR-034).
  final DateTime startedAt;

  /// `null` while unfinished.
  final DateTime? endedAt;

  final SessionConfig config;

  /// `null` while unfinished.
  final SessionResult? result;

  /// Whether the session has finished with an outcome.
  bool get isCompleted => endedAt != null && result != null;

  Session copyWith({
    int? id,
    DateTime? startedAt,
    DateTime? endedAt,
    SessionConfig? config,
    SessionResult? result,
  }) {
    return Session(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      config: config ?? this.config,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          other.id == id &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.config == config &&
          other.result == result;

  @override
  int get hashCode => Object.hash(id, startedAt, endedAt, config, result);

  @override
  String toString() =>
      'Session(id: $id, startedAt: $startedAt, endedAt: $endedAt, '
      'config: $config, result: $result)';
}
