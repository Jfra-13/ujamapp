/// Estado de pago de un participante dentro de un Jam (semáforo).
/// gris = no pagó · naranja = subió voucher, pendiente · verde = verificado.
enum PaymentStatus { gris, naranja, verde }

/// Un usuario "dentro del frasco": su participación en un Jam concreto.
/// Vive en la subcolección `jams/{jamId}/participants/{userId}`.
class Participant {
  final String id; // = userId
  final String name;
  final PaymentStatus status;
  final String? voucherUrl;

  /// Items opcionales elegidos por este miembro (los fijos son implícitos).
  final List<String> selectedItemIds;

  /// Monto a pagar = Σ pricePerPerson de items fijos + opcionales elegidos.
  /// Definitivo al confirmar; no cambia si entran nuevos miembros.
  final double amountDue;

  Participant({
    required this.id,
    required this.name,
    this.status = PaymentStatus.gris,
    this.voucherUrl,
    this.selectedItemIds = const [],
    this.amountDue = 0,
  });

  factory Participant.fromMap(String id, Map<String, dynamic> map) {
    return Participant(
      id: id,
      name: map['name'] as String? ?? '',
      status: PaymentStatus.values.byName(map['status'] as String? ?? 'gris'),
      voucherUrl: map['voucherUrl'] as String?,
      selectedItemIds:
          List<String>.from(map['selectedItemIds'] as List? ?? const []),
      amountDue: (map['amountDue'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'status': status.name,
        'voucherUrl': voucherUrl,
        'selectedItemIds': selectedItemIds,
        'amountDue': amountDue,
      };
}
