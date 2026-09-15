import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../mock/mock_transporte_data.dart';

class PassengersDonutChartWidget extends StatelessWidget {
  const PassengersDonutChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = MockTransporteData.categoriasPassageiros;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribuição por Modalidade de Benefício',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Detalhamento entre pagantes e categorias de gratuidade regulamentada',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Layout Adaptável de Donut + Legenda
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 450;
                final chartWidget = SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _DonutChartPainter(categories: categories),
                  ),
                );

                final legendWidget = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.map((cat) {
                    final color = Color(cat['color'] as int);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat['name'],
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      Center(child: chartWidget),
                      const SizedBox(height: 16),
                      legendWidget,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    chartWidget,
                    Flexible(child: legendWidget),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;

  _DonutChartPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = categories.fold(0, (sum, item) => sum + (item['count'] as num));
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 26.0;

    double startAngle = -math.pi / 2;

    for (var cat in categories) {
      final sweepAngle = ((cat['count'] as num) / total) * 2 * math.pi;
      final paint = Paint()
        ..color = Color(cat['color'] as int)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => false;
}
