import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/kpi_data.dart';
import '../../widgets/charts/evolution_chart.dart';
import '../../widgets/dialogs/report_preview_dialog.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Seletor de Abas: Diário, Semanal, Mensal
          Card(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                tabs: const [
                  Tab(text: 'Relatório Diário'),
                  Tab(text: 'Relatório Semanal'),
                  Tab(text: 'Relatório Mensal'),
                ],
                onTap: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Conteúdo do Relatório Selecionado
          _buildReportContent(_tabController.index),
        ],
      ),
    );
  }

  Widget _buildReportContent(int index) {
    String periodKey;
    String reportTitle;
    String periodLabel;
    String summary;

    if (index == 1) {
      periodKey = 'semana';
      reportTitle = 'Relatório Executivo Semanal';
      periodLabel = 'Semana 37 (07 a 13/09/2026)';
      summary =
        'Consolidação dos últimos 7 dias operacionais: foram totalizados 86.940 km rodados e 8.640 viagens realizadas nas 8 linhas. O índice de gratuidades manteve-se estável em 20.2%, atendendo aos critérios da legislação municipal de São Caetano do Sul.';
    } else if (index == 2) {
      periodKey = 'mes';
      reportTitle = 'Relatório Mensal de Desempenho';
      periodLabel = 'Mês de Setembro/2026 (Consolidado)';
      summary =
        'Acumulado mensal de 368.200 km aferidos e 36.800 viagens. Foram transportados 1.210.000 passageiros no sistema integrado municipal. As operadoras cumpriram o índice mínimo de pontualidade e regularidade horária.';
    } else {
      periodKey = 'hoje';
      reportTitle = 'Relatório Executivo Diário';
      periodLabel = '14 de Setembro de 2026';
      summary =
        'A operação de transporte municipal de São Caetano do Sul transcorreu hoje com 99.6% de cumprimento das viagens programadas nas 8 linhas municipais. Registrou-se anomalia de viagens na Linha 04 no pico da manhã e desvio de trajeto na Linha 01.';
    }

    final kpis = MockTransporteData.getKpisByPeriod(periodKey);
    final km = kpis['km'] as KpiData;
    final viagens = kpis['viagens'] as KpiData;
    final pagantes = kpis['pagantes'] as KpiData;
    final naoPagantes = kpis['naoPagantes'] as KpiData;
    final financeiro = kpis['financeiro'] as KpiData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card Principal do Relatório
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reportTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Período: $periodLabel',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openPreview(reportTitle, periodLabel, summary, kpis),
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                          label: const Text('Visualizar', style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _exportReport('PDF', reportTitle),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Exportar', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Síntese Executiva
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Síntese Executiva para Gestores',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary,
                        style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quadro de Indicadores Consolidados
                const Text(
                  'Quadro Consolidado do Período',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMiniKpi('Quilometragem', '${Formatters.number(km.value)} km', '+${km.change}%'),
                      const SizedBox(width: 10),
                      _buildMiniKpi('Viagens Concluídas', Formatters.number(viagens.value), kpis['cumprimento'] as String),
                      const SizedBox(width: 10),
                      _buildMiniKpi('Pass. Pagantes', Formatters.number(pagantes.value), 'Tarifados'),
                      const SizedBox(width: 10),
                      _buildMiniKpi('Gratuidades', Formatters.number(naoPagantes.value), kpis['indiceGratuidade'] as String),
                      const SizedBox(width: 10),
                      _buildMiniKpi('Financeiro (Mock)', Formatters.currency(financeiro.value), 'Demonstrativo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Gráfico de Apoio do Relatório
        const EvolutionChartWidget(),
      ],
    );
  }

  Widget _buildMiniKpi(String title, String value, String sub) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _openPreview(String title, String period, String summary, Map<String, dynamic> kpis) {
    showDialog(
      context: context,
      builder: (ctx) => ReportPreviewDialog(
        reportType: title,
        period: period,
        summary: summary,
        kpis: kpis,
        onExportPdf: () {
          Navigator.of(ctx).pop();
          _exportReport('PDF', title);
        },
        onExportCsv: () {
          Navigator.of(ctx).pop();
          _exportReport('CSV', title);
        },
      ),
    );
  }

  void _exportReport(String format, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Relatório "$title" exportado em formato $format com sucesso!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
