import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/periodo.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/detalhes/detalhes_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/relatorio/relatorio_screen.dart';
import '../services/operacao_api.dart';
import '../widgets/common/erro_carregamento.dart';
import 'theme/app_theme.dart';

class SemobApp extends StatefulWidget {
  const SemobApp({super.key});

  @override
  State<SemobApp> createState() => _SemobAppState();
}

class _SemobAppState extends State<SemobApp> {
  String _selectedPeriod = 'hoje';
  DateTimeRange? _customRange;
  bool _isRefreshing = false;
  final OperacaoApi _api = OperacaoApi();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  DateTime? _ultimaData;
  String? _erroUltimaData;
  int _versaoDados = 0;

  @override
  void initState() {
    super.initState();
    _carregarUltimaData();
  }

  /// Devolve true se conseguiu uma data válida.
  Future<bool> _carregarUltimaData() async {
    try {
      final resposta = await _api.ultimaData();
      if (!mounted) return false;
      setState(() {
        _ultimaData = resposta.ultimaData;
        _erroUltimaData = resposta.ultimaData == null
            ? 'O banco ainda não tem dados de operação.'
            : null;
      });
      return resposta.ultimaData != null;
    } on ApiException catch (e) {
      if (!mounted) return false;
      setState(() => _erroUltimaData = e.mensagem);
      return false;
    }
  }

  String _dataReferenciaLabel() {
    final data = _ultimaData;
    return data == null
        ? 'Dados de referência: —'
        : 'Dados de referência: ${_formatDate(data)}';
  }

  InvestigationType? _selectedInvestigationType;

  double _textScale = 1.0;
  bool _isHighContrast = false;
  bool _isEnhancedFocus = false;

  void _openReport() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => RelatorioScreen(
          selectedPeriod: _selectedPeriod,
          periodLabel: _periodLabel(),
          dataReferenceLabel: _dataReferenciaLabel(),
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

    final ok = await _carregarUltimaData();

    if (!mounted) return;

    setState(() {
      _isRefreshing = false;
      if (ok) _versaoDados++;
    });

    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Dados atualizados com sucesso.'
              : 'Não foi possível atualizar: $_erroUltimaData',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectCustomPeriod(BuildContext dialogContext) async {
    final referencia = _ultimaData ?? DateTime.now();

    final initialRange =
        _customRange ??
        DateTimeRange(
          start: DateTime(
            referencia.year,
            referencia.month,
            referencia.day - 6,
          ),
          end: DateTime(referencia.year, referencia.month, referencia.day),
        );

    final range = await showDateRangePicker(
      context: dialogContext,
      firstDate: DateTime(2024),
      lastDate: _ultimaData ?? DateTime(referencia.year + 2),
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

    _navigatorKey.currentState?.push(
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
          onClose: () => _navigatorKey.currentState?.pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isHighContrast
        ? AppTheme.highContrastTheme
        : AppTheme.lightTheme;

    return MaterialApp(
      title: 'SEMOB-SCS',
      scaffoldMessengerKey: _messengerKey,
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: theme,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(_textScale)),
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
              onOpenReport: _openReport,
              showHomeControls: !isInvestigation,
              selectedPeriod: _selectedPeriod,
              customPeriodLabel: _periodLabel(),
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
            ),
            if (!isInvestigation)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 24, bottom: 2),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_note_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _dataReferenciaLabel(),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: isInvestigation
                  ? DetalhesScreen(
                      item: null,
                      type: _selectedInvestigationType,
                      onBack: _backToDashboard,
                    )
                  : _buildDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final ultimaData = _ultimaData;

    if (ultimaData == null) {
      if (_erroUltimaData == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return ErroCarregamento(
        mensagem: _erroUltimaData!,
        onTentarNovamente: () {
          setState(() => _erroUltimaData = null);
          _carregarUltimaData();
        },
      );
    }

    return DashboardScreen(
      api: _api,
      periodo: periodoDaConsulta(
        botao: _selectedPeriod,
        ultimaData: ultimaData,
        personalizado: _customRange,
      ),
      versaoDados: _versaoDados,
      isRefreshing: _isRefreshing,
      onOpenInvestigation: _openInvestigation,
      onSelectAlert: (_) {},
    );
  }
}

class _InstitutionalHeader extends StatelessWidget {
  final bool showHomeControls;
  final String selectedPeriod;
  final String customPeriodLabel;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(width: 24),
              Container(
                width: 1,
                height: 52,
                color: Colors.white.withValues(alpha: 0.28),
              ),
              const Spacer(),
              if (showHomeControls) ...[
                _buildControls(context),
                const SizedBox(width: 12),
              ],
              _buildProfileSettingsButton(),
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
        _periodSelector(context),
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
            side: BorderSide(color: Colors.white.withValues(alpha: 0.75)),
            minimumSize: const Size(122, 42),
            fixedSize: const Size(122, 42),
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
            side: BorderSide(color: Colors.white.withValues(alpha: 0.75)),
            minimumSize: const Size(122, 42),
            fixedSize: const Size(122, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSettingsButton({bool compact = false}) {
    return Tooltip(
      message: 'Perfil e Configurações',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onOpenSettings,
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: const Text(
              'LG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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
            const SizedBox(width: 6),
            _buildProfileSettingsButton(compact: true),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
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
              width: 108,
              height: 36,
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? const Color(0xFF3D5D9A) : Colors.white,
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
