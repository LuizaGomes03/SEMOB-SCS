import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Aviso discreto de que um período tem feriado. Só explica o número, não é um
/// alerta: por isso a cor de texto secundária, e não vermelho.
class AvisoFeriado extends StatelessWidget {
  /// Altura de cada linha em relação à fonte. Fica pública para quem precisa
  /// calcular quantas linhas cabem no espaço que tem.
  static const alturaDaLinha = 1.25;

  final String texto;
  final double tamanho;
  final int maxLinhas;

  const AvisoFeriado({
    super.key,
    required this.texto,
    this.tamanho = 12,
    this.maxLinhas = 2,
  });

  @override
  Widget build(BuildContext context) {
    // O Tooltip garante o texto inteiro quando as reticências cortarem o final.
    return Tooltip(
      message: texto,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: tamanho + 1,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              texto,
              maxLines: maxLinhas,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: tamanho,
                height: alturaDaLinha,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
