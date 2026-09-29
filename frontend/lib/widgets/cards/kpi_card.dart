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

  Color _statusColor() {
    switch (data.status) {
      case KpiStatus.normal:
        return AppColors.successText;
      case KpiStatus.atencao:
        return AppColors.warning;
      case KpiStatus.critico:
        return AppColors.danger;
    }
  }

  Color _statusBackground() {
    switch (data.status) {
      case KpiStatus.normal:
        return AppColors.successBg;
      case KpiStatus.atencao:
        return AppColors.warningBg;
      case KpiStatus.critico:
        return AppColors.dangerBg;
    }
  }

  String _statusLabel() {
    switch (data.status) {
      case KpiStatus.normal:
        return 'NORMAL';
      case KpiStatus.atencao:
        return 'ATENÇÃO';
      case KpiStatus.critico:
        return 'CRÍTICO';
    }
  }

  IconData _statusIcon() {
    switch (data.status) {
      case KpiStatus.normal:
        return Icons.check_circle_outline;
      case KpiStatus.atencao:
        return Icons.warning_amber_rounded;
      case KpiStatus.critico:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonLoader(height: 18, width: 140),
              SizedBox(height: 24),
              SkeletonLoader(height: 42, width: 180),
              SizedBox(height: 18),
              SkeletonLoader(height: 18, width: 120),
            ],
          ),
        ),
      );
    }

    final statusColor = _statusColor();
    final statusBackground = _statusBackground();

    final isPositive = data.change > 0;
    final isNegative = data.change < 0;

    final trendColor = isPositive
        ? AppColors.successText
        : (isNegative
            ? AppColors.dangerText
            : AppColors.textSecondary);

    final formattedValue = data.unit == 'R\$'
        ? Formatters.currency(data.value)
        : Formatters.number(data.value);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO + ÍCONE
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // VALOR PRINCIPAL
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
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (data.unit.isNotEmpty && data.unit != 'R\$') ...[
                      const SizedBox(width: 7),
                      Text(
                        data.unit,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // STATUS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusIcon(),
                      size: 17,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // VARIAÇÃO
              Row(
                children: [
                  Icon(
                    isPositive
                        ? Icons.arrow_upward
                        : (isNegative
                            ? Icons.arrow_downward
                            : Icons.remove),
                    size: 15,
                    color: trendColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.percentage(data.change),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: trendColor,
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