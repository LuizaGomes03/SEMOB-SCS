import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/kpi_data.dart';
import '../common/skeleton_loader.dart';

class KpiCardWidget extends StatelessWidget {
  final String title;
  final KpiData data;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const KpiCardWidget({
    super.key,
    required this.title,
    required this.data,
    required this.icon,
    this.iconBg = AppColors.primaryLight,
    this.iconColor = AppColors.primary,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 16, width: 100),
              SizedBox(height: 12),
              SkeletonLoader(height: 28, width: 140),
              SizedBox(height: 12),
              SkeletonLoader(height: 14, width: 120),
            ],
          ),
        ),
      );
    }

    final isPositive = data.change > 0;
    final isNegative = data.change < 0;
    final trendColor = isPositive
        ? AppColors.successText
        : (isNegative ? AppColors.dangerText : AppColors.textSecondary);
    final trendBg = isPositive
        ? AppColors.successBg
        : (isNegative ? AppColors.dangerBg : AppColors.borderSubtle);

    final formattedValue = data.unit == 'R\$'
        ? Formatters.currency(data.value)
        : Formatters.number(data.value);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header do Card: Título, Tooltip e Ícone
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: data.tooltip,
                          child: const Icon(
                            Icons.help_outline,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Valor Principal e Unidade
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedValue,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (data.unit.isNotEmpty && data.unit != 'R\$') ...[
                      const SizedBox(width: 4),
                      Text(
                        data.unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Rodapé: Variação e Comparação
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: trendBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_outward
                              : (isNegative ? Icons.arrow_downward : Icons.remove),
                          size: 12,
                          color: trendColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.percentage(data.change),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data.previousLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
