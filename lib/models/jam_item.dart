/// Tipo de item de gasto dentro de un Jam.
/// fijo = lo paga todo el mundo · opcional = lo elige quien quiere.
enum ItemKind { fijo, opcional }

/// Un item de gasto del Jam (casa, carbón, carne...).
///
/// El precio es POR PERSONA y fijo: no se divide en vivo. La división
/// automática es solo una calculadora al crear (ver README Apéndice F).
/// Así, sumar miembros nuevos nunca recalcula lo que ya pagaron los demás.
class JamItem {
  final String id;
  final String name;
  final double pricePerPerson;
  final ItemKind kind;

  JamItem({
    required this.id,
    required this.name,
    required this.pricePerPerson,
    required this.kind,
  });

  bool get isFixed => kind == ItemKind.fijo;

  factory JamItem.fromMap(Map<String, dynamic> map) {
    return JamItem(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      pricePerPerson: (map['pricePerPerson'] as num? ?? 0).toDouble(),
      kind: ItemKind.values.byName(map['kind'] as String? ?? 'fijo'),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'pricePerPerson': pricePerPerson,
        'kind': kind.name,
      };
}
