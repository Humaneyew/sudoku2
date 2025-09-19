import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ChampionshipBackupData {
  const ChampionshipBackupData({
    required this.version,
    required this.exportedAt,
    required this.myScore,
    required this.bestRank,
    required this.bestScore,
    required this.installSeed,
    required this.lastAwardedGameId,
    required this.autoScroll,
    required this.opponents,
  });

  static const int currentVersion = 1;

  final int version;
  final DateTime exportedAt;
  final int myScore;
  final int bestRank;
  final int bestScore;
  final int installSeed;
  final String? lastAwardedGameId;
  final bool autoScroll;
  final List<Map<String, dynamic>> opponents;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'myScore': myScore,
      'bestRank': bestRank,
      'bestScore': bestScore,
      'installSeed': installSeed,
      'lastAwardedGameId': lastAwardedGameId,
      'settings': <String, dynamic>{'autoScroll': autoScroll},
      'opponents': opponents,
    };
  }

  static ChampionshipBackupData fromJson(Map<String, dynamic> json) {
    final version = (json['version'] as num?)?.toInt();
    if (version == null) {
      throw const FormatException('Missing version');
    }
    if (version != currentVersion) {
      throw FormatException('Unsupported backup version: $version');
    }
    final exportedAtRaw = json['exportedAt'] as String?;
    final exportedAt = exportedAtRaw != null
        ? DateTime.tryParse(exportedAtRaw)?.toUtc()
        : null;
    if (exportedAt == null) {
      throw const FormatException('Invalid exportedAt');
    }

    final myScore = (json['myScore'] as num?)?.toInt();
    final bestRank = (json['bestRank'] as num?)?.toInt();
    final bestScore = (json['bestScore'] as num?)?.toInt();
    final installSeed = (json['installSeed'] as num?)?.toInt();
    if (myScore == null || bestRank == null || bestScore == null || installSeed == null) {
      throw const FormatException('Missing numeric fields');
    }

    final settings = json['settings'];
    final autoScroll = settings is Map
        ? (settings['autoScroll'] as bool?) ?? true
        : true;

    final opponentsRaw = json['opponents'];
    if (opponentsRaw is! List) {
      throw const FormatException('Opponents should be a list');
    }
    final opponents = <Map<String, dynamic>>[];
    for (final item in opponentsRaw) {
      if (item is Map<String, dynamic>) {
        opponents.add(Map<String, dynamic>.from(item));
      } else if (item is Map) {
        opponents.add(Map<String, dynamic>.from(item.cast<dynamic, dynamic>()));
      }
    }

    return ChampionshipBackupData(
      version: version,
      exportedAt: exportedAt,
      myScore: myScore,
      bestRank: bestRank,
      bestScore: bestScore,
      installSeed: installSeed,
      lastAwardedGameId: json['lastAwardedGameId'] as String?,
      autoScroll: autoScroll,
      opponents: List<Map<String, dynamic>>.unmodifiable(opponents),
    );
  }
}

class ChampionshipBackupManager {
  static const String backupFileName = 'champ_backup_v1.json';

  static Future<File> saveBackup(ChampionshipBackupData data) async {
    if (kIsWeb) {
      throw UnsupportedError('File system is not available on the web');
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$backupFileName';
    final file = File(path);
    final encoded = jsonEncode(data.toJson());
    return file.writeAsString(encoded);
  }

  static Future<ChampionshipBackupData> loadFromFile(File file) async {
    final source = await file.readAsString();
    return decode(source);
  }

  static ChampionshipBackupData decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return ChampionshipBackupData.fromJson(decoded);
    }
    if (decoded is Map) {
      return ChampionshipBackupData.fromJson(
        Map<String, dynamic>.from(decoded.cast<dynamic, dynamic>()),
      );
    }
    throw const FormatException('Invalid backup format');
  }
}

