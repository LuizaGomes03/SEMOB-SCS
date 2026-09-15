import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/kpi_data.dart';
import '../../models/operacao_item.dart';
import '../../widgets/cards/kpi_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/status_badge.dart';

class OperacaoScreen extends StatefulWidget {
  final Function(OperacaoItem) onSelectDetail;

  const OperacaoScreen({
    super.key,
    required this.onSelectDetail,
  });

  @override
  State<OperacaoScreen> createState() => _OperacaoScreenState();
}

class _OperacaoScreenState extends State<OperacaoScreen> {
  String _selectedLine = 'todas';
  String _selectedStatus = 'todos';
  String _searchQuery = '';
  String _sortColumn = 'date';
  bool _sortAsc = false;
  int _currentPage = 1;
  static const int _itemsPerPage = 6;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    // Filtragem e Ordenação
    final filtered = MockTransporteData.operacoes.where((item) {
      final matchesLine = _selectedLine == 'todas' || item.lineId == _selectedLine;
      final matchesStatus = _selectedStatus == 'todos' || item.status == _selectedStatus;
      final matchesSearch = _searchQuery.isEmpty ||
          item.lineName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.lineCode.contains(_searchQuery) ||
          item.date.contains(_searchQuery);
      return matchesLine && matchesStatus && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      int cmp = 0;
      switch (_sortColumn) {
        case 'km':
          cmp = a.km.compareTo(b.km);
          break;
        case 'viagens':
          cmp = a.viagens.compareTo(b.viagens);
          break;
        case 'pagantes':
          cmp = a.pagantes.compareTo(b.pagantes);
          break;
        case 'line':
          cmp = a.lineName.compareTo(b.lineName);
          break;
        default:
          cmp = a.date.compareTo(b.date);
      }
      return _sortAsc ? cmp : -cmp;
    });

    final totalPages = (filtered.length / _itemsPerPage).ceil().clamp(1, 999);
    final startIndex = ((_currentPage - 1) * _itemsPerPage).clamp(0, filtered.length);
    final endIndex = (_currentPage * _itemsPerPage).clamp(0, filtered.length);
    final paginatedItems = filtered.sublist(startIndex, endIndex);

