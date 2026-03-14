enum PaymentStatus { gris, naranja, verde }

class Participant {
  final String id;
  final String name;
  final PaymentStatus status;
  final String? voucherUrl;

  Participant({
    required this.id,
    required this.name,
    this.status = PaymentStatus.gris,
    this.voucherUrl,
  });
}