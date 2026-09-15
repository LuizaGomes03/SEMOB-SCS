import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/kpi_data.dart';
import '../../widgets/cards/kpi_card.dart';
import '../../widgets/charts/evolution_chart.dart';
import '../../widgets/common/status_badge.dart';

class FinanceiroScreen extends StatelessWidget {
  final String selectedPeriod;

  const FinanceiroScreen({
    super.key,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final kpis = MockTransporteData.getKpisByPeriod(selectedPeriod);
    final financeiro = kpis['financeiro'] as KpiData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de Alerta Institucional de Escopo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline, color: AppColors.warning, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indicadores Financeiros em Definição Oficial',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warningText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Conforme requisitos do Projeto Integrador TTI206, a SEMOB-SCS e a consolidadora Smart Data ainda definirão as fórmulas financeiras definitivas. Os dados abaixo são demonstrativos e preparados para substituição.',
                        style: TextStyle(fontSize: 11, color: AppColors.warningText, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cards Financeiros Demonstrativos
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 650;
              final width = isNarrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 36) / (constraints.maxWidth < 1100 ? 2 : 4);

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Valor Consolidado (Mock)',
                      data: financeiro,
                      icon: Icons.monetization_on_outlined,
                      iconBg: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Arrecadação Tarifária Estimada',
                      data: KpiData(
                        value: (financeiro.value * 0.88).round(),
                        unit: 'R\$',
                        change: 1.4,
                        trend: TrendDirection.up,
                        previousLabel: 'vs. período anterior',
                        tooltip: 'Estimativa de valores recolhidos na bilhetagem.',
                      ),
                      icon: Icons.point_of_sale_outlined,
                      iconBg: AppColors.successBg,
                      iconColor: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Compensação de Gratuidades',
                      data: KpiData(
                        value: (financeiro.value * 0.12).round(),
                        unit: 'R\$',
                        change: 3.2,
                        trend: TrendDirection.up,
                        previousLabel: 'estimativa de subsídio',
                        tooltip: 'Estimativa de compensação por gratuidades legais municipais.',
                      ),
                      icon: Icons.account_balance_outlined,
                      iconBg: AppColors.warningBg,
                      iconColor: AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Tarifa Base SCS',
                      data: const KpiData(
                        value: 5,
                        unit: 'R\$/pass.',
                        change: 0.0,
                        trend: TrendDirection.neutral,
                        previousLabel: 'decreto municipal',
                        tooltip: 'Valor de referência da tarifa pública municipal vigente.',
                      ),
                      icon: Icons.confirmation_number_outlined,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Gráfico de Evolução Financeira
          const EvolutionChartWidget(),
          const SizedBox(height: 16),

          // Tabela Financeira Demonstrativa
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Demonstrativo Consolidado de Lançamentos Financeiros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Valores consolidados por período de apuração contábil',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(AppColors.background),
                      columns: const [
                        DataColumn(label: Text('Período', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Descrição Operacional', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Valor (R\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Variação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Observação Técnica', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                      rows: MockTransporteData.tabelaFinanceira.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item['periodo'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            DataCell(Text(item['descricao'] as String, style: const TextStyle(fontSize: 12))),
                            DataCell(
                              Text(
                                Formatters.currency(item['valor'] as num),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            DataCell(
                              Text(
                                item['comparacao'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (item['comparacao'] as String).startsWith('+')
                                      ? AppColors.successText
                                      : AppColors.dangerText,
                                ),
                              ),
                            ),
                            DataCell(StatusBadge(status: item['status'] as String)),
                            DataCell(
                              Text(
                                item['observacao'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
