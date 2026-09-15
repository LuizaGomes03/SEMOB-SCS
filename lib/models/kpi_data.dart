enum TrendDirection { up, down, neutral }

class KpiData {
  final num value;
  final String unit;
  final double change;
  final TrendDirection trend;
  final String previousLabel;
  final String tooltip;

  const KpiData({
    required this.value,
    required this.unit,
    required this.change,
    required this.trend,
    required this.previousLabel,
    required this.tooltip,
  });
}
