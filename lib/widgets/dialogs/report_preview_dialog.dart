import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/kpi_data.dart';

class ReportPreviewDialog extends StatelessWidget {
  final String reportType;
  final String period;
  final String summary;
  final Map<String, dynamic> kpis;
  final VoidCallback onExportPdf;
  final VoidCallback onExportCsv;

  const ReportPreviewDialog({
    super.key,
    required this.reportType,
    required this.period,
    required this.summary,
    required this.kpis,
    required this.onExportPdf,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    final km = kpis['km'] as KpiData;
    final viagens = kpis['viagens'] as KpiData;
    final pagantes = kpis['pagantes'] as KpiData;
    final naoPagantes = kpis['naoPagantes'] as KpiData;
    final financeiro = kpis['financeiro'] as KpiData;

    final totalPassageiros = pagantes.value + naoPagantes.value;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 680),
        child: Column(
          children: [
            // Topo do Dialog
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Pré-Visualização do Relatório Oficial',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Conteúdo do Documento Timbrado
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cabeçalho Timbrado
                      Column(
                        children: const [
                          Text(
                            'PREFEITURA MUNICIPAL DE SÃO CAETANO DO SUL',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'SECRETARIA MUNICIPAL DE MOBILIDADE URBANA (SEMOB-SCS)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Diretoria de Planejamento e Monitoramento Operacional',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          Divider(color: AppColors.primary, thickness: 1.5),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Título do Relatório
                      Center(
                        child: Text(
                          reportType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Período de Referência: $period',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Resumo
                      const Text(
                        '1. SÍNTESE EXECUTIVA DA OPERAÇÃO',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary,
                        style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 20),

                      // Tabela de Indicadores
                      const Text(
                        '2. QUADRO CONSOLIDADO DE INDICADORES',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      _buildIndicatorRow('Quilometragem Total Homologada', '${Formatters.number(km.value)} km'),
                      _buildIndicatorRow('Viagens Municipais Concluídas', '${Formatters.number(viagens.value)} viagens'),
                      _buildIndicatorRow('Passageiros com Validação Tarifária', Formatters.number(pagantes.value)),
                      _buildIndicatorRow('Passageiros com Gratuidade Legal', Formatters.number(naoPagantes.value)),
                      _buildIndicatorRow('Total de Munícipes Transportados', Formatters.number(totalPassageiros), isTotal: true),
                      _buildIndicatorRow('Apuração Tarifária Consolidada (Mock)', Formatters.currency(financeiro.value)),
                      const SizedBox(height: 32),

                      // Bloco de Assinaturas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSignatureBlock('Dra. Luiza Gomes', 'Coordenadora de Monitoramento SEMOB-SCS'),
                          _buildSignatureBlock('Diretoria de Fiscalização', 'Secretaria de Mobilidade Urbana — SCS'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Rodapé de Ações
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onExportCsv,
                    icon: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text('Exportar CSV', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onExportPdf,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Exportar PDF', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(String label, String value, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isTotal ? AppColors.primaryLight.withOpacity(0.5) : Colors.transparent,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureBlock(String name, String role) {
    return Column(
      children: [
        Container(width: 160, height: 1, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(role, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
      ],
    );
  }
}
