import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;

    switch (status.toLowerCase()) {
      case 'regular':
      case 'resolvido':
      case 'auditado':
      case 'sucesso':
        bg = AppColors.successBg;
        text = AppColors.successText;
        border = AppColors.success.withOpacity(0.3);
        break;
      case 'atenção':
      case 'pendente':
      case 'em consolidação':
        bg = AppColors.warningBg;
        text = AppColors.warningText;
        border = AppColors.warning.withOpacity(0.3);
        break;
      case 'crítico':
      case 'urgente':
      case 'cancelado':
        bg = AppColors.dangerBg;
        text = AppColors.dangerText;
        border = AppColors.danger.withOpacity(0.3);
        break;
      default:
        bg = AppColors.infoBg;
        text = AppColors.infoText;
        border = AppColors.primary.withOpacity(0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
