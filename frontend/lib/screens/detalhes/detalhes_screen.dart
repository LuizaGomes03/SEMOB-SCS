
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/operacao_item.dart';

enum InvestigationType {
  quilometragem,
  viagens,
  pagantes,
  gratuidades,
  financeiro,
  operacaoLinhas,
}

enum _ChartType {
  automatico,
  linha,
  barras,
  pizza,
}

class DetalhesScreen extends StatefulWidget {
  final OperacaoItem? item;
  final InvestigationType? type;
  final VoidCallback onBack;

  const DetalhesScreen({
    super.key,
    this.item,
    this.type,
    required this.onBack,
  });

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  String _periodFilter = 'Diário';
  String _dayFilter = 'Todos';
  String _lineFilter = 'Todas as linhas';
  DateTimeRange? _customRange;
  _ChartType _chartType = _ChartType.automatico;

  @override
  Widget build(BuildContext context) {
    if (widget.item != null) {
      return _buildOperationDetail(context, widget.item!);
    }

    final type = widget.type ?? InvestigationType.quilometragem;

    if (type == InvestigationType.operacaoLinhas) {
      return _buildLineOperationsInvestigation(context);
    }

    final config = _getConfig(type);

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 700 ? 16.0 : 30.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 26, padding, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Voltar ao Dashboard'),
              ),
              const SizedBox(height: 24),
              _buildTitle(config),
              const SizedBox(height: 24),
              _buildFilters(),
              const SizedBox(height: 20),
              _buildMainKpi(config),
              const SizedBox(height: 20),
              _buildChartSection(config, type),
              const SizedBox(height: 20),
              if (type == InvestigationType.pagantes ||
                  type == InvestigationType.gratuidades)
                ...[
                  _buildPassengerComposition(),
                  const SizedBox(height: 20),
                ],
              _buildByLine(type),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle(_InvestigationConfig config) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(config.icon, color: AppColors.primary, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Investigação do Indicador',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                config.title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                config.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _filter('Diário', Icons.today_outlined,
              selected: _periodFilter == 'Diário'),
          _filter('Semanal', Icons.date_range_outlined,
              selected: _periodFilter == 'Semanal'),
          _filter('Quinzenal', Icons.calendar_view_week_outlined,
              selected: _periodFilter == 'Quinzenal'),
          _filter('Mensal', Icons.calendar_month_outlined,
              selected: _periodFilter == 'Mensal'),
          _filter('Selecionar período', Icons.calendar_today_outlined,
              selected: _periodFilter == 'Personalizado'),
          _filter('Sexta-feira', Icons.event_available_outlined,
              selected: _dayFilter == 'Sexta-feira'),
          _filter('Dia útil', Icons.work_outline,
              selected: _dayFilter == 'Dia útil'),
          _filter('Não útil', Icons.weekend_outlined,
              selected: _dayFilter == 'Não útil'),
          _filter(_lineFilter, Icons.directions_bus_outlined,
              selected: _lineFilter != 'Todas as linhas'),
        ],
      ),
    );
  }

  Widget _filter(String label, IconData icon, {bool selected = false}) {
    return OutlinedButton.icon(
      onPressed: () => _handleFilter(label),
      icon: Icon(icon, size: 17),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected
            ? Colors.white
            : AppColors.textPrimary,
        backgroundColor:
            selected ? AppColors.primary : Colors.white,
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : const Color(0xFFD9DEE7),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }

  Future<void> _handleFilter(String label) async {
    if (label == 'Selecionar período') {
      final now = DateTime.now();
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024),
        lastDate: DateTime(now.year + 2),
        initialDateRange: _customRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 6)),
              end: now,
            ),
        helpText: 'Selecionar período da investigação',
        saveText: 'Aplicar',
        cancelText: 'Cancelar',
        confirmText: 'Aplicar',
      );

      if (range != null) {
        setState(() {
          _customRange = range;
          _periodFilter = 'Personalizado';
        });
      }
      return;
    }

    if (label == 'Todas as linhas' ||
        label.startsWith('Linha ')) {
      _showLinePicker();
      return;
    }

    if (label == 'Sexta-feira' ||
        label == 'Dia útil' ||
        label == 'Não útil') {
      setState(() {
        _dayFilter = _dayFilter == label ? 'Todos' : label;
      });
      return;
    }

    setState(() => _periodFilter = label);
  }

  Future<void> _showLinePicker() async {
    final lines = <String>[
      'Todas as linhas',
      ...MockTransporteData.operacoes.map((e) => e.lineCode),
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Filtrar por linha',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              ...lines.map(
                (line) => ListTile(
                  leading: const Icon(Icons.directions_bus_outlined),
                  title: Text(line),
                  trailing: line == _lineFilter
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(context, line),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _lineFilter = selected);
    }
  }

  Widget _buildMainKpi(_InvestigationConfig config) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: config.statusColor.withValues(alpha: 0.30),
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    config.value,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.unit,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: config.statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              config.status,
              style: TextStyle(
                color: config.statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    _InvestigationConfig config,
    InvestigationType type,
  ) {
    final available = _availableChartTypes(type);
    final current = available.contains(_chartType)
        ? _chartType
        : _ChartType.automatico;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.analysisTitle,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      config.analysisDescription,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _chartTypeMenu(available, current),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 300,
            child: _Chart(
              type: current == _ChartType.automatico
                  ? _recommendedChart(type)
                  : current,
              values: config.chartValues,
              labels: _labelsForPeriod(),
              color: AppColors.primary,
              secondaryColor: const Color(0xFF7FA2D4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Período: ${_periodDescription()} • ${_lineFilter == 'Todas as linhas' ? 'todas as linhas' : _lineFilter}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartTypeMenu(
    List<_ChartType> available,
    _ChartType current,
  ) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<_ChartType>(
        value: current,
        borderRadius: BorderRadius.circular(12),
        items: available.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(_chartLabel(type)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _chartType = value);
          }
        },
      ),
    );
  }

  List<_ChartType> _availableChartTypes(InvestigationType type) {
    switch (type) {
      case InvestigationType.pagantes:
      case InvestigationType.gratuidades:
        return const [
          _ChartType.automatico,
          _ChartType.linha,
          _ChartType.barras,
        ];
      case InvestigationType.quilometragem:
      case InvestigationType.viagens:
      case InvestigationType.financeiro:
        return const [
          _ChartType.automatico,
          _ChartType.linha,
          _ChartType.barras,
        ];
      case InvestigationType.operacaoLinhas:
        return const [_ChartType.automatico, _ChartType.barras];
    }
  }

  _ChartType _recommendedChart(InvestigationType type) {
    switch (type) {
      case InvestigationType.quilometragem:
      case InvestigationType.viagens:
      case InvestigationType.financeiro:
      case InvestigationType.pagantes:
      case InvestigationType.gratuidades:
        return _ChartType.linha;
      case InvestigationType.operacaoLinhas:
        return _ChartType.barras;
    }
  }

  String _chartLabel(_ChartType type) {
    switch (type) {
      case _ChartType.automatico:
        return 'Automático';
      case _ChartType.linha:
        return 'Linha';
      case _ChartType.barras:
        return 'Barras';
      case _ChartType.pizza:
        return 'Pizza';
    }
  }

  List<String> _labelsForPeriod() {
    switch (_periodFilter) {
      case 'Semanal':
        return const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      case 'Quinzenal':
        return const ['1', '3', '5', '7', '9', '11', '13', '15'];
      case 'Mensal':
        return const ['1', '5', '10', '15', '20', '25', '30'];
      case 'Personalizado':
        return const ['Início', 'P2', 'P3', 'P4', 'P5', 'P6', 'Fim'];
      default:
        return const ['06h', '08h', '10h', '12h', '14h', '16h', '18h'];
    }
  }

  String _periodDescription() {
    if (_periodFilter == 'Personalizado' && _customRange != null) {
      return '${_formatDate(_customRange!.start)} – ${_formatDate(_customRange!.end)}';
    }
    return _periodFilter;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  Widget _buildPassengerComposition() {
    const pagantes = 32450.0;
    const gratuidades = 8230.0;
    final total = pagantes + gratuidades;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;
          final chart = SizedBox(
            width: compact ? 190 : 230,
            height: 190,
            child: CustomPaint(
              painter: _DonutPainter(
                first: pagantes / total,
                firstColor: AppColors.primary,
                secondColor: const Color(0xFF7FA2D4),
              ),
            ),
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Composição dos passageiros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Aqui a distribuição em partes do total é mais útil que uma série temporal.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _compositionRow(
                'Pagantes',
                pagantes,
                total,
                AppColors.primary,
              ),
              const SizedBox(height: 12),
              _compositionRow(
                'Gratuidades',
                gratuidades,
                total,
                const Color(0xFF7FA2D4),
              ),
            ],
          );

          return compact
              ? Column(
                  children: [chart, const SizedBox(height: 10), details],
                )
              : Row(
                  children: [
                    chart,
                    const SizedBox(width: 30),
                    Expanded(child: details),
                  ],
                );
        },
      ),
    );
  }

  Widget _compositionRow(
    String label,
    double value,
    double total,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(
          '${(value / total * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildLineOperationsInvestigation(BuildContext context) {
    final rows = MockTransporteData.operacoes.take(10).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 700 ? 16.0 : 30.0;
        final twoColumns = constraints.maxWidth >= 900;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 24, padding, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Voltar ao Dashboard'),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_bus_filled_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operação das linhas',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'As 10 linhas do sistema: viagens programadas × realizadas.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDE4EF)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'O mock atual possui totais de viagens por linha. Ele ainda não possui os horários de cada viagem; por isso, esta tela verifica a execução total programada, sem inventar cumprimento horário.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: rows
                    .map(
                      (row) => SizedBox(
                        width: itemWidth,
                        child: _LineInvestigationCard(row: row),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildByLine(InvestigationType type) {
    var rows = MockTransporteData.operacoes;

    if (_lineFilter != 'Todas as linhas') {
      rows = rows.where((row) => row.lineCode == _lineFilter).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comportamento por linha',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E6EF)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++)
                _buildLineRow(
                  rows[i],
                  type,
                  i == rows.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineRow(
    OperacaoItem row,
    InvestigationType type,
    bool isLast,
  ) {
    final isCritical = row.status.toLowerCase() == 'crítico';
    final value = switch (type) {
      InvestigationType.quilometragem => '${Formatters.number(row.km)} km',
      InvestigationType.viagens =>
        '${row.viagens}/${row.viagensProgramadas}',
      InvestigationType.pagantes => Formatters.number(row.pagantes),
      InvestigationType.gratuidades => Formatters.number(row.naoPagantes),
      InvestigationType.financeiro =>
        'R\$ ${row.financeiro.toStringAsFixed(2)}',
      InvestigationType.operacaoLinhas =>
        '${row.viagens}/${row.viagensProgramadas}',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              row.lineCode,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.lineName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  row.statusDesc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (isCritical) ...[
            const SizedBox(width: 12),
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 21,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperationDetail(
    BuildContext context,
    OperacaoItem row,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text('Voltar'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Detalhamento: ${row.lineName}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            row.statusDesc,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _metric('Quilometragem', '${Formatters.number(row.km)} km', Icons.route),
              _metric('Viagens', '${row.viagens}/${row.viagensProgramadas}', Icons.directions_bus),
              _metric('Pagantes', Formatters.number(row.pagantes), Icons.people),
              _metric('Não pagantes', Formatters.number(row.naoPagantes), Icons.card_membership),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  _InvestigationConfig _getConfig(InvestigationType type) {
    switch (type) {
      case InvestigationType.quilometragem:
        return const _InvestigationConfig(
          title: 'Quilometragem',
          description:
              'Acompanhe a quilometragem realizada em relação ao planejamento operacional.',
          icon: Icons.route,
          value: '12.450',
          unit: 'km realizados',
          status: 'Normal',
          statusColor: Colors.green,
          analysisTitle: 'Evolução da quilometragem',
          analysisDescription:
              'Compare a quilometragem realizada ao longo do período e identifique desvios relevantes.',
          chartValues: [82, 86, 88, 84, 91, 76, 89],
        );
      case InvestigationType.viagens:
        return const _InvestigationConfig(
          title: 'Viagens',
          description:
              'Acompanhe a execução das viagens previstas e identifique viagens não realizadas.',
          icon: Icons.directions_bus,
          value: '1.245',
          unit: 'viagens realizadas',
          status: 'Atenção',
          statusColor: Colors.orange,
          analysisTitle: 'Viagens realizadas',
          analysisDescription:
              'Acompanhe a execução das viagens e localize desvios ao longo do período.',
          chartValues: [90, 92, 94, 93, 95, 78, 92],
        );
      case InvestigationType.pagantes:
        return const _InvestigationConfig(
          title: 'Passageiros Pagantes',
          description:
              'Acompanhe a demanda de passageiros pagantes do sistema.',
          icon: Icons.people,
          value: '32.450',
          unit: 'passageiros pagantes',
          status: 'Normal',
          statusColor: Colors.green,
          analysisTitle: 'Evolução dos passageiros pagantes',
          analysisDescription:
              'Observe a evolução da demanda e compare o comportamento das linhas.',
          chartValues: [72, 78, 80, 76, 84, 60, 82],
        );
      case InvestigationType.gratuidades:
        return const _InvestigationConfig(
          title: 'Gratuidades',
          description:
              'Acompanhe os passageiros não pagantes e sua distribuição no sistema.',
          icon: Icons.card_membership,
          value: '8.230',
          unit: 'passageiros não pagantes',
          status: 'Atenção',
          statusColor: Colors.orange,
          analysisTitle: 'Evolução das gratuidades',
          analysisDescription:
              'Observe a evolução dos passageiros não pagantes e identifique concentrações.',
          chartValues: [58, 61, 64, 63, 69, 55, 67],
        );
      case InvestigationType.financeiro:
        return const _InvestigationConfig(
          title: 'Financeiro',
          description:
              'Acompanhe a arrecadação tarifária e os registros financeiros consolidados.',
          icon: Icons.attach_money,
          value: 'R\$ 162.250,00',
          unit: 'arrecadação',
          status: 'Normal',
          statusColor: Colors.green,
          analysisTitle: 'Evolução financeira',
          analysisDescription:
              'Compare a arrecadação ao longo do período operacional.',
          chartValues: [74, 78, 81, 79, 85, 61, 83],
        );
      case InvestigationType.operacaoLinhas:
        return const _InvestigationConfig(
          title: 'Operação das linhas',
          description: 'Compare as 10 linhas do sistema pelo programado e realizado.',
          icon: Icons.directions_bus_filled_outlined,
          value: '10',
          unit: 'linhas do sistema',
          status: 'Monitoramento',
          statusColor: AppColors.primary,
          analysisTitle: 'Programado × realizado',
          analysisDescription: 'Verifique quais linhas cumpriram, fizeram menos ou fizeram mais viagens.',
          chartValues: [184, 142, 160, 150, 138, 172, 155, 146, 164, 151],
        );
    }
  }
}


class _LineInvestigationCard extends StatelessWidget {
  final OperacaoItem row;

  const _LineInvestigationCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final planned = row.viagensProgramadas;
    final actual = row.viagens;
    final difference = actual - planned;
    final percent = planned <= 0 ? 0.0 : (difference.abs() / planned) * 100;

    final color = difference == 0
        ? Colors.green
        : percent <= 5
            ? Colors.orange
            : Colors.red;

    final status = difference == 0
        ? 'No programado'
        : difference > 0
            ? '+$difference acima do programado'
            : '$difference abaixo do programado';

    final progress = planned <= 0
        ? 0.0
        : (actual / planned).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  row.lineCode,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  row.lineName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$actual / $planned',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: const Color(0xFFE7EBF2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                difference == 0
                    ? Icons.check_circle_outline
                    : difference > 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                color: color,
                size: 17,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Programadas: $planned  •  Realizadas: $actual',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final _ChartType type;
  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color secondaryColor;

  const _Chart({
    required this.type,
    required this.values,
    required this.labels,
    required this.color,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _ChartType.barras:
        return _BarChart(values: values, labels: labels, color: color);
      case _ChartType.linha:
        return _LineChart(values: values, labels: labels, color: color);
      case _ChartType.pizza:
      case _ChartType.automatico:
        return _LineChart(values: values, labels: labels, color: color);
    }
  }
}

class _LineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;

  const _LineChart({
    required this.values,
    required this.labels,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        values: values,
        labels: labels,
        color: color,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;

  const _BarChart({
    required this.values,
    required this.labels,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 38),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final height = 205 * (values[i] / maxValue);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Column(
                    children: [
                      Text(
                        values[i].toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels[i],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;

  _LineChartPainter({
    required this.values,
    required this.labels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 12.0;
    const top = 18.0;
    const bottom = 34.0;

    final chart = Rect.fromLTWH(
      left,
      top,
      math.max(0, size.width - left - right),
      math.max(0, size.height - top - bottom),
    );

    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final range = math.max(1, maxValue - minValue);

    final gridPaint = Paint()
      ..color = const Color(0xFFE7EBF2)
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(
        Offset(chart.left, y),
        Offset(chart.right, y),
        gridPaint,
      );
    }

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = chart.left +
          chart.width * i / math.max(1, values.length - 1);
      final normalized = (values[i] - minValue) / range;
      final y = chart.bottom - normalized * chart.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      final pointPaint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), 4.5, pointPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 55);

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chart.bottom + 10),
      );
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final yLabels = [
      maxValue,
      minValue + range * 0.75,
      minValue + range * 0.50,
      minValue + range * 0.25,
      minValue,
    ];

    for (int i = 0; i < yLabels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: yLabels[i].toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textMuted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final y = chart.top + chart.height * i / 4;
      painter.paint(
        canvas,
        Offset(chart.left - painter.width - 7, y - 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.color != color ||
        oldDelegate.labels != labels;
  }
}

class _DonutPainter extends CustomPainter {
  final double first;
  final Color firstColor;
  final Color secondColor;

  _DonutPainter({
    required this.first,
    required this.firstColor,
    required this.secondColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 12;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.butt;

    paint.color = secondColor;
    canvas.drawCircle(center, radius, paint);

    paint.color = firstColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * first,
      false,
      paint,
    );

    final total = 1.0;
    final tp = TextPainter(
      text: TextSpan(
        text: '${(first * total * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        center.dx - tp.width / 2,
        center.dy - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.first != first;
  }
}

class _InvestigationConfig {
  final String title;
  final String description;
  final IconData icon;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final String analysisTitle;
  final String analysisDescription;
  final List<double> chartValues;

  const _InvestigationConfig({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.analysisTitle,
    required this.analysisDescription,
    required this.chartValues,
  });
}
