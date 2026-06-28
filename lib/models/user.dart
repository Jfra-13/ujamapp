import 'package:cloud_firestore/cloud_firestore.dart';

/// Rango del usuario, derivado de los puntos. Define slogan y logo en el perfil
/// (README Apéndice D). Los umbrales de puntos quedan por definir.
enum Rank { frascoVacio, cucharada, buenFrasco, frascoDeOro, maestroMermelada }

/// Estadísticas de participación del usuario (las 4 titulares + contadores base).
/// Se guardan denormalizadas y se actualizan en transacción al verificar un pago
/// o completar un Jam — no se recalcula el historial en cada lectura.
class UserStats {
  final int jamsCreated;
  final int jamsJoined;
  final int jamsCompleted;

  /// Velocidad promedio de pago (minutos desde que entra al Jam hasta el voucher).
  final double avgPaySpeedMinutes;

  /// Tasa de cumplimiento = jamsCompleted / jamsJoined (0..1).
  final double completionRate;

  /// Jams consecutivos pagando a tiempo.
  final int currentStreak;

  const UserStats({
    this.jamsCreated = 0,
    this.jamsJoined = 0,
    this.jamsCompleted = 0,
    this.avgPaySpeedMinutes = 0,
    this.completionRate = 0,
    this.currentStreak = 0,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      jamsCreated: map['jamsCreated'] as int? ?? 0,
      jamsJoined: map['jamsJoined'] as int? ?? 0,
      jamsCompleted: map['jamsCompleted'] as int? ?? 0,
      avgPaySpeedMinutes: (map['avgPaySpeedMinutes'] as num? ?? 0).toDouble(),
      completionRate: (map['completionRate'] as num? ?? 0).toDouble(),
      currentStreak: map['currentStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'jamsCreated': jamsCreated,
        'jamsJoined': jamsJoined,
        'jamsCompleted': jamsCompleted,
        'avgPaySpeedMinutes': avgPaySpeedMinutes,
        'completionRate': completionRate,
        'currentStreak': currentStreak,
      };
}

/// Perfil de usuario. Documento en `users/{userId}`.
/// Nombre `AppUser` para no chocar con `User` de Firebase Auth.
class AppUser {
  final String id;
  final String nickname;
  final String? avatarUrl;

  /// Frase bajo el nombre, derivada del rango (no se edita a mano).
  final String slogan;

  final int points;
  final Rank rank;

  /// Insignias ganadas (ids de badge).
  final List<String> badges;

  final UserStats stats;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.slogan = '',
    this.points = 0,
    this.rank = Rank.frascoVacio,
    this.badges = const [],
    this.stats = const UserStats(),
    required this.createdAt,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      nickname: map['nickname'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      slogan: map['slogan'] as String? ?? '',
      points: map['points'] as int? ?? 0,
      rank: Rank.values.byName(map['rank'] as String? ?? 'frascoVacio'),
      badges: List<String>.from(map['badges'] as List? ?? const []),
      stats: UserStats.fromMap(
          Map<String, dynamic>.from(map['stats'] as Map? ?? const {})),
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'slogan': slogan,
        'points': points,
        'rank': rank.name,
        'badges': badges,
        'stats': stats.toMap(),
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
