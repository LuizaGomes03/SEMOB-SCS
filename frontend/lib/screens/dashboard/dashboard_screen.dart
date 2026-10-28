import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/periodo.dart';
import '../../models/indicadores.dart';
import '../../services/operacao_api.dart';
import '../../widgets/common/erro_carregamento.dart';
import '../detalhes/detalhes_screen.dart';

class DashboardScreen extends StatefulWidget {
  final OperacaoApi api;
  final PeriodoConsulta periodo;
  final int versaoDados;
  final bool isRefreshing;
  final ValueChanged<InvestigationType> onOpenInvestigation;
  final Function(dynamic) onSelectAlert;

  const DashboardScreen({
    super.key,
    required this.api,
    required this.periodo,
    required this.versaoDados,
    required this.isRefreshing,
    required this.onOpenInvestigation,
    required this.onSelectAlert,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Indicadores> _indicadores;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.periodo != widget.periodo ||
        oldWidget.versaoDados != widget.versaoDados) {
      _buscar();
    }
  }

  void _buscar() {
    _indicadores = widget.api.indicadores(
      dataInicio: widget.periodo.inicio,
      dataFim: widget.periodo.fim,
      comparacao: widget.periodo.comparacao,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Indicadores>(
      future: _indicadores,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErroCarregamento(
            mensagem: snapshot.error.toString(),
            onTentarNovamente: () => setState(_buscar),
          );
        }
        return _buildConteudo(snapshot.data!);
      },
    );
  }

  // ================================================================
  // CONTEÚDO
  // ================================================================

  Widget _buildConteudo(Indicadores dados) {
    final variacao =
        dados.comparacao?.variacaoPercentual ?? const <String, double?>{};

    final cards = [
      _DashboardKpi(
        title: 'Quilometragem',
        valor: Formatters.number(dados.quilometragem),
        detalhe: 'km',
        variacao: variacao['quilometragem'],
        semDados: dados.diasOperacao == 0,
        icon: Icons.route,
        type: InvestigationType.quilometragem,
      ),
      _DashboardKpi(
        title: 'Viagens',
        valor: Formatters.number(dados.viagens),
        detalhe: 'de ${Formatters.number(dados.viagensProgramadas)} programadas',
        variacao: variacao['viagens'],
        semDados: dados.diasOperacao == 0,
        icon: Icons.directions_bus,
        type: InvestigationType.viagens,
      ),
      _DashboardKpi(
        title: 'Passageiros Pagantes',
        valor: Formatters.number(dados.passageirosPagantes),
        detalhe: 'passageiros',
        variacao: variacao['passageirosPagantes'],
        semDados: dados.diasPassageiros == 0,
        icon: Icons.people,
        type: InvestigationType.pagantes,
      ),
      _DashboardKpi(
        title: 'Gratuidades',
        valor: Formatters.number(dados.passageirosNaoPagantes),
        detalhe: 'passageiros não pagantes',
        variacao: variacao['passageirosNaoPagantes'],
        semDados: dados.diasPassageiros == 0,
        icon: Icons.card_membership,
        type: InvestigationType.gratuidades,
      ),
      _DashboardKpi(
        title: 'Financeiro',
        valor: Formatters.currency(dados.creditosVendidos),
        detalhe:
            'em créditos vendidos · ${Formatters.currency(dados.creditosUtilizados)} utilizados',
        variacao: variacao['creditosVendidos'],
        semDados: dados.diasFinanceiro == 0,
        icon: Icons.attach_money,
        type: InvestigationType.financeiro,
      ),
    ];

    final rotuloComparacao = _rotuloComparacao(dados.comparacao);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monitoramento da Operação',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Período: ${rotuloPeriodo(widget.periodo.inicio, widget.periodo.fim)}',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = Breakpoints.getKpiColumns(context);
              const spacing = 16.0;
              final cardWidth =
                  (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards.map((card) {
                  return SizedBox(
                    width: cardWidth,
                    height: 220,
                    child: _buildKpiCard(card, rotuloComparacao),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Selecione um indicador para abrir a investigação detalhada.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CARD
  // ================================================================

  Widget _buildKpiCard(_DashboardKpi item, String rotuloComparacao) {
    final variacao = item.semDados ? null : item.variacao;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isRefreshing
            ? null
            : () => widget.onOpenInvestigation(item.type),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 24),
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.semDados ? '—' : item.valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.semDados ? 'Sem dados neste período' : item.detalhe,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              // Sem base de comparação: some a linha inteira, nunca "0%".
              SizedBox(
                height: 18,
                child: variacao == null
                    ? null
                    : Row(
                        children: [
                          Icon(
                            variacao > 0
                                ? Icons.trending_up
                                : variacao < 0
                                    ? Icons.trending_down
                                    : Icons.trending_flat,
                            size: 17,
                            color: _corVariacao(variacao),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            Formatters.percentage(variacao),
                            style: TextStyle(
                              color: _corVariacao(variacao),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              rotuloComparacao,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _corVariacao(double v) => v > 0
      ? Colors.green
      : v < 0
          ? Colors.red
          : AppColors.textMuted;

  // ================================================================
  // RÓTULOS
  // ================================================================

  String _diaMes(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _rotuloComparacao(ComparacaoIndicadores? c) {
    if (c == null) return '';
    return c.dataInicio == c.dataFim
        ? 'vs. ${_diaMes(c.dataInicio)}'
        : 'vs. ${_diaMes(c.dataInicio)} – ${_diaMes(c.dataFim)}';
  }
}

// ==================================================================
// MODELO INTERNO DO CARD
// ==================================================================

class _DashboardKpi {
  final String title;
  final String valor;
  final String detalhe;
  final double? variacao;
  final bool semDados;
  final IconData icon;
  final InvestigationType type;

  const _DashboardKpi({
    required this.title,
    required this.valor,
    required this.detalhe,
    required this.variacao,
    required this.semDados,
    required this.icon,
    required this.type,
  });
}