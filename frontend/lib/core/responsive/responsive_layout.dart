import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Construtor de Layout Responsivo que se adapta a Mobile, Tablet e Desktop
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktopMin) {
          return desktop;
        } else if (constraints.maxWidth >= Breakpoints.tabletMin) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
