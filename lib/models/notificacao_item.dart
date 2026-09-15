class NotificacaoItem {
  final String id;
  final String category; // 'Alertas', 'Informações', 'Atualizações'
  final String title;
  final String description;
  final String time;
  bool read;
  final String severity; // 'danger', 'warning', 'info', 'success'
  final int destinationIndex;

  NotificacaoItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.time,
    this.read = false,
    required this.severity,
    required this.destinationIndex,
  });
}
