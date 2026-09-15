import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/anomalia_item.dart';
import '../../models/kpi_data.dart';
import '../../widgets/cards/kpi_card.dart';
import '../../widgets/cards/alert_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/status_badge.dart';

class AnomaliasScreen extends StatefulWidget {
  final AnomaliaItem? initialSelectedAlert;

  const AnomaliasScreen({
    super.key,
    this.initialSelectedAlert,
  });

  @override
  State<AnomaliasScreen> createState() => _AnomaliasScreenState();
}

class _AnomaliasScreenState extends State<AnomaliasScreen> {
  String _selectedSeverity = 'todas';
  String _selectedStatus = 'todos';
  String _selectedType = 'todos';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final allAlerts = MockTransporteData.anomalias;

    final filtered = allAlerts.where((a) {
      final matchesSeverity = _selectedSeverity == 'todas' || a.severity == _selectedSeverity;
      final matchesStatus = _selectedStatus == 'todos' || a.status == _selectedStatus;
      final matchesType = _selectedType == 'todos' || a.type == _selectedType;
      final matchesSearch = _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.line.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.code.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSeverity && matchesStatus && matchesType && matchesSearch;
    }).toList();

    final total = allAlerts.length;
    final criticos = allAlerts.where((a) => a.severity == 'Crítico' && a.status != 'Resolvido').length;
    final atencao = allAlerts.where((a) => a.severity == 'Atenção' && a.status != 'Resolvido').length;
    final resolvidos = allAlerts.where((a) => a.status == 'Resolvido').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 4 KPIs de Auditoria
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
                      title: 'Total de Alertas',
                      data: KpiData(
                        value: total,
                        unit: 'casos',
                        change: 12.5,
                        trend: TrendDirection.up,
                        previousLabel: 'no ciclo atual',
                        tooltip: 'Ocorrências operacionais capturadas pela telemetria.',
                      ),
                      icon: Icons.shield_outlined,
                      iconBg: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Alertas Críticos',
                      data: KpiData(
                        value: criticos,
                        unit: 'urgentes',
                        change: criticos > 0 ? 100 : 0,
                        trend: criticos > 0 ? TrendDirection.down : TrendDirection.neutral,
                        previousLabel: 'demandam ação imediata',
                        tooltip: 'Viagens suprimidas e falhas graves de frota.',
                      ),
                      icon: Icons.error_outline,
                      iconBg: AppColors.dangerBg,
                      iconColor: AppColors.danger,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Avisos de Atenção',
                      data: KpiData(
                        value: atencao,
                        unit: 'desvios',
                        change: 0.0,
                        trend: TrendDirection.neutral,
                        previousLabel: 'desvios médios',
                        tooltip: 'Quilometragem atípica e variações de gratuidades.',
                      ),
                      icon: Icons.warning_amber_rounded,
                      iconBg: AppColors.warningBg,
                      iconColor: AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Alertas Resolvidos',
                      data: KpiData(
                        value: resolvidos,
                        unit: 'auditados',
                        change: 25.0,
                        trend: TrendDirection.up,
                        previousLabel: 'resolução técnica',
                        tooltip: 'Ocorrências que receberam parecer ou foram regularizadas.',
                      ),
                      icon: Icons.check_circle_outline,
                      iconBg: AppColors.successBg,
                      iconColor: AppColors.success,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Filtros
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 240,
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Buscar anomalia ou linha...',
                        prefixIcon: Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedSeverity,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'todas', child: Text('Severidade: Todas', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Crítico', child: Text('Crítico', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Atenção', child: Text('Atenção', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (v) => setState(() => _selectedSeverity = v!),
                  ),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Status: Todos', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Pendente', child: Text('Pendente', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Em Análise', child: Text('Em Análise', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Resolvido', child: Text('Resolvido', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                  ),
                  DropdownButton<String>(
                    value: _selectedType,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Tipo: Todos', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Quilometragem', child: Text('Quilometragem', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Viagens Canceladas', child: Text('Viagens Canceladas', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Gratuidades', child: Text('Gratuidades', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Consolidação de Dados', child: Text('Consolidação de Dados', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tabela no Desktop ou Cards no Mobile
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ocorrências para Fiscalização Operacional',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text('${filtered.length} alerta(s)', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  const Divider(height: 20),

                  if (filtered.isEmpty)
                    EmptyStateWidget(
                      title: 'Nenhum alerta encontrado',
                      description: 'Não há ocorrências correspondentes aos filtros selecionados.',
                      actionLabel: 'Limpar Filtros',
                      onAction: () => setState(() {
                        _selectedSeverity = 'todas';
                        _selectedStatus = 'todos';
                        _selectedType = 'todos';
                        _searchQuery = '';
                      }),
                    )
                  else if (isMobile)
                    // Mobile: Cards Expansíveis
                    Column(
                      children: filtered.map((item) {
                        return AlertCardWidget(
                          alert: item,
                          onAudit: () => _showAuditDialog(item),
                        );
                      }).toList(),
                    )
                  else
                    // Desktop: Tabela Completa
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(AppColors.background),
                        columns: const [
                          DataColumn(label: Text('Código / Tipo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Título da Anomalia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Linha Afetada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Data/Hora', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Severidade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Ação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                        rows: filtered.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(item.type, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              DataCell(Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                              DataCell(Text(item.line, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(item.date, style: const TextStyle(fontSize: 11))),
                              DataCell(StatusBadge(status: item.severity)),
                              DataCell(StatusBadge(status: item.status)),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _showAuditDialog(item),
                                  icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                                  label: const Text('Auditar', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
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

  void _showAuditDialog(AnomaliaItem alert) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    alert.severity == 'Crítico' ? Icons.error_outline : Icons.warning_amber_rounded,
                    color: alert.severity == 'Crítico' ? AppColors.danger : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auditoria: ${alert.code}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(alert.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Linha: ${alert.line}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('Data: ${alert.date}', style: const TextStyle(fontSize: 11)),
                          const SizedBox(height: 4),
                          Text('Esperado: ${alert.expectedValue}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('Aferido: ${alert.actualValue}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.dangerText)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Recomendação de Fiscalização:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(alert.actionRequired, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                  ],
                ),
              ),
              actions: [
                if (alert.status != 'Resolvido')
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => alert.status = 'Resolvido');
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alerta marcado como Resolvido no sistema.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Marcar Resolvido'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
