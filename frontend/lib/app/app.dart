import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/responsive/breakpoints.dart';
import '../mock/mock_transporte_data.dart';
import '../models/operacao_item.dart';
import '../models/anomalia_item.dart';
import '../models/notificacao_item.dart';
import 'theme/app_theme.dart';

import '../widgets/sidebar/app_sidebar.dart';
import '../widgets/header/app_header.dart';
import '../widgets/dialogs/notification_dialog.dart';
import '../widgets/dialogs/accessibility_dialog.dart';

import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/operacao/operacao_screen.dart';
import '../screens/passageiros/passageiros_screen.dart';
import '../screens/financeiro/financeiro_screen.dart';
import '../screens/anomalias/anomalias_screen.dart';
import '../screens/relatorios/relatorios_screen.dart';
import '../screens/detalhes/detalhes_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';

class SemobApp extends StatefulWidget {
  const SemobApp({super.key});

  @override
  State<SemobApp> createState() => _SemobAppState();
}

class _SemobAppState extends State<SemobApp> {
  // Estado de Autenticação
  bool _isAuthenticated = true; // Inicia true para agilizar navegação, permite logout completo

  // Navegação
  int _currentScreenIndex = 0;
  int _previousScreenIndex = 0;
  OperacaoItem? _selectedDetailItem;
  AnomaliaItem? _selectedAlertItem;

  // Filtros Globais
  String _selectedPeriod = 'hoje';
  bool _isRefreshing = false;
  bool _isSidebarCollapsed = false;

  // Acessibilidade Digital
  double _textScale = 1.0;
  bool _isHighContrast = false;
  bool _isEnhancedFocus = false;

