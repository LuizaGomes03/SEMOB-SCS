import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AccessibilityDialog extends StatelessWidget {
  final double textScale;
  final bool isHighContrast;
  final bool isEnhancedFocus;
  final Function(double) onTextScaleChange;
  final VoidCallback onToggleHighContrast;
  final VoidCallback onToggleEnhancedFocus;

  const AccessibilityDialog({
    super.key,
    required this.textScale,
    required this.isHighContrast,
    required this.isEnhancedFocus,
    required this.onTextScaleChange,
    required this.onToggleHighContrast,
    required this.onToggleEnhancedFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: const [
                  Icon(Icons.accessibility_new, color: AppColors.primary, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Menu de Acessibilidade Digital',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajustes de contraste, escala tipográfica e navegação assistiva em conformidade com as diretrizes e-MAG / WCAG 2.1.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Controle de Tamanho da Fonte
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tamanho da Fonte',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Escala atual: ${(textScale * 100).toInt()}%',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton.outlined(
                          icon: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () => onTextScaleChange((textScale - 0.1).clamp(0.8, 1.4)),
                          tooltip: 'Diminuir tamanho da fonte',
                        ),
                        const SizedBox(width: 4),
                        IconButton.outlined(
                          icon: const Text('A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () => onTextScaleChange(1.0),
                          tooltip: 'Restaurar tamanho padrão da fonte',
                        ),
                        const SizedBox(width: 4),
                        IconButton.outlined(
                          icon: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: () => onTextScaleChange((textScale + 0.1).clamp(0.8, 1.4)),
                          tooltip: 'Aumentar tamanho da fonte',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Alto Contraste
              SwitchListTile(
                title: const Text('Alto Contraste (Preto e Amarelo)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Maximiza o contraste para baixa visão ou fotossensibilidade', style: TextStyle(fontSize: 11)),
                value: isHighContrast,
                activeColor: AppColors.primary,
                onChanged: (_) => onToggleHighContrast(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),

              // Foco Reforçado
              SwitchListTile(
                title: const Text('Foco Visível Reforçado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Destaca elementos ativos durante a navegação por teclado', style: TextStyle(fontSize: 11)),
                value: isEnhancedFocus,
                activeColor: AppColors.primary,
                onChanged: (_) => onToggleEnhancedFocus(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              const SizedBox(height: 12),

              // VLibras Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.sign_language, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Interface preparada para integração com o VLibras (Língua Brasileira de Sinais).',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Botão Fechar
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Concluído'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
