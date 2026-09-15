import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/operacao_item.dart';
import '../../widgets/cards/alert_card.dart';
import '../../widgets/charts/hourly_bar_chart.dart';
import '../../widgets/common/status_badge.dart';

class DetalhesScreen extends StatelessWidget {
  final OperacaoItem? item;
  final VoidCallback onBack;

  const DetalhesScreen({
    super.key,
    required this.item,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final row = item ?? MockTransporteData.operacoes.first;
    final relatedAlerts = MockTransporteData.anomalias.where((a) {
      return a.line.contains(row.lineCode) || a.line.toLowerCase().contains(row.lineName.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botão Voltar e Cabeçalho de Contexto
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Voltar ao contexto anterior', style: TextStyle(fontSize: 12)),
              ),
              const Spacer(),
              StatusBadge(status: row.status),
            ],
          ),
          const SizedBox(height: 16),

          // Card de Identificação da Linha e Dia
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhamento: ${row.lineName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Data: ${row.date}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_bus_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Frota Ativa: ${row.veiculosAtivos} veículos', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(row.statusDesc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quadro de Indicadores Específicos
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
                  _buildMetricCard(width, 'Quilometragem Aferida', '${Formatters.number(row.km)} km', 'Prog: ${Formatters.number(row.kmProgramado)} km'),
                  _buildMetricCard(width, 'Viagens Realizadas', '${row.viagens} / ${row.viagensProgramadas}', 'Taxa: ${((row.viagens / row.viagensProgramadas) * 100).toStringAsFixed(1)}%'),
                  _buildMetricCard(width, 'Passageiros Pagantes', Formatters.number(row.pagantes), '${row.percentualPagantes.toStringAsFixed(1)}% do total'),
                  _buildMetricCard(width, 'Gratuidades', Formatters.number(row.naoPagantes), '${(100 - row.percentualPagantes).toStringAsFixed(1)}% do total'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Gráfico por Faixa Horária
          HourlyBarChartWidget(totalPassageiros: row.totalPassageiros),
          const SizedBox(height: 16),

          // Alertas Vinculados a esta Linha
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ocorrências e Alertas Vinculados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Apontamentos da fiscalização e telemetria para esta linha no período',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  if (relatedAlerts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nenhuma anomalia crítica ou desvio registrado para esta linha. Operação em padrão regular.',
                              style: TextStyle(fontSize: 12, color: AppColors.successText, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: relatedAlerts.map((a) {
                        return AlertCardWidget(alert: a, onAudit: () {});
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

  Widget _buildMetricCard(double width, String title, String value, String sub) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