  // Notificações
  late List<NotificacaoItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(MockTransporteData.notificacoes);
  }

  void _navigateTo(int index) {
    if (_currentScreenIndex != index) {
      setState(() {
        _previousScreenIndex = _currentScreenIndex;
        _currentScreenIndex = index;
      });
    }
  }

  void _openDetail(OperacaoItem item) {
    setState(() {
      _selectedDetailItem = item;
      _previousScreenIndex = _currentScreenIndex;
      _currentScreenIndex = 7; // Tela de detalhes
    });
  }

  void _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados sincronizados com a telemetria Smart Data com sucesso.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _openNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => NotificationDialog(
        notifications: _notifications,
        onNavigate: (dest) => _navigateTo(dest),
        onMarkAllAsRead: () {
          setState(() {
            for (var n in _notifications) {
              n.read = true;
            }
          });
          Navigator.of(ctx).pop();
        },
        onClearAll: () {
          setState(() => _notifications.clear());
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _openAccessibilityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AccessibilityDialog(
        textScale: _textScale,
        isHighContrast: _isHighContrast,
        isEnhancedFocus: _isEnhancedFocus,
        onTextScaleChange: (val) => setState(() => _textScale = val),
        onToggleHighContrast: () => setState(() => _isHighContrast = !_isHighContrast),
        onToggleEnhancedFocus: () => setState(() => _isEnhancedFocus = !_isEnhancedFocus),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isHighContrast ? AppTheme.highContrastTheme : AppTheme.lightTheme;

    return MaterialApp(
      title: 'Dashboard de Operação — SEMOB-SCS',
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
      home: _isAuthenticated ? _buildAppScaffold() : LoginScreen(
        onLoginSuccess: () => setState(() {
          _isAuthenticated = true;
          _currentScreenIndex = 0;
        }),
      ),
    );
  }

  Widget _buildAppScaffold() {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Builder(
      builder: (context) {
        final isMobile = Breakpoints.isMobile(context);

        // Metadados da tela atual
        final screenTitles = [
          {'title': 'Dashboard de Operação', 'sub': 'Visão consolidada da operação de transporte público municipal'},
          {'title': 'Operação de Transporte', 'sub': 'Análise detalhada de quilometragem e viagens por linha municipal'},
          {'title': 'Passageiros e Demanda', 'sub': 'Acompanhamento de passageiros pagantes e gratuidades'},
          {'title': 'Informações Financeiras', 'sub': 'Apuração tarifária consolidada (dados demonstrativos)'},
          {'title': 'Anomalias e Alertas', 'sub': 'Auditoria de desvios operacionais e inconsistências na telemetria'},
          {'title': 'Relatórios da Operação', 'sub': 'Consolidação periódica e exportação para gestores'},
          {'title': 'Perfil e Configurações', 'sub': 'Identificação do gestor e preferências do sistema'},
          {'title': 'Detalhamento da Operação', 'sub': 'Análise aprofundada da escala e distribuição de passageiros'},
        ];

        final currentMeta = screenTitles[_currentScreenIndex.clamp(0, screenTitles.length - 1)];
        final unreadCount = _notifications.where((n) => !n.read).length;

        // Conteúdo da tela ativa
        Widget activeBody;
        switch (_currentScreenIndex) {
          case 1:
            activeBody = OperacaoScreen(onSelectDetail: _openDetail);
            break;
          case 2:
            activeBody = PassageirosScreen(selectedPeriod: _selectedPeriod);
            break;
          case 3:
            activeBody = FinanceiroScreen(selectedPeriod: _selectedPeriod);
            break;
          case 4:
            activeBody = AnomaliasScreen(initialSelectedAlert: _selectedAlertItem);
            break;
          case 5:
            activeBody = const RelatoriosScreen();
            break;
          case 6:
            activeBody = ConfiguracoesScreen(
              textScale: _textScale,
              isHighContrast: _isHighContrast,
              isEnhancedFocus: _isEnhancedFocus,
              onTextScaleChange: (v) => setState(() => _textScale = v),
              onToggleHighContrast: () => setState(() => _isHighContrast = !_isHighContrast),
              onToggleEnhancedFocus: () => setState(() => _isEnhancedFocus = !_isEnhancedFocus),
              onLogout: () => setState(() => _isAuthenticated = false),
            );
            break;
          case 7:
            activeBody = DetalhesScreen(
              item: _selectedDetailItem,
              onBack: () => _navigateTo(_previousScreenIndex),
            );
            break;
          default:
            activeBody = DashboardScreen(
              selectedPeriod: _selectedPeriod,
              isRefreshing: _isRefreshing,
              onNavigate: (dest) => _navigateTo(dest),
              onSelectAlert: (alert) {
                setState(() => _selectedAlertItem = alert);
                _navigateTo(4);
              },
            );
        }

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppColors.background,
          // Drawer no Mobile
          drawer: isMobile
              ? Drawer(
                  child: AppSidebar(
                    selectedIndex: _currentScreenIndex,
                    onItemSelected: _navigateTo,
                    onLogout: () => setState(() => _isAuthenticated = false),
                    isDrawer: true,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                // Sidebar Fixa/Recolhível no Desktop/Tablet
                if (!isMobile)
                  AppSidebar(
                    selectedIndex: _currentScreenIndex,
                    onItemSelected: _navigateTo,
                    isCollapsed: _isSidebarCollapsed,
                    onToggleCollapse: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                    onLogout: () => setState(() => _isAuthenticated = false),
                  ),

                // Área de Conteúdo Principal
                Expanded(
                  child: Column(
                    children: [
                      AppHeader(
                        title: currentMeta['title']!,
                        subtitle: currentMeta['sub']!,
                        selectedPeriod: _selectedPeriod,
                        onPeriodSelected: (p) => setState(() => _selectedPeriod = p),
                        onRefresh: _handleRefresh,
                        isRefreshing: _isRefreshing,
                        onOpenNotifications: _openNotificationsDialog,
                        unreadNotifications: unreadCount,
                        onOpenAccessibility: _openAccessibilityDialog,
                        onOpenProfile: () => _navigateTo(6),
                        onOpenDrawer: () => scaffoldKey.currentState?.openDrawer(),
                      ),
                      Expanded(child: activeBody),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Comportamento de rolagem aprimorado para Web, Desktop e Mobile (Touch + Mouse drag)
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
