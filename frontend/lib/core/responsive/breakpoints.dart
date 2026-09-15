import 'package:flutter/material.dart';

/// Padrões de Responsividade e Breakpoints do Sistema SEMOB-SCS
class Breakpoints {
  static const double mobileMax = 767.0;
  static const double tabletMin = 768.0;
  static const double desktopMin = 1200.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletMin;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletMin && width < desktopMin;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMin;

  static int getKpiColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 960) return 2;
    if (width < 1400) return 3;
    return 5;
  }
}
