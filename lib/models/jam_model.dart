import 'package:cloud_firestore/cloud_firestore.dart';

import 'jam_item.dart';

/// Ciclo de vida del Jam, gobernado por un único `deadline` (README Apéndice G).
/// abierto -> (deadline) -> vencido -> (todos pagan) -> completado.
enum JamStatus { abierto, vencido, completado }

/// Un Jam (frasco): un recaudo grupal.
/// Documento en la colección `jams/{jamId}`. Los participantes van en la
/// subcolección `jams/{jamId}/participants/{userId}`.
class Jam {
  final String id;
  final String title;
  final String? description;
  final String icon;
  final String adminId;
  final DateTime deadline;
  final JamStatus status;

  /// Tope de items opcionales que un miembro puede elegir. null = sin tope.
  final int? maxOpcionales;

  /// Items de gasto, embebidos en el doc (lista acotada).
  final List<JamItem> items;

  /// IDs de los miembros "dentro del frasco". Usado para queries y reglas.
  final List<String> memberIds;

  Jam({
    required this.id,
    required this.title,
    this.description,
    this.icon = '🍯',
    required this.adminId,
    required this.deadline,
    this.status = JamStatus.abierto,
    this.maxOpcionales,
    this.items = const [],
    this.memberIds = const [],
  });

  factory Jam.fromMap(String id, Map<String, dynamic> map) {
    return Jam(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      icon: map['icon'] as String? ?? '🍯',
      adminId: map['adminId'] as String? ?? '',
      deadline: (map['deadline'] as Timestamp).toDate(),
      status: JamStatus.values.byName(map['status'] as String? ?? 'abierto'),
      maxOpcionales: map['maxOpcionales'] as int?,
      items: (map['items'] as List? ?? const [])
          .map((e) => JamItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      memberIds: List<String>.from(map['memberIds'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'icon': icon,
        'adminId': adminId,
        'deadline': Timestamp.fromDate(deadline),
        'status': status.name,
        'maxOpcionales': maxOpcionales,
        'items': items.map((e) => e.toMap()).toList(),
        'memberIds': memberIds,
      };
}
