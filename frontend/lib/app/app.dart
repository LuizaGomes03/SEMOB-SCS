
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../mock/mock_transporte_data.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/detalhes/detalhes_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/relatorio/relatorio_screen.dart';
import 'theme/app_theme.dart';

class SemobApp extends StatefulWidget {
  const SemobApp({super.key});

  @override
  State<SemobApp> createState() => _SemobAppState();
}

class _SemobAppState extends State<SemobApp> {
  String _selectedPeriod = 'hoje';
  DateTimeRange? _customRange;
  DateTime _lastDataDate = DateTime.now().subtract(const Duration(days: 1));
  bool _isRefreshing = false;

  InvestigationType? _selectedInvestigationType;

  double _textScale = 1.0;
  bool _isHighContrast = false;
  bool _isEnhancedFocus = false;



  void _openReport(BuildContext navigatorContext) {
    Navigator.of(navigatorContext).push(
      MaterialPageRoute(
        builder: (_) => RelatorioScreen(
          selectedPeriod: _selectedPeriod,
          periodLabel: _periodLabel(),
          dataReferenceLabel: 'Dados de referência: ${_formatDate(_lastDataDate)}',
        ),
      ),
    );
  }

  void _openInvestigation(InvestigationType type) {
    setState(() {
      _selectedInvestigationType = type;
    });
  }

  void _backToDashboard() {
    setState(() {
      _selectedInvestigationType = null;
    });
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isRefreshing = false;
      _lastDataDate = DateTime.now().subtract(const Duration(days: 1));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados atualizados com sucesso.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectCustomPeriod(BuildContext dialogContext) async {
    final now = DateTime.now();

    final initialRange = _customRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, now.day - 6),
          end: DateTime(now.year, now.month, now.day),
        );

