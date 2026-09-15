import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/kpi_data.dart';
import '../../widgets/cards/kpi_card.dart';
import '../../widgets/cards/alert_card.dart';
import '../../widgets/charts/evolution_chart.dart';
import '../../widgets/charts/passengers_comparison_chart.dart';

class DashboardScreen extends StatelessWidget {
  final String selectedPeriod;
  final bool isRefreshing;
  final Function(int) onNavigate;
  final Function(dynamic) onSelectAlert;

  const DashboardScreen({
    super.key,
    required this.selectedPeriod,
    required this.isRefreshing,
    required this.onNavigate,
    required this.onSelectAlert,
  });

  @override
  Widget build(BuildContext context) {
    final kpis = MockTransporteData.getKpisByPeriod(selectedPeriod);
    final alerts = MockTransporteData.anomalias.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Informativo Institucional
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ambiente de Demonstração (TTI206) — Dados mockados preparados para futura integração com a base bruta da Smart Data.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Os 5 KPIs Principais Responsivos
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = Breakpoints.getKpiColumns(context);
              final width = (constraints.maxWidth - ((cols - 1) * 12)) / cols;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Quilometragem',
                      data: kpis['km'] as KpiData,
                      icon: Icons.speed,
                      iconColor: AppColors.primary,
                      iconBg: AppColors.primaryLight,
                      isLoading: isRefreshing,
                      onTap: () => onNavigate(1), // Operação
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Viagens Realizadas',
                      data: kpis['viagens'] as KpiData,
                      icon: Icons.directions_bus,
                      iconColor: const Color(0xFF0284C7),
                      iconBg: const Color(0xFFE0F2FE),
                      isLoading: isRefreshing,
                      onTap: () => onNavigate(1), // Operação
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Passageiros Pagantes',
                      data: kpis['pagantes'] as KpiData,
                      icon: Icons.people_alt,
                      iconColor: AppColors.success,
                      iconBg: AppColors.successBg,
                      isLoading: isRefreshing,
                      onTap: () => onNavigate(2), // Passageiros
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Não Pagantes (Gratuidades)',
                      data: kpis['naoPagantes'] as KpiData,
                      icon: Icons.badge_outlined,
                      iconColor: AppColors.warning,
                      iconBg: AppColors.warningBg,
                      isLoading: isRefreshing,
                      onTap: () => onNavigate(2), // Passageiros
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Financeiro (Mock)',
                      data: kpis['financeiro'] as KpiData,
                      icon: Icons.monetization_on_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBg: const Color(0xFFF3E8FF),
                      isLoading: isRefreshing,
                      onTap: () => onNavigate(3), // Financeiro
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Gráfico de Evolução da Operação (com abas Km, Viagens, Passageiros, Financeiro)
          const EvolutionChartWidget(),
          const SizedBox(height: 16),

          // Grid Duplo: Gráfico de Passageiros + Resumo da Operação
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 3, child: PassengersComparisonChartWidget()),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildResumoOperacaoCard(kpis)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    const PassengersComparisonChartWidget(),
                    const SizedBox(height: 16),
                    _buildResumoOperacaoCard(kpis),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Seção: Alertas e Anomalias em Destaque
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 22),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Alertas e Anomalias em Destaque',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => onNavigate(4), // Anomalias
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Ver Central', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Desvios operacionais fictícios gerados para validação da interface de fiscalização.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Lista de Cards de Alertas
                  Column(
                    children: alerts.map((alert) {
                      return AlertCardWidget(
                        alert: alert,
                        onAudit: () {
                          onSelectAlert(alert);
                          onNavigate(4); // Navega para anomalias com foco
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoOperacaoCard(Map<String, dynamic> kpis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo da Operação',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Síntese executiva do período selecionado',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            _buildSummaryRow(
              'Cumprimento de Viagens',
              kpis['cumprimento'] as String,
              'Meta SEMOB: > 98.0%',
              AppColors.successText,
            ),
            const Divider(height: 16),
            _buildSummaryRow(
              'Índice de Gratuidades',
              kpis['indiceGratuidade'] as String,
              'Idosos, estudantes e PCD',
              AppColors.primary,
            ),
            const Divider(height: 16),
            _buildSummaryRow(
              'Pontualidade Geral',
              kpis['pontualidade'] as String,
              'Tolerância ± 5 min',
              AppColors.textPrimary,
            ),
            const Divider(height: 16),
            _buildSummaryRow(
              'Linhas em Monitoramento',
              '8 linhas',
              '100% da rede municipal',
              AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, String sub, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                sub,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valColor),
        ),
      ],
    );
  }
}
