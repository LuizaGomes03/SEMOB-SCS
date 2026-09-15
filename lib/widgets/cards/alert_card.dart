import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/anomalia_item.dart';
import '../common/status_badge.dart';

class AlertCardWidget extends StatelessWidget {
  final AnomaliaItem alert;
  final VoidCallback onAudit;

  const AlertCardWidget({
    super.key,
    required this.alert,
    required this.onAudit,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.severity == 'Crítico';
    final borderColor = isCritical ? AppColors.danger : AppColors.warning;
    final bgColor = isCritical ? AppColors.dangerBg : AppColors.warningBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topo do card: Severidade, Data e Status
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: isCritical ? AppColors.danger : AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    StatusBadge(status: alert.severity),
                  ],
                ),
                Text(
                  alert.date,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Título e Descrição
            Text(
              alert.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              alert.description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),

            // Linha e Parâmetros
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Linha Afetada',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        Text(
                          alert.line,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aferido vs Esperado',
                          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        Text(
                          '${alert.actualValue} / ${alert.expectedValue}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCritical ? AppColors.dangerText : AppColors.warningText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Rodapé com Status e Ação
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                StatusBadge(status: alert.status),
                TextButton.icon(
                  onPressed: onAudit,
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                  label: const Text('Auditar Ocorrência', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
