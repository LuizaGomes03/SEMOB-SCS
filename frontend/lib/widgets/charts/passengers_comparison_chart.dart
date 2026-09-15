import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../mock/mock_transporte_data.dart';

class PassengersComparisonChartWidget extends StatelessWidget {
  const PassengersComparisonChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final history = MockTransporteData.historicoDiario;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho e Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Passageiros no Período',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Comparativo entre passageiros pagantes e gratuidades',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Legenda Responsiva
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _buildLegendItem('Pagantes', AppColors.primary),
                _buildLegendItem('Não Pagantes (Gratuidades)', AppColors.warning),
              ],
            ),
            const SizedBox(height: 16),

            // Gráfico de Barras em Canvas
            SizedBox(
              height: 220,
              width: double.infinity,
              child: CustomPaint(
                painter: _BarChartPainter(history: history),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> history;

  _BarChartPainter({required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final double maxVal = 40000;
    final double chartBottom = size.height - 25;
    final double chartHeight = chartBottom - 15;
    final double groupWidth = (size.width - 20) / history.length;
    final double barWidth = (groupWidth * 0.35).clamp(8.0, 24.0);

    final paintPagantes = Paint()..color = AppColors.primary;
    final paintNaoPagantes = Paint()..color = AppColors.warning;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      final pagantes = (item['pagantes'] as num).toDouble();
      final naoPagantes = (item['naoPagantes'] as num).toDouble();

      final groupCenterX = 10 + (i * groupWidth) + (groupWidth / 2);

      // Barra Pagantes
      final hPagantes = (pagantes / maxVal) * chartHeight;
      final rectPagantes = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          groupCenterX - barWidth - 2,
          chartBottom - hPagantes,
          barWidth,
          hPagantes,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rectPagantes, paintPagantes);

      // Barra Não Pagantes
      final hNaoPagantes = (naoPagantes / maxVal) * chartHeight;
      final rectNaoPagantes = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          groupCenterX + 2,
          chartBottom - hNaoPagantes,
          barWidth,
          hNaoPagantes,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rectNaoPagantes, paintNaoPagantes);

      // Label Eixo X
      textPainter.text = TextSpan(
        text: item['label'],
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(groupCenterX - (textPainter.width / 2), size.height - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => false;
}
