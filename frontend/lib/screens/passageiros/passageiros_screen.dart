import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/kpi_data.dart';
import '../../widgets/cards/kpi_card.dart';
import '../../widgets/charts/passengers_comparison_chart.dart';
import '../../widgets/charts/passengers_donut_chart.dart';

class PassageirosScreen extends StatefulWidget {
  final String selectedPeriod;

  const PassageirosScreen({
    super.key,
    required this.selectedPeriod,
  });

  @override
  State<PassageirosScreen> createState() => _PassageirosScreenState();
}

class _PassageirosScreenState extends State<PassageirosScreen> {
  String _selectedDate = 'todas';

  @override
  Widget build(BuildContext context) {
    final kpis = MockTransporteData.getKpisByPeriod(widget.selectedPeriod);
    final pagantes = kpis['pagantes'] as KpiData;
    final naoPagantes = kpis['naoPagantes'] as KpiData;
    final totalPassageiros = pagantes.value + naoPagantes.value;
    final percentualPagantes = (pagantes.value / totalPassageiros * 100);

    final operations = MockTransporteData.operacoes.where((o) {
      return _selectedDate == 'todas' || o.date == _selectedDate;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 4 KPIs de Demanda
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
                      title: 'Total de Passageiros',
                      data: KpiData(
                        value: totalPassageiros,
                        unit: 'passageiros',
                        change: pagantes.change,
                        trend: pagantes.trend,
                        previousLabel: pagantes.previousLabel,
                        tooltip: 'Volume consolidado de munícipes transportados no período.',
                      ),
                      icon: Icons.people_alt,
                      iconBg: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Passageiros Pagantes',
                      data: pagantes,
                      icon: Icons.credit_card,
                      iconBg: AppColors.successBg,
                      iconColor: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Não Pagantes (Gratuidades)',
                      data: naoPagantes,
                      icon: Icons.volunteer_activism_outlined,
                      iconBg: AppColors.warningBg,
                      iconColor: AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Índice de Pagantes',
                      data: KpiData(
                        value: percentualPagantes.round(),
                        unit: '%',
                        change: -0.3,
                        trend: TrendDirection.neutral,
                        previousLabel: 'taxa de bilhetagem',
                        tooltip: 'Proporção de passageiros que remuneram diretamente a tarifa pública.',
                      ),
                      icon: Icons.pie_chart_outline,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Gráficos de Demanda lado a lado ou empilhados
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(child: PassengersComparisonChartWidget()),
                    SizedBox(width: 16),
                    Expanded(child: PassengersDonutChartWidget()),
                  ],
                );
              } else {
                return Column(
                  children: const [
                    PassengersComparisonChartWidget(),
                    SizedBox(height: 16),
                    PassengersDonutChartWidget(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Tabela de Detalhamento de Passageiros por Linha
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Demonstrativo por Linha Municipal',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Volume de passageiros pagantes e gratuidades',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        value: _selectedDate,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'todas', child: Text('Todas as Datas', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: '14/09/2026', child: Text('Hoje (14/09)', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: '13/09/2026', child: Text('13/09/2026', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) => setState(() => _selectedDate = val!),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(AppColors.background),
                      columns: const [
                        DataColumn(label: Text('Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Linha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Pagantes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Gratuidades', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Total Geral', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('% Pagantes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                      rows: operations.map((row) {
                        return DataRow(
                          cells: [
                            DataCell(Text(row.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            DataCell(Text(row.lineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            DataCell(Text(Formatters.number(row.pagantes), style: const TextStyle(fontSize: 12, color: AppColors.successText, fontWeight: FontWeight.bold))),
                            DataCell(Text(Formatters.number(row.naoPagantes), style: const TextStyle(fontSize: 12, color: AppColors.warningText, fontWeight: FontWeight.bold))),
                            DataCell(Text(Formatters.number(row.totalPassageiros), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: LinearProgressIndicator(
                                      value: row.percentualPagantes / 100,
                                      backgroundColor: AppColors.warningBg,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${row.percentualPagantes.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
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
