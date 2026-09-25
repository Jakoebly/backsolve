// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    check: () => ComparableExpr(level).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    check: () => ComparableExpr(accuracy).isBetweenValues(0, 100),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgAnswerSecondsMeta = const VerificationMeta(
    'avgAnswerSeconds',
  );
  @override
  late final GeneratedColumn<double> avgAnswerSeconds = GeneratedColumn<double>(
    'avg_answer_seconds',
    aliasedName,
    false,
    check: () => ComparableExpr(avgAnswerSeconds).isBiggerThanValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<LevelChange>, String>
  levelHistory = GeneratedColumn<String>(
    'level_history',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<LevelChange>>($CategoriesTable.$converterlevelHistory);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    displayOrder,
    level,
    accuracy,
    avgAnswerSeconds,
    levelHistory,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('avg_answer_seconds')) {
      context.handle(
        _avgAnswerSecondsMeta,
        avgAnswerSeconds.isAcceptableOrUnknown(
          data['avg_answer_seconds']!,
          _avgAnswerSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgAnswerSecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      avgAnswerSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_answer_seconds'],
      )!,
      levelHistory: $CategoriesTable.$converterlevelHistory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}level_history'],
        )!,
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<LevelChange>, String> $converterlevelHistory =
      const LevelHistoryConverter();
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final int displayOrder;
  final int level;
  final double accuracy;
  final double avgAnswerSeconds;
  final List<LevelChange> levelHistory;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.level,
    required this.accuracy,
    required this.avgAnswerSeconds,
    required this.levelHistory,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['display_order'] = Variable<int>(displayOrder);
    map['level'] = Variable<int>(level);
    map['accuracy'] = Variable<double>(accuracy);
    map['avg_answer_seconds'] = Variable<double>(avgAnswerSeconds);
    {
      map['level_history'] = Variable<String>(
        $CategoriesTable.$converterlevelHistory.toSql(levelHistory),
      );
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      displayOrder: Value(displayOrder),
      level: Value(level),
      accuracy: Value(accuracy),
      avgAnswerSeconds: Value(avgAnswerSeconds),
      levelHistory: Value(levelHistory),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      level: serializer.fromJson<int>(json['level']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      avgAnswerSeconds: serializer.fromJson<double>(json['avgAnswerSeconds']),
      levelHistory: serializer.fromJson<List<LevelChange>>(
        json['levelHistory'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'level': serializer.toJson<int>(level),
      'accuracy': serializer.toJson<double>(accuracy),
      'avgAnswerSeconds': serializer.toJson<double>(avgAnswerSeconds),
      'levelHistory': serializer.toJson<List<LevelChange>>(levelHistory),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    int? displayOrder,
    int? level,
    double? accuracy,
    double? avgAnswerSeconds,
    List<LevelChange>? levelHistory,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    displayOrder: displayOrder ?? this.displayOrder,
    level: level ?? this.level,
    accuracy: accuracy ?? this.accuracy,
    avgAnswerSeconds: avgAnswerSeconds ?? this.avgAnswerSeconds,
    levelHistory: levelHistory ?? this.levelHistory,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      level: data.level.present ? data.level.value : this.level,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      avgAnswerSeconds: data.avgAnswerSeconds.present
          ? data.avgAnswerSeconds.value
          : this.avgAnswerSeconds,
      levelHistory: data.levelHistory.present
          ? data.levelHistory.value
          : this.levelHistory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('level: $level, ')
          ..write('accuracy: $accuracy, ')
          ..write('avgAnswerSeconds: $avgAnswerSeconds, ')
          ..write('levelHistory: $levelHistory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    displayOrder,
    level,
    accuracy,
    avgAnswerSeconds,
    levelHistory,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayOrder == this.displayOrder &&
          other.level == this.level &&
          other.accuracy == this.accuracy &&
          other.avgAnswerSeconds == this.avgAnswerSeconds &&
          other.levelHistory == this.levelHistory);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> displayOrder;
  final Value<int> level;
  final Value<double> accuracy;
  final Value<double> avgAnswerSeconds;
  final Value<List<LevelChange>> levelHistory;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.level = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.avgAnswerSeconds = const Value.absent(),
    this.levelHistory = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int displayOrder,
    required int level,
    required double accuracy,
    required double avgAnswerSeconds,
    required List<LevelChange> levelHistory,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       displayOrder = Value(displayOrder),
       level = Value(level),
       accuracy = Value(accuracy),
       avgAnswerSeconds = Value(avgAnswerSeconds),
       levelHistory = Value(levelHistory);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? displayOrder,
    Expression<int>? level,
    Expression<double>? accuracy,
    Expression<double>? avgAnswerSeconds,
    Expression<String>? levelHistory,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayOrder != null) 'display_order': displayOrder,
      if (level != null) 'level': level,
      if (accuracy != null) 'accuracy': accuracy,
      if (avgAnswerSeconds != null) 'avg_answer_seconds': avgAnswerSeconds,
      if (levelHistory != null) 'level_history': levelHistory,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? displayOrder,
    Value<int>? level,
    Value<double>? accuracy,
    Value<double>? avgAnswerSeconds,
    Value<List<LevelChange>>? levelHistory,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      level: level ?? this.level,
      accuracy: accuracy ?? this.accuracy,
      avgAnswerSeconds: avgAnswerSeconds ?? this.avgAnswerSeconds,
      levelHistory: levelHistory ?? this.levelHistory,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (avgAnswerSeconds.present) {
      map['avg_answer_seconds'] = Variable<double>(avgAnswerSeconds.value);
    }
    if (levelHistory.present) {
      map['level_history'] = Variable<String>(
        $CategoriesTable.$converterlevelHistory.toSql(levelHistory.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('level: $level, ')
          ..write('accuracy: $accuracy, ')
          ..write('avgAnswerSeconds: $avgAnswerSeconds, ')
          ..write('levelHistory: $levelHistory, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionType, String> sessionType =
      GeneratedColumn<String>(
        'session_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionType>($SessionsTable.$convertersessionType);
  static const VerificationMeta _difficultyLevelMeta = const VerificationMeta(
    'difficultyLevel',
  );
  @override
  late final GeneratedColumn<int> difficultyLevel = GeneratedColumn<int>(
    'difficulty_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adaptiveStartLevelMeta =
      const VerificationMeta('adaptiveStartLevel');
  @override
  late final GeneratedColumn<int> adaptiveStartLevel = GeneratedColumn<int>(
    'adaptive_start_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AnswerMode, String> answerMode =
      GeneratedColumn<String>(
        'answer_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AnswerMode>($SessionsTable.$converteranswerMode);
  @override
  late final GeneratedColumnWithTypeConverter<PresetKind, String> presetKind =
      GeneratedColumn<String>(
        'preset_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PresetKind>($SessionsTable.$converterpresetKind);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  categoryIds = GeneratedColumn<String>(
    'category_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($SessionsTable.$convertercategoryIds);
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgAnswerSecondsMeta = const VerificationMeta(
    'avgAnswerSeconds',
  );
  @override
  late final GeneratedColumn<double> avgAnswerSeconds = GeneratedColumn<double>(
    'avg_answer_seconds',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionCountMeta = const VerificationMeta(
    'questionCount',
  );
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
    'question_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    sessionType,
    difficultyLevel,
    adaptiveStartLevel,
    answerMode,
    presetKind,
    categoryIds,
    accuracy,
    avgAnswerSeconds,
    questionCount,
    correctCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('difficulty_level')) {
      context.handle(
        _difficultyLevelMeta,
        difficultyLevel.isAcceptableOrUnknown(
          data['difficulty_level']!,
          _difficultyLevelMeta,
        ),
      );
    }
    if (data.containsKey('adaptive_start_level')) {
      context.handle(
        _adaptiveStartLevelMeta,
        adaptiveStartLevel.isAcceptableOrUnknown(
          data['adaptive_start_level']!,
          _adaptiveStartLevelMeta,
        ),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('avg_answer_seconds')) {
      context.handle(
        _avgAnswerSecondsMeta,
        avgAnswerSeconds.isAcceptableOrUnknown(
          data['avg_answer_seconds']!,
          _avgAnswerSecondsMeta,
        ),
      );
    }
    if (data.containsKey('question_count')) {
      context.handle(
        _questionCountMeta,
        questionCount.isAcceptableOrUnknown(
          data['question_count']!,
          _questionCountMeta,
        ),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      sessionType: $SessionsTable.$convertersessionType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}session_type'],
        )!,
      ),
      difficultyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty_level'],
      ),
      adaptiveStartLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adaptive_start_level'],
      ),
      answerMode: $SessionsTable.$converteranswerMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}answer_mode'],
        )!,
      ),
      presetKind: $SessionsTable.$converterpresetKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preset_kind'],
        )!,
      ),
      categoryIds: $SessionsTable.$convertercategoryIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category_ids'],
        )!,
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      avgAnswerSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_answer_seconds'],
      ),
      questionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_count'],
      ),
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionType, String, String> $convertersessionType =
      const EnumNameConverter<SessionType>(SessionType.values);
  static JsonTypeConverter2<AnswerMode, String, String> $converteranswerMode =
      const EnumNameConverter<AnswerMode>(AnswerMode.values);
  static JsonTypeConverter2<PresetKind, String, String> $converterpresetKind =
      const EnumNameConverter<PresetKind>(PresetKind.values);
  static TypeConverter<List<String>, String> $convertercategoryIds =
      const StringListConverter();
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final SessionType sessionType;

  /// `NULL` = adaptive, 1–5 = fixed level.
  final int? difficultyLevel;

  /// Set only when adaptive: the L{N} shown in the helper text at start.
  final int? adaptiveStartLevel;
  final AnswerMode answerMode;
  final PresetKind presetKind;
  final List<String> categoryIds;
  final double? accuracy;
  final double? avgAnswerSeconds;
  final int? questionCount;
  final int? correctCount;
  const SessionRow({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.sessionType,
    this.difficultyLevel,
    this.adaptiveStartLevel,
    required this.answerMode,
    required this.presetKind,
    required this.categoryIds,
    this.accuracy,
    this.avgAnswerSeconds,
    this.questionCount,
    this.correctCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    {
      map['session_type'] = Variable<String>(
        $SessionsTable.$convertersessionType.toSql(sessionType),
      );
    }
    if (!nullToAbsent || difficultyLevel != null) {
      map['difficulty_level'] = Variable<int>(difficultyLevel);
    }
    if (!nullToAbsent || adaptiveStartLevel != null) {
      map['adaptive_start_level'] = Variable<int>(adaptiveStartLevel);
    }
    {
      map['answer_mode'] = Variable<String>(
        $SessionsTable.$converteranswerMode.toSql(answerMode),
      );
    }
    {
      map['preset_kind'] = Variable<String>(
        $SessionsTable.$converterpresetKind.toSql(presetKind),
      );
    }
    {
      map['category_ids'] = Variable<String>(
        $SessionsTable.$convertercategoryIds.toSql(categoryIds),
      );
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || avgAnswerSeconds != null) {
      map['avg_answer_seconds'] = Variable<double>(avgAnswerSeconds);
    }
    if (!nullToAbsent || questionCount != null) {
      map['question_count'] = Variable<int>(questionCount);
    }
    if (!nullToAbsent || correctCount != null) {
      map['correct_count'] = Variable<int>(correctCount);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      sessionType: Value(sessionType),
      difficultyLevel: difficultyLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(difficultyLevel),
      adaptiveStartLevel: adaptiveStartLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(adaptiveStartLevel),
      answerMode: Value(answerMode),
      presetKind: Value(presetKind),
      categoryIds: Value(categoryIds),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      avgAnswerSeconds: avgAnswerSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(avgAnswerSeconds),
      questionCount: questionCount == null && nullToAbsent
          ? const Value.absent()
          : Value(questionCount),
      correctCount: correctCount == null && nullToAbsent
          ? const Value.absent()
          : Value(correctCount),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      sessionType: $SessionsTable.$convertersessionType.fromJson(
        serializer.fromJson<String>(json['sessionType']),
      ),
      difficultyLevel: serializer.fromJson<int?>(json['difficultyLevel']),
      adaptiveStartLevel: serializer.fromJson<int?>(json['adaptiveStartLevel']),
      answerMode: $SessionsTable.$converteranswerMode.fromJson(
        serializer.fromJson<String>(json['answerMode']),
      ),
      presetKind: $SessionsTable.$converterpresetKind.fromJson(
        serializer.fromJson<String>(json['presetKind']),
      ),
      categoryIds: serializer.fromJson<List<String>>(json['categoryIds']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      avgAnswerSeconds: serializer.fromJson<double?>(json['avgAnswerSeconds']),
      questionCount: serializer.fromJson<int?>(json['questionCount']),
      correctCount: serializer.fromJson<int?>(json['correctCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'sessionType': serializer.toJson<String>(
        $SessionsTable.$convertersessionType.toJson(sessionType),
      ),
      'difficultyLevel': serializer.toJson<int?>(difficultyLevel),
      'adaptiveStartLevel': serializer.toJson<int?>(adaptiveStartLevel),
      'answerMode': serializer.toJson<String>(
        $SessionsTable.$converteranswerMode.toJson(answerMode),
      ),
      'presetKind': serializer.toJson<String>(
        $SessionsTable.$converterpresetKind.toJson(presetKind),
      ),
      'categoryIds': serializer.toJson<List<String>>(categoryIds),
      'accuracy': serializer.toJson<double?>(accuracy),
      'avgAnswerSeconds': serializer.toJson<double?>(avgAnswerSeconds),
      'questionCount': serializer.toJson<int?>(questionCount),
      'correctCount': serializer.toJson<int?>(correctCount),
    };
  }

  SessionRow copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    SessionType? sessionType,
    Value<int?> difficultyLevel = const Value.absent(),
    Value<int?> adaptiveStartLevel = const Value.absent(),
    AnswerMode? answerMode,
    PresetKind? presetKind,
    List<String>? categoryIds,
    Value<double?> accuracy = const Value.absent(),
    Value<double?> avgAnswerSeconds = const Value.absent(),
    Value<int?> questionCount = const Value.absent(),
    Value<int?> correctCount = const Value.absent(),
  }) => SessionRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    sessionType: sessionType ?? this.sessionType,
    difficultyLevel: difficultyLevel.present
        ? difficultyLevel.value
        : this.difficultyLevel,
    adaptiveStartLevel: adaptiveStartLevel.present
        ? adaptiveStartLevel.value
        : this.adaptiveStartLevel,
    answerMode: answerMode ?? this.answerMode,
    presetKind: presetKind ?? this.presetKind,
    categoryIds: categoryIds ?? this.categoryIds,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    avgAnswerSeconds: avgAnswerSeconds.present
        ? avgAnswerSeconds.value
        : this.avgAnswerSeconds,
    questionCount: questionCount.present
        ? questionCount.value
        : this.questionCount,
    correctCount: correctCount.present ? correctCount.value : this.correctCount,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      difficultyLevel: data.difficultyLevel.present
          ? data.difficultyLevel.value
          : this.difficultyLevel,
      adaptiveStartLevel: data.adaptiveStartLevel.present
          ? data.adaptiveStartLevel.value
          : this.adaptiveStartLevel,
      answerMode: data.answerMode.present
          ? data.answerMode.value
          : this.answerMode,
      presetKind: data.presetKind.present
          ? data.presetKind.value
          : this.presetKind,
      categoryIds: data.categoryIds.present
          ? data.categoryIds.value
          : this.categoryIds,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      avgAnswerSeconds: data.avgAnswerSeconds.present
          ? data.avgAnswerSeconds.value
          : this.avgAnswerSeconds,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('sessionType: $sessionType, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('adaptiveStartLevel: $adaptiveStartLevel, ')
          ..write('answerMode: $answerMode, ')
          ..write('presetKind: $presetKind, ')
          ..write('categoryIds: $categoryIds, ')
          ..write('accuracy: $accuracy, ')
          ..write('avgAnswerSeconds: $avgAnswerSeconds, ')
          ..write('questionCount: $questionCount, ')
          ..write('correctCount: $correctCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    sessionType,
    difficultyLevel,
    adaptiveStartLevel,
    answerMode,
    presetKind,
    categoryIds,
    accuracy,
    avgAnswerSeconds,
    questionCount,
    correctCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.sessionType == this.sessionType &&
          other.difficultyLevel == this.difficultyLevel &&
          other.adaptiveStartLevel == this.adaptiveStartLevel &&
          other.answerMode == this.answerMode &&
          other.presetKind == this.presetKind &&
          other.categoryIds == this.categoryIds &&
          other.accuracy == this.accuracy &&
          other.avgAnswerSeconds == this.avgAnswerSeconds &&
          other.questionCount == this.questionCount &&
          other.correctCount == this.correctCount);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<SessionType> sessionType;
  final Value<int?> difficultyLevel;
  final Value<int?> adaptiveStartLevel;
  final Value<AnswerMode> answerMode;
  final Value<PresetKind> presetKind;
  final Value<List<String>> categoryIds;
  final Value<double?> accuracy;
  final Value<double?> avgAnswerSeconds;
  final Value<int?> questionCount;
  final Value<int?> correctCount;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.adaptiveStartLevel = const Value.absent(),
    this.answerMode = const Value.absent(),
    this.presetKind = const Value.absent(),
    this.categoryIds = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.avgAnswerSeconds = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.correctCount = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required SessionType sessionType,
    this.difficultyLevel = const Value.absent(),
    this.adaptiveStartLevel = const Value.absent(),
    required AnswerMode answerMode,
    required PresetKind presetKind,
    required List<String> categoryIds,
    this.accuracy = const Value.absent(),
    this.avgAnswerSeconds = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.correctCount = const Value.absent(),
  }) : startedAt = Value(startedAt),
       sessionType = Value(sessionType),
       answerMode = Value(answerMode),
       presetKind = Value(presetKind),
       categoryIds = Value(categoryIds);
  static Insertable<SessionRow> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? sessionType,
    Expression<int>? difficultyLevel,
    Expression<int>? adaptiveStartLevel,
    Expression<String>? answerMode,
    Expression<String>? presetKind,
    Expression<String>? categoryIds,
    Expression<double>? accuracy,
    Expression<double>? avgAnswerSeconds,
    Expression<int>? questionCount,
    Expression<int>? correctCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (sessionType != null) 'session_type': sessionType,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      if (adaptiveStartLevel != null)
        'adaptive_start_level': adaptiveStartLevel,
      if (answerMode != null) 'answer_mode': answerMode,
      if (presetKind != null) 'preset_kind': presetKind,
      if (categoryIds != null) 'category_ids': categoryIds,
      if (accuracy != null) 'accuracy': accuracy,
      if (avgAnswerSeconds != null) 'avg_answer_seconds': avgAnswerSeconds,
      if (questionCount != null) 'question_count': questionCount,
      if (correctCount != null) 'correct_count': correctCount,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<SessionType>? sessionType,
    Value<int?>? difficultyLevel,
    Value<int?>? adaptiveStartLevel,
    Value<AnswerMode>? answerMode,
    Value<PresetKind>? presetKind,
    Value<List<String>>? categoryIds,
    Value<double?>? accuracy,
    Value<double?>? avgAnswerSeconds,
    Value<int?>? questionCount,
    Value<int?>? correctCount,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      sessionType: sessionType ?? this.sessionType,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      adaptiveStartLevel: adaptiveStartLevel ?? this.adaptiveStartLevel,
      answerMode: answerMode ?? this.answerMode,
      presetKind: presetKind ?? this.presetKind,
      categoryIds: categoryIds ?? this.categoryIds,
      accuracy: accuracy ?? this.accuracy,
      avgAnswerSeconds: avgAnswerSeconds ?? this.avgAnswerSeconds,
      questionCount: questionCount ?? this.questionCount,
      correctCount: correctCount ?? this.correctCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(
        $SessionsTable.$convertersessionType.toSql(sessionType.value),
      );
    }
    if (difficultyLevel.present) {
      map['difficulty_level'] = Variable<int>(difficultyLevel.value);
    }
    if (adaptiveStartLevel.present) {
      map['adaptive_start_level'] = Variable<int>(adaptiveStartLevel.value);
    }
    if (answerMode.present) {
      map['answer_mode'] = Variable<String>(
        $SessionsTable.$converteranswerMode.toSql(answerMode.value),
      );
    }
    if (presetKind.present) {
      map['preset_kind'] = Variable<String>(
        $SessionsTable.$converterpresetKind.toSql(presetKind.value),
      );
    }
    if (categoryIds.present) {
      map['category_ids'] = Variable<String>(
        $SessionsTable.$convertercategoryIds.toSql(categoryIds.value),
      );
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (avgAnswerSeconds.present) {
      map['avg_answer_seconds'] = Variable<double>(avgAnswerSeconds.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('sessionType: $sessionType, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('adaptiveStartLevel: $adaptiveStartLevel, ')
          ..write('answerMode: $answerMode, ')
          ..write('presetKind: $presetKind, ')
          ..write('categoryIds: $categoryIds, ')
          ..write('accuracy: $accuracy, ')
          ..write('avgAnswerSeconds: $avgAnswerSeconds, ')
          ..write('questionCount: $questionCount, ')
          ..write('correctCount: $correctCount')
          ..write(')'))
        .toString();
  }
}

class $QuestionAttemptsTable extends QuestionAttempts
    with TableInfo<$QuestionAttemptsTable, QuestionAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    check: () => ComparableExpr(level).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedAnswerMeta = const VerificationMeta(
    'expectedAnswer',
  );
  @override
  late final GeneratedColumn<double> expectedAnswer = GeneratedColumn<double>(
    'expected_answer',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _givenAnswerMeta = const VerificationMeta(
    'givenAnswer',
  );
  @override
  late final GeneratedColumn<double> givenAnswer = GeneratedColumn<double>(
    'given_answer',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _answerSecondsMeta = const VerificationMeta(
    'answerSeconds',
  );
  @override
  late final GeneratedColumn<double> answerSeconds = GeneratedColumn<double>(
    'answer_seconds',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    categoryId,
    templateId,
    level,
    questionText,
    expectedAnswer,
    givenAnswer,
    isCorrect,
    answerSeconds,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('expected_answer')) {
      context.handle(
        _expectedAnswerMeta,
        expectedAnswer.isAcceptableOrUnknown(
          data['expected_answer']!,
          _expectedAnswerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedAnswerMeta);
    }
    if (data.containsKey('given_answer')) {
      context.handle(
        _givenAnswerMeta,
        givenAnswer.isAcceptableOrUnknown(
          data['given_answer']!,
          _givenAnswerMeta,
        ),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('answer_seconds')) {
      context.handle(
        _answerSecondsMeta,
        answerSeconds.isAcceptableOrUnknown(
          data['answer_seconds']!,
          _answerSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_answerSecondsMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionAttemptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      expectedAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_answer'],
      )!,
      givenAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}given_answer'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      answerSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}answer_seconds'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $QuestionAttemptsTable createAlias(String alias) {
    return $QuestionAttemptsTable(attachedDatabase, alias);
  }
}

class QuestionAttemptRow extends DataClass
    implements Insertable<QuestionAttemptRow> {
  final int id;
  final int sessionId;
  final String categoryId;
  final String templateId;
  final int level;
  final String questionText;
  final double expectedAnswer;
  final double? givenAnswer;
  final bool isCorrect;
  final double answerSeconds;
  final DateTime answeredAt;
  const QuestionAttemptRow({
    required this.id,
    required this.sessionId,
    required this.categoryId,
    required this.templateId,
    required this.level,
    required this.questionText,
    required this.expectedAnswer,
    this.givenAnswer,
    required this.isCorrect,
    required this.answerSeconds,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['category_id'] = Variable<String>(categoryId);
    map['template_id'] = Variable<String>(templateId);
    map['level'] = Variable<int>(level);
    map['question_text'] = Variable<String>(questionText);
    map['expected_answer'] = Variable<double>(expectedAnswer);
    if (!nullToAbsent || givenAnswer != null) {
      map['given_answer'] = Variable<double>(givenAnswer);
    }
    map['is_correct'] = Variable<bool>(isCorrect);
    map['answer_seconds'] = Variable<double>(answerSeconds);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  QuestionAttemptsCompanion toCompanion(bool nullToAbsent) {
    return QuestionAttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      categoryId: Value(categoryId),
      templateId: Value(templateId),
      level: Value(level),
      questionText: Value(questionText),
      expectedAnswer: Value(expectedAnswer),
      givenAnswer: givenAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(givenAnswer),
      isCorrect: Value(isCorrect),
      answerSeconds: Value(answerSeconds),
      answeredAt: Value(answeredAt),
    );
  }

  factory QuestionAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionAttemptRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      templateId: serializer.fromJson<String>(json['templateId']),
      level: serializer.fromJson<int>(json['level']),
      questionText: serializer.fromJson<String>(json['questionText']),
      expectedAnswer: serializer.fromJson<double>(json['expectedAnswer']),
      givenAnswer: serializer.fromJson<double?>(json['givenAnswer']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      answerSeconds: serializer.fromJson<double>(json['answerSeconds']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'categoryId': serializer.toJson<String>(categoryId),
      'templateId': serializer.toJson<String>(templateId),
      'level': serializer.toJson<int>(level),
      'questionText': serializer.toJson<String>(questionText),
      'expectedAnswer': serializer.toJson<double>(expectedAnswer),
      'givenAnswer': serializer.toJson<double?>(givenAnswer),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'answerSeconds': serializer.toJson<double>(answerSeconds),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  QuestionAttemptRow copyWith({
    int? id,
    int? sessionId,
    String? categoryId,
    String? templateId,
    int? level,
    String? questionText,
    double? expectedAnswer,
    Value<double?> givenAnswer = const Value.absent(),
    bool? isCorrect,
    double? answerSeconds,
    DateTime? answeredAt,
  }) => QuestionAttemptRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    categoryId: categoryId ?? this.categoryId,
    templateId: templateId ?? this.templateId,
    level: level ?? this.level,
    questionText: questionText ?? this.questionText,
    expectedAnswer: expectedAnswer ?? this.expectedAnswer,
    givenAnswer: givenAnswer.present ? givenAnswer.value : this.givenAnswer,
    isCorrect: isCorrect ?? this.isCorrect,
    answerSeconds: answerSeconds ?? this.answerSeconds,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  QuestionAttemptRow copyWithCompanion(QuestionAttemptsCompanion data) {
    return QuestionAttemptRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      level: data.level.present ? data.level.value : this.level,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      expectedAnswer: data.expectedAnswer.present
          ? data.expectedAnswer.value
          : this.expectedAnswer,
      givenAnswer: data.givenAnswer.present
          ? data.givenAnswer.value
          : this.givenAnswer,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      answerSeconds: data.answerSeconds.present
          ? data.answerSeconds.value
          : this.answerSeconds,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionAttemptRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('categoryId: $categoryId, ')
          ..write('templateId: $templateId, ')
          ..write('level: $level, ')
          ..write('questionText: $questionText, ')
          ..write('expectedAnswer: $expectedAnswer, ')
          ..write('givenAnswer: $givenAnswer, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answerSeconds: $answerSeconds, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    categoryId,
    templateId,
    level,
    questionText,
    expectedAnswer,
    givenAnswer,
    isCorrect,
    answerSeconds,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionAttemptRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.categoryId == this.categoryId &&
          other.templateId == this.templateId &&
          other.level == this.level &&
          other.questionText == this.questionText &&
          other.expectedAnswer == this.expectedAnswer &&
          other.givenAnswer == this.givenAnswer &&
          other.isCorrect == this.isCorrect &&
          other.answerSeconds == this.answerSeconds &&
          other.answeredAt == this.answeredAt);
}

class QuestionAttemptsCompanion extends UpdateCompanion<QuestionAttemptRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> categoryId;
  final Value<String> templateId;
  final Value<int> level;
  final Value<String> questionText;
  final Value<double> expectedAnswer;
  final Value<double?> givenAnswer;
  final Value<bool> isCorrect;
  final Value<double> answerSeconds;
  final Value<DateTime> answeredAt;
  const QuestionAttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.level = const Value.absent(),
    this.questionText = const Value.absent(),
    this.expectedAnswer = const Value.absent(),
    this.givenAnswer = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.answerSeconds = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  QuestionAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String categoryId,
    required String templateId,
    required int level,
    required String questionText,
    required double expectedAnswer,
    this.givenAnswer = const Value.absent(),
    required bool isCorrect,
    required double answerSeconds,
    required DateTime answeredAt,
  }) : sessionId = Value(sessionId),
       categoryId = Value(categoryId),
       templateId = Value(templateId),
       level = Value(level),
       questionText = Value(questionText),
       expectedAnswer = Value(expectedAnswer),
       isCorrect = Value(isCorrect),
       answerSeconds = Value(answerSeconds),
       answeredAt = Value(answeredAt);
  static Insertable<QuestionAttemptRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? categoryId,
    Expression<String>? templateId,
    Expression<int>? level,
    Expression<String>? questionText,
    Expression<double>? expectedAnswer,
    Expression<double>? givenAnswer,
    Expression<bool>? isCorrect,
    Expression<double>? answerSeconds,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (categoryId != null) 'category_id': categoryId,
      if (templateId != null) 'template_id': templateId,
      if (level != null) 'level': level,
      if (questionText != null) 'question_text': questionText,
      if (expectedAnswer != null) 'expected_answer': expectedAnswer,
      if (givenAnswer != null) 'given_answer': givenAnswer,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (answerSeconds != null) 'answer_seconds': answerSeconds,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  QuestionAttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? categoryId,
    Value<String>? templateId,
    Value<int>? level,
    Value<String>? questionText,
    Value<double>? expectedAnswer,
    Value<double?>? givenAnswer,
    Value<bool>? isCorrect,
    Value<double>? answerSeconds,
    Value<DateTime>? answeredAt,
  }) {
    return QuestionAttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      categoryId: categoryId ?? this.categoryId,
      templateId: templateId ?? this.templateId,
      level: level ?? this.level,
      questionText: questionText ?? this.questionText,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      givenAnswer: givenAnswer ?? this.givenAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      answerSeconds: answerSeconds ?? this.answerSeconds,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (expectedAnswer.present) {
      map['expected_answer'] = Variable<double>(expectedAnswer.value);
    }
    if (givenAnswer.present) {
      map['given_answer'] = Variable<double>(givenAnswer.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (answerSeconds.present) {
      map['answer_seconds'] = Variable<double>(answerSeconds.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('categoryId: $categoryId, ')
          ..write('templateId: $templateId, ')
          ..write('level: $level, ')
          ..write('questionText: $questionText, ')
          ..write('expectedAnswer: $expectedAnswer, ')
          ..write('givenAnswer: $givenAnswer, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answerSeconds: $answerSeconds, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $QuestionAttemptsTable questionAttempts = $QuestionAttemptsTable(
    this,
  );
  late final Index sessionsStartedAt = Index(
    'sessions_started_at',
    'CREATE INDEX sessions_started_at ON sessions (started_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    sessions,
    questionAttempts,
    sessionsStartedAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('question_attempts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required int displayOrder,
      required int level,
      required double accuracy,
      required double avgAnswerSeconds,
      required List<LevelChange> levelHistory,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> displayOrder,
      Value<int> level,
      Value<double> accuracy,
      Value<double> avgAnswerSeconds,
      Value<List<LevelChange>> levelHistory,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestionAttemptsTable, List<QuestionAttemptRow>>
  _questionAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questionAttempts,
    aliasName: 'categories__id__question_attempts__category_id',
  );

  $$QuestionAttemptsTableProcessedTableManager get questionAttemptsRefs {
    final manager = $$QuestionAttemptsTableTableManager(
      $_db,
      $_db.questionAttempts,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionAttemptsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgAnswerSeconds => $composableBuilder(
    column: $table.avgAnswerSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<LevelChange>, List<LevelChange>, String>
  get levelHistory => $composableBuilder(
    column: $table.levelHistory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> questionAttemptsRefs(
    Expression<bool> Function($$QuestionAttemptsTableFilterComposer f) f,
  ) {
    final $$QuestionAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionAttempts,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.questionAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgAnswerSeconds => $composableBuilder(
    column: $table.avgAnswerSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelHistory => $composableBuilder(
    column: $table.levelHistory,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get avgAnswerSeconds => $composableBuilder(
    column: $table.avgAnswerSeconds,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<LevelChange>, String>
  get levelHistory => $composableBuilder(
    column: $table.levelHistory,
    builder: (column) => column,
  );

  Expression<T> questionAttemptsRefs<T extends Object>(
    Expression<T> Function($$QuestionAttemptsTableAnnotationComposer a) f,
  ) {
    final $$QuestionAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionAttempts,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.questionAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool questionAttemptsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<double> avgAnswerSeconds = const Value.absent(),
                Value<List<LevelChange>> levelHistory = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                displayOrder: displayOrder,
                level: level,
                accuracy: accuracy,
                avgAnswerSeconds: avgAnswerSeconds,
                levelHistory: levelHistory,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int displayOrder,
                required int level,
                required double accuracy,
                required double avgAnswerSeconds,
                required List<LevelChange> levelHistory,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                displayOrder: displayOrder,
                level: level,
                accuracy: accuracy,
                avgAnswerSeconds: avgAnswerSeconds,
                levelHistory: levelHistory,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionAttemptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (questionAttemptsRefs) db.questionAttempts,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questionAttemptsRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      QuestionAttemptRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._questionAttemptsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).questionAttemptsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool questionAttemptsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required SessionType sessionType,
      Value<int?> difficultyLevel,
      Value<int?> adaptiveStartLevel,
      required AnswerMode answerMode,
      required PresetKind presetKind,
      required List<String> categoryIds,
      Value<double?> accuracy,
      Value<double?> avgAnswerSeconds,
      Value<int?> questionCount,
      Value<int?> correctCount,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<SessionType> sessionType,
      Value<int?> difficultyLevel,
      Value<int?> adaptiveStartLevel,
      Value<AnswerMode> answerMode,
      Value<PresetKind> presetKind,
      Value<List<String>> categoryIds,
      Value<double?> accuracy,
      Value<double?> avgAnswerSeconds,
      Value<int?> questionCount,
      Value<int?> correctCount,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestionAttemptsTable, List<QuestionAttemptRow>>
  _questionAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questionAttempts,
    aliasName: 'sessions__id__question_attempts__session_id',
  );

  $$QuestionAttemptsTableProcessedTableManager get questionAttemptsRefs {
    final manager = $$QuestionAttemptsTableTableManager(
      $_db,
      $_db.questionAttempts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionAttemptsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionType, SessionType, String>
  get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adaptiveStartLevel => $composableBuilder(
    column: $table.adaptiveStartLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AnswerMode, AnswerMode, String>
  get answerMode => $composableBuilder(
    column: $table.answerMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<PresetKind, PresetKind, String>
  get presetKind => $composableBuilder(
    column: $table.presetKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get categoryIds => $composableBuilder(
    column: $table.categoryIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgAnswerSeconds => $composableBuilder(
    column: $table.avgAnswerSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> questionAttemptsRefs(
    Expression<bool> Function($$QuestionAttemptsTableFilterComposer f) f,
  ) {
    final $$QuestionAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.questionAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adaptiveStartLevel => $composableBuilder(
    column: $table.adaptiveStartLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerMode => $composableBuilder(
    column: $table.answerMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetKind => $composableBuilder(
    column: $table.presetKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryIds => $composableBuilder(
    column: $table.categoryIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgAnswerSeconds => $composableBuilder(
    column: $table.avgAnswerSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionType, String> get sessionType =>
      $composableBuilder(
        column: $table.sessionType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get adaptiveStartLevel => $composableBuilder(
    column: $table.adaptiveStartLevel,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AnswerMode, String> get answerMode =>
      $composableBuilder(
        column: $table.answerMode,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<PresetKind, String> get presetKind =>
      $composableBuilder(
        column: $table.presetKind,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get categoryIds =>
      $composableBuilder(
        column: $table.categoryIds,
        builder: (column) => column,
      );

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get avgAnswerSeconds => $composableBuilder(
    column: $table.avgAnswerSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  Expression<T> questionAttemptsRefs<T extends Object>(
    Expression<T> Function($$QuestionAttemptsTableAnnotationComposer a) f,
  ) {
    final $$QuestionAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionAttempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.questionAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({bool questionAttemptsRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<SessionType> sessionType = const Value.absent(),
                Value<int?> difficultyLevel = const Value.absent(),
                Value<int?> adaptiveStartLevel = const Value.absent(),
                Value<AnswerMode> answerMode = const Value.absent(),
                Value<PresetKind> presetKind = const Value.absent(),
                Value<List<String>> categoryIds = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<double?> avgAnswerSeconds = const Value.absent(),
                Value<int?> questionCount = const Value.absent(),
                Value<int?> correctCount = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                sessionType: sessionType,
                difficultyLevel: difficultyLevel,
                adaptiveStartLevel: adaptiveStartLevel,
                answerMode: answerMode,
                presetKind: presetKind,
                categoryIds: categoryIds,
                accuracy: accuracy,
                avgAnswerSeconds: avgAnswerSeconds,
                questionCount: questionCount,
                correctCount: correctCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required SessionType sessionType,
                Value<int?> difficultyLevel = const Value.absent(),
                Value<int?> adaptiveStartLevel = const Value.absent(),
                required AnswerMode answerMode,
                required PresetKind presetKind,
                required List<String> categoryIds,
                Value<double?> accuracy = const Value.absent(),
                Value<double?> avgAnswerSeconds = const Value.absent(),
                Value<int?> questionCount = const Value.absent(),
                Value<int?> correctCount = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                sessionType: sessionType,
                difficultyLevel: difficultyLevel,
                adaptiveStartLevel: adaptiveStartLevel,
                answerMode: answerMode,
                presetKind: presetKind,
                categoryIds: categoryIds,
                accuracy: accuracy,
                avgAnswerSeconds: avgAnswerSeconds,
                questionCount: questionCount,
                correctCount: correctCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionAttemptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (questionAttemptsRefs) db.questionAttempts,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questionAttemptsRefs)
                    await $_getPrefetchedData<
                      SessionRow,
                      $SessionsTable,
                      QuestionAttemptRow
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._questionAttemptsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SessionsTableReferences(
                        db,
                        table,
                        p0,
                      ).questionAttemptsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool questionAttemptsRefs})
    >;
typedef $$QuestionAttemptsTableCreateCompanionBuilder =
    QuestionAttemptsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String categoryId,
      required String templateId,
      required int level,
      required String questionText,
      required double expectedAnswer,
      Value<double?> givenAnswer,
      required bool isCorrect,
      required double answerSeconds,
      required DateTime answeredAt,
    });
typedef $$QuestionAttemptsTableUpdateCompanionBuilder =
    QuestionAttemptsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> categoryId,
      Value<String> templateId,
      Value<int> level,
      Value<String> questionText,
      Value<double> expectedAnswer,
      Value<double?> givenAnswer,
      Value<bool> isCorrect,
      Value<double> answerSeconds,
      Value<DateTime> answeredAt,
    });

final class $$QuestionAttemptsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $QuestionAttemptsTable,
          QuestionAttemptRow
        > {
  $$QuestionAttemptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('question_attempts__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('question_attempts__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestionAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionAttemptsTable> {
  $$QuestionAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedAnswer => $composableBuilder(
    column: $table.expectedAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get givenAnswer => $composableBuilder(
    column: $table.givenAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get answerSeconds => $composableBuilder(
    column: $table.answerSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionAttemptsTable> {
  $$QuestionAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedAnswer => $composableBuilder(
    column: $table.expectedAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get givenAnswer => $composableBuilder(
    column: $table.givenAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get answerSeconds => $composableBuilder(
    column: $table.answerSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionAttemptsTable> {
  $$QuestionAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedAnswer => $composableBuilder(
    column: $table.expectedAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get givenAnswer => $composableBuilder(
    column: $table.givenAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<double> get answerSeconds => $composableBuilder(
    column: $table.answerSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionAttemptsTable,
          QuestionAttemptRow,
          $$QuestionAttemptsTableFilterComposer,
          $$QuestionAttemptsTableOrderingComposer,
          $$QuestionAttemptsTableAnnotationComposer,
          $$QuestionAttemptsTableCreateCompanionBuilder,
          $$QuestionAttemptsTableUpdateCompanionBuilder,
          (QuestionAttemptRow, $$QuestionAttemptsTableReferences),
          QuestionAttemptRow,
          PrefetchHooks Function({bool sessionId, bool categoryId})
        > {
  $$QuestionAttemptsTableTableManager(
    _$AppDatabase db,
    $QuestionAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<double> expectedAnswer = const Value.absent(),
                Value<double?> givenAnswer = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<double> answerSeconds = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => QuestionAttemptsCompanion(
                id: id,
                sessionId: sessionId,
                categoryId: categoryId,
                templateId: templateId,
                level: level,
                questionText: questionText,
                expectedAnswer: expectedAnswer,
                givenAnswer: givenAnswer,
                isCorrect: isCorrect,
                answerSeconds: answerSeconds,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String categoryId,
                required String templateId,
                required int level,
                required String questionText,
                required double expectedAnswer,
                Value<double?> givenAnswer = const Value.absent(),
                required bool isCorrect,
                required double answerSeconds,
                required DateTime answeredAt,
              }) => QuestionAttemptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                categoryId: categoryId,
                templateId: templateId,
                level: level,
                questionText: questionText,
                expectedAnswer: expectedAnswer,
                givenAnswer: givenAnswer,
                isCorrect: isCorrect,
                answerSeconds: answerSeconds,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuestionAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$QuestionAttemptsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$QuestionAttemptsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$QuestionAttemptsTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$QuestionAttemptsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuestionAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionAttemptsTable,
      QuestionAttemptRow,
      $$QuestionAttemptsTableFilterComposer,
      $$QuestionAttemptsTableOrderingComposer,
      $$QuestionAttemptsTableAnnotationComposer,
      $$QuestionAttemptsTableCreateCompanionBuilder,
      $$QuestionAttemptsTableUpdateCompanionBuilder,
      (QuestionAttemptRow, $$QuestionAttemptsTableReferences),
      QuestionAttemptRow,
      PrefetchHooks Function({bool sessionId, bool categoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$QuestionAttemptsTableTableManager get questionAttempts =>
      $$QuestionAttemptsTableTableManager(_db, _db.questionAttempts);
}
