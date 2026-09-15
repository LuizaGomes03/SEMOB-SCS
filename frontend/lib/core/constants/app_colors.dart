import 'package:flutter/material.dart';

/// Paleta Institucional SEMOB-SCS e Prefeitura de São Caetano do Sul
class AppColors {
  // Cores Principais Obrigatórias
  static const Color primary = Color(0xFF3D5D9A); // Azul institucional oficial
  static const Color primaryDark = Color(0xFF2B4370);
  static const Color primaryLight = Color(0xFFEBF1FA);
  static const Color background = Color(0xFFF5F7FA); // Fundo principal
  static const Color card = Color(0xFFFFFFFF); // Fundo dos cards

  // Textos
  static const Color textPrimary = Color(0xFF183B70); // Texto principal oficial
  static const Color textSecondary = Color(0xFF667085); // Texto secundário oficial
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Bordas e Divisores
  static const Color border = Color(0xFFE4E7EC);
  static const Color borderSubtle = Color(0xFFF2F4F7);
  static const Color focusRing = Color(0xFF3D5D9A);

  // Status Semânticos
  static const Color success = Color(0xFF10B981); // Verde sucesso
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successText = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B); // Amarelo/laranja atenção
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningText = Color(0xFF92400E);

  static const Color danger = Color(0xFFEF4444); // Vermelho crítico
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color dangerText = Color(0xFF991B1B);

  static const Color info = Color(0xFF3D5D9A); // Azul informativo
  static const Color infoBg = Color(0xFFEFF4FB);
  static const Color infoText = Color(0xFF183B70);

  // Alto Contraste (WCAG AAA)
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcCard = Color(0xFF121212);
  static const Color hcPrimary = Color(0xFFFFFF00); // Amarelo de alto contraste
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcBorder = Color(0xFFFFFFFF);
}
