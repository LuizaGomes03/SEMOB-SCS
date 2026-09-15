import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HourlyBarChartWidget extends StatelessWidget {
  final int totalPassageiros;

  const HourlyBarChartWidget({
    super.key,
    required this.totalPassageiros,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> slots = [
      {'label': '05-07h', 'pct': 0.18, 'peak': true},
      {'label': '07-09h', 'pct': 0.26, 'peak': true},
      {'label': '09-12h', 'pct': 0.08, 'peak': false},
      {'label': '12-14h', 'pct': 0.12, 'peak': false},
      {'label': '14-17h', 'pct': 0.09, 'peak': false},
      {'label': '17-19h', 'pct': 0.20, 'peak': true},
      {'label': '19-21h', 'pct': 0.05, 'peak': false},
      {'label': '21-23h', 'pct': 0.02, 'peak': false},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demanda por Faixa Horária de Operação',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Distribuição de munícipes transportados ao longo da escala diária',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: slots.map((slot) {
                  final double pct = slot['pct'];
                  final bool isPeak = slot['peak'];
                  final int count = (totalPassageiros * pct).round();

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isPeak ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: (120 * (pct / 0.28)).clamp(10.0, 120.0),
                            decoration: BoxDecoration(
                              color: isPeak ? AppColors.primary : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slot['label'],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isPeak ? FontWeight.bold : FontWeight.normal,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
