class Jam {
  final String id;
  final String title;
  final DateTime deadline;
  final double totalBudget;
  // Lista de IDs de usuarios que están "dentro del frasco"
  final List<String> participants;

  Jam({
    required this.id,
    required this.title,
    required this.deadline,
    required this.totalBudget,
    required this.participants,
  });
}