import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../mock/mock_transporte_data.dart';

class EvolutionChartWidget extends StatefulWidget {
  const EvolutionChartWidget({super.key});

  @override
  State<EvolutionChartWidget> createState() => _EvolutionChartWidgetState();
}

class _EvolutionChartWidgetState extends State<EvolutionChartWidget> {
  String _selectedMetric = 'km';

  @override
  Widget build(BuildContext context) {
    final history = MockTransporteData.historicoDiario;

    List<double> values;
    String unit;
    Color color;

    switch (_selectedMetric) {
      case 'viagens':
        values = history.map((d) => (d['viagens'] as num).toDouble()).toList();
        unit = 'viagens';
        color = const Color(0xFF0284C7);
        break;
      case 'passageiros':
        values = history.map((d) => (d['pagantes'] as num).toDouble()).toList();
        unit = 'pass.';
        color = AppColors.success;
        break;
      case 'financeiro':
        values = history.map((d) => (d['financeiro'] as num).toDouble()).toList();
        unit = 'R\$';
        color = const Color(0xFF8B5CF6);
        break;
      default:
        values = history.map((d) => (d['km'] as num).toDouble()).toList();
        unit = 'km';
        color = AppColors.primary;
    }

    final labels = history.map((d) => d['label'] as String).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho e Seletor de Métrica
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evolução da Operação Municipal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Acompanhamento diário dos indicadores consolidados',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildMetricChip('km', 'Quilometragem'),
                          const SizedBox(width: 6),
                          _buildMetricChip('viagens', 'Viagens'),
                          const SizedBox(width: 6),
                          _buildMetricChip('passageiros', 'Passageiros'),
                          const SizedBox(width: 6),
                          _buildMetricChip('financeiro', 'Financeiro'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Gráfico em Canvas Responsivo
            SizedBox(
              height: 240,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineChartPainter(
                  values: values,
                  labels: labels,
                  color: color,
                  unit: unit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String key, String label) {
    final isSelected = _selectedMetric == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedMetric = key;
          });
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.borderSubtle,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final String unit;

  _LineChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double minVal = values.reduce((a, b) => a < b ? a : b) * 0.95;
    final double maxVal = values.reduce((a, b) => a > b ? a : b) * 1.05;
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final double chartBottom = size.height - 30;
    final double chartHeight = chartBottom - 20;
    final double chartWidth = size.width - 20;

    final paintGrid = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 1;

    // Linhas de Grade Horizontais
    for (int i = 0; i <= 3; i++) {
      final y = chartBottom - (chartHeight / 3 * i);
      canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), paintGrid);
    }

    final double stepX = chartWidth / (values.length - 1);
    final List<Offset> points = [];

    for (int i = 0; i < values.length; i++) {
      final x = 10 + (i * stepX);
      final normalized = (values[i] - minVal) / range;
      final y = chartBottom - (normalized * chartHeight);
      points.add(Offset(x, y));
    }

    // Área Sombreada sob a Curva
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.35), color.withOpacity(0.02)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartBottom));

    final pathFill = Path();
    pathFill.moveTo(points.first.dx, chartBottom);
    for (var pt in points) {
      pathFill.lineTo(pt.dx, pt.dy);
    }
    pathFill.lineTo(points.last.dx, chartBottom);
    pathFill.close();
    canvas.drawPath(pathFill, fillPaint);

    // Linha Principal
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathLine = Path();
    pathLine.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      pathLine.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(pathLine, linePaint);

    // Pontos e Textos de Eixo
    final pointPaint = Paint()..color = color;
    final pointInnerPaint = Paint()..color = Colors.white;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      // Ponto
      canvas.drawCircle(pt, 5, pointPaint);
      canvas.drawCircle(pt, 2.5, pointInnerPaint);

      // Label do Eixo X
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pt.dx - (textPainter.width / 2), size.height - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