    final range = await showDateRangePicker(
      context: dialogContext,
      firstDate: DateTime(2024),
      lastDate: DateTime(now.year + 2),
      initialDateRange: initialRange,
      helpText: 'Selecione o período da operação',
      saveText: 'Aplicar',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF3D5D9A),
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range == null) return;

    setState(() {
      _customRange = range;
      _selectedPeriod = 'personalizado';
      _selectedInvestigationType = null;
    });
  }

  String _periodLabel() {
    switch (_selectedPeriod) {
      case 'semana':
        return 'Semana';
      case 'mes':
      case 'mês':
        return 'Mês';
      case 'personalizado':
        if (_customRange == null) return 'Personalizado';
        return '${_formatDate(_customRange!.start)} – ${_formatDate(_customRange!.end)}';
      default:
        return 'Hoje';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  void _openSettings() {
    setState(() {
      _selectedInvestigationType = null;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfiguracoesScreen(
          textScale: _textScale,
          isHighContrast: _isHighContrast,
          isEnhancedFocus: _isEnhancedFocus,
          onTextScaleChange: (value) {
            setState(() => _textScale = value);
          },
          onToggleHighContrast: () {
            setState(() => _isHighContrast = !_isHighContrast);
          },
          onToggleEnhancedFocus: () {
            setState(() => _isEnhancedFocus = !_isEnhancedFocus);
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        _isHighContrast ? AppTheme.highContrastTheme : AppTheme.lightTheme;

    return MaterialApp(
      title: 'SEMOB-SCS',
      debugShowCheckedModeBanner: false,
      theme: theme,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_textScale),
          ),
          child: child!,
        );
      },
      home: _buildShell(),
    );
  }

  Widget _buildShell() {
    final isInvestigation = _selectedInvestigationType != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _InstitutionalHeader(
              showHomeControls: !isInvestigation,
              selectedPeriod: _selectedPeriod,

              customPeriodLabel: _periodLabel(),
              dataReferenceLabel: 'Dados de referência: ${_formatDate(_lastDataDate)}',
              isRefreshing: _isRefreshing,
              onPeriodSelected: (period) {
                if (period == 'personalizado') {
                  return;
                }

                setState(() {
                  _selectedPeriod = period;
                  _customRange = null;
                  _selectedInvestigationType = null;
                });
              },
              onRefresh: _handleRefresh,
              onOpenCustomPeriod: (dialogContext) =>
                  _selectCustomPeriod(dialogContext),
              onOpenSettings: _openSettings,
              onOpenReport: () => _openReport(context),
            ),
            Expanded(
              child: isInvestigation
                  ? DetalhesScreen(
                      item: null,
                      type: _selectedInvestigationType,
                      onBack: _backToDashboard,
                    )
                  : DashboardScreen(
                      selectedPeriod: _selectedPeriod,
                      isRefreshing: _isRefreshing,
                      onOpenInvestigation: _openInvestigation,
                      onSelectAlert: (_) {},
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstitutionalHeader extends StatelessWidget {
  final bool showHomeControls;
  final String selectedPeriod;
  final String customPeriodLabel;
  final String dataReferenceLabel;
  final bool isRefreshing;
  final ValueChanged<String> onPeriodSelected;
  final VoidCallback onRefresh;
  final ValueChanged<BuildContext> onOpenCustomPeriod;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenReport;

  const _InstitutionalHeader({
    required this.showHomeControls,
    required this.selectedPeriod,
    required this.customPeriodLabel,
    required this.dataReferenceLabel,
    required this.isRefreshing,
    required this.onPeriodSelected,
    required this.onRefresh,
    required this.onOpenCustomPeriod,
    required this.onOpenSettings,
    required this.onOpenReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF3D5D9A),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;

          if (compact) {
            return _buildCompactHeader(context);
          }

          return Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 24),
              Container(
                width: 1,
                height: 52,
                color: Colors.white.withValues(alpha: 0.28),
              ),
              const Spacer(),
              if (showHomeControls)
                _buildControls(context)
              else
                IconButton(
                  tooltip: 'Configurações',
                  onPressed: onOpenSettings,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              const SizedBox(width: 8),
              _profileCircle(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 230,
      height: 54,
      child: Image.asset(
        'assets/images/logo_semob_scs.png',
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        errorBuilder: (_, __, ___) {
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance, color: Colors.white, size: 34),
              SizedBox(width: 10),
              Text(
                'SEMOB-SCS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _periodSelector(context),
            const SizedBox(height: 3),
            Text(
              dataReferenceLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: isRefreshing
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Atualizar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.75),
            ),
            minimumSize: const Size(126, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onOpenReport,
          icon: const Icon(Icons.description_outlined, size: 18),
          label: const Text('Relatório'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.75),
            ),
            minimumSize: const Size(122, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Configurações',
          onPressed: onOpenSettings,
          icon: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: 25,
          ),
        ),
      ],
    );
  }

  Widget _profileCircle() {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: const Text(
        'LG',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _buildLogo()),
            if (showHomeControls)
              IconButton(
                tooltip: 'Gerar relatório',
                onPressed: onOpenReport,
                icon: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                ),
              ),
            if (!showHomeControls)
              IconButton(
                tooltip: 'Configurações',
                onPressed: onOpenSettings,
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                ),
              ),
            const SizedBox(width: 4),
            _profileCircle(),
          ],
        ),
        if (showHomeControls) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildControls(context),
          ),
        ],
      ],
    );
  }

  Widget _periodSelector(BuildContext context) {
    final options = const [
      ('hoje', 'Hoje'),
      ('semana', 'Semana'),
      ('mes', 'Mês'),
      ('personalizado', 'Personalizado'),
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final selected = selectedPeriod == option.$1;

          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (option.$1 == 'personalizado') {
                onOpenCustomPeriod(context);
              } else {
                onPeriodSelected(option.$1);
              }
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 70),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selected && option.$1 == 'personalizado'
                    ? customPeriodLabel
                    : option.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF3D5D9A)
                      : Colors.white,
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
