import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/kpi_data.dart';
import '../detalhes/detalhes_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String selectedPeriod;
  final bool isRefreshing;
  final ValueChanged<InvestigationType> onOpenInvestigation;
  final Function(dynamic) onSelectAlert;

  const DashboardScreen({
    super.key,
    required this.selectedPeriod,
    required this.isRefreshing,
    required this.onOpenInvestigation,
    required this.onSelectAlert,
  });

  @override
  Widget build(BuildContext context) {
    final kpis = MockTransporteData.getKpisByPeriod(
      selectedPeriod,
    );

    final km = kpis['km'] as KpiData;
    final viagens = kpis['viagens'] as KpiData;
    final pagantes = kpis['pagantes'] as KpiData;
    final naoPagantes = kpis['naoPagantes'] as KpiData;
    final financeiro = kpis['financeiro'] as KpiData;

    final cards = [
      _DashboardKpi(
        title: 'Quilometragem',
        data: km,
        icon: Icons.route,
        type: InvestigationType.quilometragem,
      ),
      _DashboardKpi(
        title: 'Viagens',
        data: viagens,
        icon: Icons.directions_bus,
        type: InvestigationType.viagens,
      ),
      _DashboardKpi(
        title: 'Passageiros Pagantes',
        data: pagantes,
        icon: Icons.people,
        type: InvestigationType.pagantes,
      ),
      _DashboardKpi(
        title: 'Gratuidades',
        data: naoPagantes,
        icon: Icons.card_membership,
        type: InvestigationType.gratuidades,
      ),
      _DashboardKpi(
        title: 'Financeiro',
        data: financeiro,
        icon: Icons.attach_money,
        type: InvestigationType.financeiro,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // CABEÇALHO
          // ==========================================================

          const Text(
            'Monitoramento da Operação',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Visão rápida dos principais indicadores do transporte municipal',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 22),

          // ==========================================================
          // LEGENDA
          // ==========================================================

          Row(
            children: [
              _buildLegend(
                color: Colors.green,
                label: 'Normal',
              ),
              const SizedBox(width: 18),
              _buildLegend(
                color: Colors.orange,
                label: 'Atenção',
              ),
              const SizedBox(width: 18),
              _buildLegend(
                color: Colors.red,
                label: 'Crítico',
              ),
            ],
          ),

          const SizedBox(height: 26),

          // ==========================================================
          // CARDS
          // ==========================================================

          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  Breakpoints.getKpiColumns(context);

              final spacing = 16.0;

              final cardWidth =
                  (constraints.maxWidth -
                          ((columns - 1) * spacing)) /
                      columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards.map((card) {
                  return SizedBox(
                    width: cardWidth,
                    height: 220,
                    child: _buildKpiCard(
                      context,
                      card,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 22),

          // ==========================================================
          // INSTRUÇÃO
          // ==========================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.05,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: AppColors.primary,
                ),
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

  Widget _buildKpiCard(
    BuildContext context,
    _DashboardKpi item,
  ) {
    final status = item.data.status;

    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);

    final change = item.data.change;

    final trendColor = change >= 0
        ? Colors.green
        : Colors.red;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isRefreshing
            ? null
            : () {
                onOpenInvestigation(item.type);
              },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: statusColor.withValues(
                alpha: 0.30,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.09,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
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
                _formatKpiValue(item.data),
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
                item.data.unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    change >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 17,
                    color: trendColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${change.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    item.data.previousLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // STATUS
  // ================================================================

  Color _statusColor(KpiStatus status) {
    switch (status) {
      case KpiStatus.normal:
        return Colors.green;

      case KpiStatus.atencao:
        return Colors.orange;

      case KpiStatus.critico:
        return Colors.red;
    }
  }

  String _statusLabel(KpiStatus status) {
    switch (status) {
      case KpiStatus.normal:
        return 'Normal';

      case KpiStatus.atencao:
        return 'Atenção';

      case KpiStatus.critico:
        return 'Crítico';
    }
  }

  // ================================================================
  // FORMATAÇÃO
  // ================================================================

  String _formatKpiValue(KpiData data) {
    if (data.unit == 'R\$') {
      return 'R\$ ${data.value.toStringAsFixed(2)}';
    }

    return data.value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
  }

  // ================================================================
  // LEGENDA
  // ================================================================

  Widget _buildLegend({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// MODELO INTERNO DO CARD
// ==================================================================

class _DashboardKpi {
  final String title;
  final KpiData data;
  final IconData icon;
  final InvestigationType type;

  const _DashboardKpi({
    required this.title,
    required this.data,
    required this.icon,
    required this.type,
  });
}