    // Cálculos de Média
    final totalKm = filtered.fold<int>(0, (sum, i) => sum + i.km);
    final avgKm = filtered.isEmpty ? 0 : (totalKm / filtered.length).round();
    final totalViagens = filtered.fold<int>(0, (sum, i) => sum + i.viagens);
    final avgViagens = filtered.isEmpty ? 0 : (totalViagens / filtered.length).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 4 Cards Analíticos de Operação
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
                      title: 'Quilometragem Total',
                      data: KpiData(
                        value: totalKm,
                        unit: 'km',
                        change: 2.1,
                        trend: TrendDirection.up,
                        previousLabel: 'na amostra filtrada',
                        tooltip: 'Somatória da quilometragem aferida em todas as viagens filtradas.',
                      ),
                      icon: Icons.speed,
                      iconBg: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Média de Quilometragem',
                      data: KpiData(
                        value: avgKm,
                        unit: 'km/linha',
                        change: 0.8,
                        trend: TrendDirection.up,
                        previousLabel: 'vs. parâmetro padrão',
                        tooltip: 'Média de quilometragem por linha operacional.',
                      ),
                      icon: Icons.alt_route,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Viagens Realizadas',
                      data: KpiData(
                        value: totalViagens,
                        unit: 'viagens',
                        change: -0.4,
                        trend: TrendDirection.down,
                        previousLabel: 'vs. programado',
                        tooltip: 'Total de viagens concluídas na amostra filtrada.',
                      ),
                      icon: Icons.directions_bus,
                      iconBg: AppColors.successBg,
                      iconColor: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: KpiCardWidget(
                      title: 'Média de Viagens',
                      data: KpiData(
                        value: avgViagens,
                        unit: 'viagens/linha',
                        change: 1.2,
                        trend: TrendDirection.up,
                        previousLabel: 'regularidade média',
                        tooltip: 'Média de partidas por linha municipal.',
                      ),
                      icon: Icons.repeat,
                      iconBg: AppColors.warningBg,
                      iconColor: AppColors.warning,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Barra de Filtros e Busca Responsiva
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: isMobile ? _buildMobileFilterBar() : _buildDesktopFilterBar(),
            ),
          ),
          const SizedBox(height: 16),

          // Lista / Tabela da Operação
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Registros Operacionais Detalhados',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Confronto de odômetro, viagens programadas e bilhetagem',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Text(
                        '${filtered.length} registro(s)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Conteúdo Adaptado: Cards no Mobile ou Tabela no Desktop
                if (filtered.isEmpty)
                  EmptyStateWidget(
                    title: 'Nenhum registro encontrado',
                    description: 'Tente alterar os termos de busca ou filtros selecionados.',
                    actionLabel: 'Limpar Filtros',
                    onAction: _clearFilters,
                  )
                else if (isMobile)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: paginatedItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _buildMobileOperationCard(paginatedItems[index]),
                  )
                else
                  _buildDesktopDataTable(paginatedItems),

                // Barra de Paginação
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Página $_currentPage de $totalPages',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            onPressed: _currentPage > 1
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            onPressed: _currentPage < totalPages
                                ? () => setState(() => _currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Barra de Filtros Desktop
  Widget _buildDesktopFilterBar() {
    return Row(
      children: [
        // Campo de Busca
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (val) => setState(() {
              _searchQuery = val;
              _currentPage = 1;
            }),
            decoration: const InputDecoration(
              hintText: 'Buscar por linha, código ou data...',
              prefixIcon: Icon(Icons.search, size: 18),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Filtro por Linha
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: _selectedLine,
            decoration: const InputDecoration(
              labelText: 'Linha',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: MockTransporteData.linhas.map((l) {
              return DropdownMenuItem(
                value: l['id'],
                child: Text(l['name']!, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) => setState(() {
              _selectedLine = val!;
              _currentPage = 1;
            }),
          ),
        ),
        const SizedBox(width: 12),

        // Filtro por Status
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'todos', child: Text('Todos', style: TextStyle(fontSize: 12))),
              DropdownMenuItem(value: 'Regular', child: Text('Regular', style: TextStyle(fontSize: 12))),
              DropdownMenuItem(value: 'Atenção', child: Text('Atenção', style: TextStyle(fontSize: 12))),
              DropdownMenuItem(value: 'Crítico', child: Text('Crítico', style: TextStyle(fontSize: 12))),
            ],
            onChanged: (val) => setState(() {
              _selectedStatus = val!;
              _currentPage = 1;
            }),
          ),
        ),

        if (_searchQuery.isNotEmpty || _selectedLine != 'todas' || _selectedStatus != 'todos') ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
            tooltip: 'Limpar filtros',
            onPressed: _clearFilters,
          ),
        ],
      ],
    );
  }

  // Barra de Filtros Mobile com BottomSheet
  Widget _buildMobileFilterBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() {
              _searchQuery = val;
              _currentPage = 1;
            }),
            decoration: const InputDecoration(
              hintText: 'Buscar linha ou data...',
              prefixIcon: Icon(Icons.search, size: 18),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: const Icon(Icons.filter_list, size: 20),
          onPressed: _showMobileFiltersBottomSheet,
          tooltip: 'Filtros avançados',
        ),
      ],
    );
  }

  void _showMobileFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrar Registros',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedLine,
                    decoration: const InputDecoration(labelText: 'Linha Municipal', border: OutlineInputBorder()),
                    items: MockTransporteData.linhas.map((l) {
                      return DropdownMenuItem(value: l['id'], child: Text(l['name']!, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() => _selectedLine = val!);
                      setState(() => _selectedLine = val!);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                      DropdownMenuItem(value: 'Atenção', child: Text('Atenção')),
                      DropdownMenuItem(value: 'Crítico', child: Text('Crítico')),
                    ],
                    onChanged: (val) {
                      setModalState(() => _selectedStatus = val!);
                      setState(() => _selectedStatus = val!);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Aplicar Filtros'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Tabela Desktop
  Widget _buildDesktopDataTable(List<OperacaoItem> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.background),
        sortColumnIndex: _sortColumn == 'km'
            ? 2
            : (_sortColumn == 'viagens' ? 3 : (_sortColumn == 'pagantes' ? 4 : 0)),
        sortAscending: _sortAsc,
        columns: [
          DataColumn(
            label: const Text('Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onSort: (columnIndex, ascending) => _toggleSort('date'),
          ),
          DataColumn(
            label: const Text('Linha / Sentido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onSort: (columnIndex, ascending) => _toggleSort('line'),
          ),
          DataColumn(
            label: const Text('Quilometragem (km)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onSort: (columnIndex, ascending) => _toggleSort('km'),
          ),
          DataColumn(
            label: const Text('Viagens (Realiz./Prog.)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onSort: (columnIndex, ascending) => _toggleSort('viagens'),
          ),
          DataColumn(
            label: const Text('Pass. Pagantes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onSort: (columnIndex, ascending) => _toggleSort('pagantes'),
          ),
          const DataColumn(
            label: Text('Não Pagantes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const DataColumn(
            label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const DataColumn(
            label: Text('Ação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
        rows: items.map((row) {
          return DataRow(
            cells: [
              DataCell(Text(row.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(row.lineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('Frota ativa: ${row.veiculosAtivos} veículos', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ),
              DataCell(
                Text(
                  '${Formatters.number(row.km)} km (Prog: ${Formatters.number(row.kmProgramado)})',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text('${row.viagens} / ${row.viagensProgramadas}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              DataCell(
                Text(Formatters.number(row.pagantes), style: const TextStyle(fontSize: 12, color: AppColors.successText, fontWeight: FontWeight.bold)),
              ),
              DataCell(
                Text(Formatters.number(row.naoPagantes), style: const TextStyle(fontSize: 12, color: AppColors.warningText, fontWeight: FontWeight.bold)),
              ),
              DataCell(StatusBadge(status: row.status)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
                  tooltip: 'Ver Detalhes desta Operação',
                  onPressed: () => widget.onSelectDetail(row),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Card Mobile
  Widget _buildMobileOperationCard(OperacaoItem row) {
    return InkWell(
      onTap: () => widget.onSelectDetail(row),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(row.date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                StatusBadge(status: row.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              row.lineName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardMetric('Km Aferido', '${Formatters.number(row.km)} km'),
                _buildCardMetric('Viagens', '${row.viagens}/${row.viagensProgramadas}'),
                _buildCardMetric('Pagantes', Formatters.number(row.pagantes)),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Ver Detalhes', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _toggleSort(String col) {
    setState(() {
      if (_sortColumn == col) {
        _sortAsc = !_sortAsc;
      } else {
        _sortColumn = col;
        _sortAsc = true;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedLine = 'todas';
      _selectedStatus = 'todos';
      _searchQuery = '';
      _currentPage = 1;
    });
  }
}
