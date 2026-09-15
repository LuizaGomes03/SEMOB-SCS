class AnomaliaItem {
  final String id;
  final String code;
  final String type;
  final String title;
  final String description;
  final String indicator;
  final String line;
  final String date;
  final String severity; // 'Crítico', 'Atenção'
  String status; // 'Pendente', 'Em Análise', 'Resolvido'
  final String expectedValue;
  final String actualValue;
  String impact;
  final String actionRequired;

  AnomaliaItem({
    required this.id,
    required this.code,
    required this.type,
    required this.title,
    required this.description,
    required this.indicator,
    required this.line,
    required this.date,
    required this.severity,
    required this.status,
    required this.expectedValue,
    required this.actualValue,
    required this.impact,
    required this.actionRequired,
  });
}
