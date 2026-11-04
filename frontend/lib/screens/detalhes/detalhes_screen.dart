
import 'dart:math' as math;

import 'package:flutter/material.dart';
// Só NumberFormat: o intl também tem um TextDirection, que esconderia o do Flutter.
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/constants/app_colors.dart';
import '../../core/utils/dia.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/periodo.dart';
import '../../mock/mock_transporte_data.dart';
import '../../models/cumprimento.dart';
import '../../models/indicadores.dart';
import '../../models/operacao_item.dart';
import '../../models/por_hora.dart';
import '../../models/por_linha.dart';
import '../../models/relatorio_item.dart';
import '../../models/viagem_nao_cumprida.dart';
import '../../services/operacao_api.dart';
import '../../widgets/common/erro_carregamento.dart';

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
  final OperacaoApi api;
  final PeriodoConsulta periodo;
  final DateTime ultimaData;
  final String botaoInicial;
  final DateTimeRange? customRange;
  final OperacaoItem? item;
  final InvestigationType? type;
  final VoidCallback onBack;

  const DetalhesScreen({
    super.key,
    required this.api,
    required this.periodo,
    required this.ultimaData,
    required this.botaoInicial,
    this.customRange,
    this.item,
    this.type,
    required this.onBack,
  });

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  // Botão da tela → botão que periodoDaConsulta entende.
  static const _botaoDoFiltro = {
    'Diário': 'hoje',
    'Semanal': 'semana',
    'Quinzenal': 'quinzena',
    'Mensal': 'mes',
  };

  // Período próprio da tela: começa igual ao do dashboard, mas muda sozinho
  // aqui dentro, sem alterar o dashboard.
  late PeriodoConsulta _periodo;
  late String _periodFilter;
  String _dayFilter = 'Todos';
  String _lineFilter = 'Todas as linhas';
  DateTimeRange? _customRange;
  _ChartType _chartType = _ChartType.automatico;
  late Future<Indicadores> _indicadores;

  /// null: período de um dia num indicador que a SEMOB não envia por hora.
  Future<_SerieGrafico>? _serie;

  // Ficam aqui, e não num widget próprio, porque o bloco por linha e o seletor
  // de linha usam os mesmos dados. _porLinha continua preenchido durante uma
  // nova busca: as linhas não mudam com o período, e o seletor segue funcionando.
  PorLinha? _porLinha;
  bool _carregandoPorLinha = false;
  String? _erroPorLinha;

  /// Identifica a busca mais recente. Uma resposta com número menor é velha.
  int _buscaPorLinha = 0;

  @override
  void initState() {
    super.initState();
    _usarPeriodoDoDashboard();
    _buscar();
    _buscarSerie();
    _buscarPorLinha();
  }

  @override
  void didUpdateWidget(covariant DetalhesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.periodo != widget.periodo) {
      _usarPeriodoDoDashboard();
      _buscar();
    }
    // A série também depende do indicador (qual métrica, se há dado por hora).
    if (oldWidget.periodo != widget.periodo || oldWidget.type != widget.type) {
      _buscarSerie();
      _buscarPorLinha();
    }
  }

  void _usarPeriodoDoDashboard() {
    _periodo = widget.periodo;
    _customRange = widget.customRange;
    _periodFilter = switch (widget.botaoInicial) {
      'semana' => 'Semanal',
      'mes' || 'mês' => 'Mensal',
      'personalizado' => 'Personalizado',
      _ => 'Diário',
    };
  }

  void _selecionarPeriodo(String filtro, String botao) {
    final novo = periodoDaConsulta(
      botao: botao,
      ultimaData: widget.ultimaData,
      personalizado: _customRange,
    );

    setState(() {
      _periodFilter = filtro;
      if (novo != _periodo) {
        _periodo = novo;
        _buscar();
        _buscarSerie();
        _buscarPorLinha();
      }
    });
  }

  /// Passageiros, gratuidades e financeiro não vêm por linha.
  bool get _temPorLinha =>
      _type == InvestigationType.quilometragem ||
      _type == InvestigationType.viagens;

  /// Código da linha do filtro ("06"), ou null para todas. O botão só existe em
  /// quilometragem e viagens: nos outros indicadores o filtro nunca vale.
  String? get _linhaEscolhida {
    if (!_temPorLinha || _lineFilter == 'Todas as linhas') return null;
    return _lineFilter.substring('Linha '.length);
  }

  // Não chama setState, igual a _buscar e _buscarSerie: quem chama decide. O
  // setState não aceita função async, por isso a espera fica em outro método.
  void _buscarPorLinha() {
    if (!_temPorLinha) return;
    _carregandoPorLinha = true;
    _erroPorLinha = null;
    _aguardarPorLinha(++_buscaPorLinha);
  }

  Future<void> _aguardarPorLinha(int busca) async {
    try {
      final resposta = await widget.api.porLinha(
        dataInicio: _periodo.inicio,
        dataFim: _periodo.fim,
      );
      if (!mounted || busca != _buscaPorLinha) return;

      setState(() {
        _porLinha = resposta;
        _carregandoPorLinha = false;
      });
    } catch (e) {
      if (!mounted || busca != _buscaPorLinha) return;

      setState(() {
        _erroPorLinha = e.toString();
        _carregandoPorLinha = false;
      });
    }
  }

  // Mesma chamada do dashboard: o número grande daqui bate com o do cartão.
  void _buscar() {
    _indicadores = widget.api.indicadores(
      dataInicio: _periodo.inicio,
      dataFim: _periodo.fim,
      comparacao: _periodo.comparacao,
    );
  }

  InvestigationType get _type => widget.type ?? InvestigationType.quilometragem;

  void _buscarSerie() {
    final inicio = _periodo.inicio;
    final fim = _periodo.fim;
    final type = _type;
    final linha = _linhaEscolhida;

    if (type == InvestigationType.operacaoLinhas) {
      _serie = null;
    } else if (inicio == fim) {
      final temPorHora = type == InvestigationType.quilometragem ||
          type == InvestigationType.viagens;
      _serie = temPorHora
          ? widget.api
              .porHora(dataInicio: inicio, dataFim: fim, linha: linha)
              .then((dados) => _seriePorHora(type, dados))
          : null;
    } else {
      _serie = widget.api
          .relatorio(
            dataInicio: inicio,
            dataFim: fim,
            agrupamento: 'diario',
            linha: linha,
          )
          .then((itens) => _seriePorDia(type, inicio, fim, itens));
    }
  }

  _SerieGrafico _seriePorHora(InvestigationType type, PorHora dados) {
    final km = type == InvestigationType.quilometragem;

    return _SerieGrafico(
      // Hora sem viagem é zero de verdade (o backend manda as 24 horas).
      // Já um dia sem operação nenhuma (dias == 0) é falta de dado: buraco.
      valores: [
        for (final h in dados.horas)
          dados.dias == 0
              ? null
              : (km ? h.quilometragem : h.viagens).toDouble(),
      ],
      rotulos: [for (final h in dados.horas) '${h.hora}h'],
      kmImprodutivo: km ? dados.kmImprodutivoSemHora : 0,
    );
  }

  _SerieGrafico _seriePorDia(
    InvestigationType type,
    DateTime inicio,
    DateTime fim,
    List<RelatorioItem> itens,
  ) {
    // Indexa pela data: dia que não veio no relatório (sem operação) vira buraco
    // no lugar certo, em vez de puxar os dias seguintes uma posição para trás.
    final porDia = {for (final item in itens) formatarDia(item.inicio): item};

    // DateTime(ano, mês, dia + 1) em vez de add(Duration(days: 1)): o construtor
    // sempre cai na meia-noite do dia seguinte, mesmo com horário de verão.
    final dias = [
      for (var d = inicio;
          !d.isAfter(fim);
          d = DateTime(d.year, d.month, d.day + 1))
        d,
    ];

    return _SerieGrafico(
      valores: [
        for (final d in dias) _metrica(type, porDia[formatarDia(d)])?.toDouble(),
      ],
      rotulos: [for (final d in dias) _formatDate(d)],
      kmImprodutivo: 0,
    );
  }

  /// null quando o dia não veio no relatório ou o relatório mandou null.
  num? _metrica(InvestigationType type, RelatorioItem? item) {
    if (item == null) return null;

    return switch (type) {
      InvestigationType.quilometragem => item.quilometragem,
      InvestigationType.viagens => item.viagens,
      InvestigationType.pagantes => item.passageirosPagantes,
      InvestigationType.gratuidades => item.passageirosNaoPagantes,
      // Provisório, igual ao cartão: créditos vendidos.
      InvestigationType.financeiro => item.creditosVendidos,
      InvestigationType.operacaoLinhas => null,
    };
  }

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
              // Voltar e título ficam fora do FutureBuilder: carregando ou com
              // erro, o usuário sempre consegue voltar ao dashboard.
              FutureBuilder<Indicadores>(
                future: _indicadores,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return ErroCarregamento(
                      mensagem: snapshot.error.toString(),
                      onTentarNovamente: () => setState(_buscar),
                    );
                  }
                  return _buildConteudo(config, type, snapshot.data!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConteudo(
    _InvestigationConfig config,
    InvestigationType type,
    Indicadores dados,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilters(),
        const SizedBox(height: 20),
        _buildMainKpi(config, type, dados),
        const SizedBox(height: 20),
        _buildChartSection(config, type),
        const SizedBox(height: 20),
        if (type == InvestigationType.viagens) ...[
          // 'falhas' na key: esta seção e a de baixo ficam na mesma Column, e
          // duas irmãs não podem ter keys iguais.
          _FalhasPorHorarioSection(
            key: ValueKey(('falhas', _periodo, _linhaEscolhida)),
            api: widget.api,
            periodo: _periodo,
            linha: _linhaEscolhida,
          ),
          const SizedBox(height: 20),
          // A key faz o Flutter criar a seção do zero quando o período ou a
          // linha mudam: ela volta para "Todas", página 1, sem limpar nada à mão.
          _ViagensNaoCumpridasSection(
            key: ValueKey((_periodo, _linhaEscolhida)),
            api: widget.api,
            periodo: _periodo,
            linha: _linhaEscolhida,
          ),
          const SizedBox(height: 20),
        ],
        if (type == InvestigationType.pagantes ||
            type == InvestigationType.gratuidades)
          ...[
            _buildPassengerComposition(dados),
            const SizedBox(height: 20),
          ],
        if (_temPorLinha) _buildByLine(type),
      ],
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
              const SizedBox(height: 8),
              Text(
                'Período: ${rotuloPeriodo(_periodo.inicio, _periodo.fim)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
          if (_temPorLinha)
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
      final ultima = widget.ultimaData;
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024),
        lastDate: ultima,
        initialDateRange: _customRange ??
            DateTimeRange(
              start: DateTime(ultima.year, ultima.month, ultima.day - 6),
              end: DateTime(ultima.year, ultima.month, ultima.day),
            ),
        helpText: 'Selecionar período da investigação',
        saveText: 'Aplicar',
        cancelText: 'Cancelar',
        confirmText: 'Aplicar',
      );

      // O usuário pode ter saído da tela com o calendário aberto.
      if (range == null || !mounted) return;

      _customRange = range;
      _selecionarPeriodo('Personalizado', 'personalizado');
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

    final botao = _botaoDoFiltro[label];
    if (botao == null || label == _periodFilter) return;

    _selecionarPeriodo(label, botao);
  }

  Future<void> _showLinePicker() async {
    // "Linha 06", e não só "06": o rótulo vira o texto do botão, e _handleFilter
    // reconhece o botão de linha por esse começo.
    final linhas = _porLinha?.linhas;
    final lines = <String>[
      'Todas as linhas',
      ...?linhas?.map((l) => 'Linha ${l.linha}'),
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
              // A lista vem da rota: pode ainda não ter chegado, ou ter falhado.
              if (linhas == null)
                ListTile(
                  enabled: false,
                  title: Text(
                    _erroPorLinha == null
                        ? 'Carregando as linhas…'
                        : 'Não foi possível carregar as linhas.',
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _lineFilter) {
      // Só o gráfico precisa buscar: o número principal e o bloco saem de
      // _porLinha, que já tem todas as linhas, e a seção de não cumpridas
      // busca sozinha porque a key dela muda.
      setState(() {
        _lineFilter = selected;
        _buscarSerie();
      });
    }
  }

  Widget _buildMainKpi(
    _InvestigationConfig config,
    InvestigationType type,
    Indicadores dados,
  ) {
    final kpi = _kpiPrincipal(type, dados);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE1E6EF),
          width: 1.4,
        ),
      ),
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
              kpi.semDados ? '—' : kpi.valor,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            kpi.semDados ? 'Sem dados neste período' : kpi.detalhe,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Mesmo valor, formatação e regra de "sem dados" do cartão do dashboard.
  ({String valor, String detalhe, bool semDados}) _kpiPrincipal(
    InvestigationType type,
    Indicadores dados,
  ) {
    final linha = _linhaEscolhida;
    if (linha != null) return _kpiDaLinha(type, linha);

    return switch (type) {
      InvestigationType.quilometragem => (
        valor: Formatters.number(dados.quilometragem),
        detalhe: 'km realizados',
        semDados: dados.diasOperacao == 0,
      ),
      InvestigationType.viagens => (
        valor: Formatters.number(dados.viagens),
        detalhe: 'de ${Formatters.number(dados.viagensProgramadas)} programadas',
        semDados: dados.diasOperacao == 0,
      ),
      InvestigationType.pagantes => (
        valor: Formatters.number(dados.passageirosPagantes),
        detalhe: 'passageiros pagantes',
        semDados: dados.diasPassageiros == 0,
      ),
      InvestigationType.gratuidades => (
        valor: Formatters.number(dados.passageirosNaoPagantes),
        detalhe: 'passageiros não pagantes',
        semDados: dados.diasPassageiros == 0,
      ),
      // Provisório, igual ao cartão: vendidos em destaque, utilizados embaixo.
      InvestigationType.financeiro => (
        valor: Formatters.currency(dados.creditosVendidos),
        detalhe:
            'em créditos vendidos · ${Formatters.currency(dados.creditosUtilizados)} utilizados',
        semDados: dados.diasFinanceiro == 0,
      ),
      // build() desvia operacaoLinhas para outra tela antes de chegar aqui.
      InvestigationType.operacaoLinhas => throw StateError(
        'Operação das linhas não tem número principal.',
      ),
    };
  }

  /// Durante uma nova busca, _porLinha ainda é do período anterior: mostrar esse
  /// valor seria errado, e mostrar o total geral pareceria ser o da linha.
  ({String valor, String detalhe, bool semDados}) _kpiDaLinha(
    InvestigationType type,
    String linha,
  ) {
    ({String valor, String detalhe, bool semDados}) aviso(String texto) =>
        (valor: '—', detalhe: texto, semDados: false);

    if (_carregandoPorLinha) return aviso('Carregando a Linha $linha…');

    final item = _porLinha?.linhas.where((l) => l.linha == linha).firstOrNull;
    if (_erroPorLinha != null || item == null) {
      return aviso('Não foi possível carregar a Linha $linha');
    }

    if (type == InvestigationType.viagens) {
      if (item.programadas == 0) return aviso('Não rodou no período');
      return (
        valor: Formatters.number(item.viagens),
        detalhe: 'de ${Formatters.number(item.programadas)} programadas '
            'na Linha $linha',
        semDados: false,
      );
    }

    if (item.quilometragem == 0) return aviso('Não rodou no período');
    return (
      valor: Formatters.number(item.quilometragem),
      detalhe: 'km realizados na Linha $linha',
      semDados: false,
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
          _buildChartBody(
            current == _ChartType.automatico ? _recommendedChart(type) : current,
          ),
          const SizedBox(height: 10),
          Text(
            'Período: ${rotuloPeriodo(_periodo.inicio, _periodo.fim)} • '
            '${_linhaEscolhida == null ? 'todas as linhas' : _lineFilter}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBody(_ChartType chartType) {
    final serie = _serie;

    if (serie == null) {
      return const _ChartMessage(
        'A SEMOB não envia esse dado por hora. Escolha um período de mais de '
        'um dia para ver a evolução.',
      );
    }

    // Altura fixa nos três estados: a tela não "pula" quando o dado chega.
    return FutureBuilder<_SerieGrafico>(
      future: serie,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: ErroCarregamento(
              mensagem: snapshot.error.toString(),
              onTentarNovamente: () => setState(_buscarSerie),
            ),
          );
        }

        final dados = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: _Chart(
                type: chartType,
                values: dados.valores,
                labels: dados.rotulos,
                color: AppColors.primary,
                secondaryColor: const Color(0xFF7FA2D4),
              ),
            ),
            if (dados.kmImprodutivo > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${_umDecimal.format(dados.kmImprodutivo)} km improdutivos não '
                'têm horário e não aparecem no gráfico',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        );
      },
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  Widget _buildPassengerComposition(Indicadores dados) {
    final pagantes = dados.passageirosPagantes;
    final gratuidades = dados.passageirosNaoPagantes;
    final total = pagantes + gratuidades;

    final decoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE1E6EF)),
    );

    // Sem passageiros (antes de 15/07/2026) ou total zero: as porcentagens
    // dividiriam por zero, então não há rosca para desenhar.
    if (dados.diasPassageiros == 0 || total == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: decoration,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Composição dos passageiros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Sem dados de passageiros neste período',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: decoration,
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
                'Divisão dos passageiros do período entre pagantes e gratuidades.',
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
    num value,
    num total,
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
          Formatters.number(value),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Text(
          '${_umDecimal.format(value / total * 100)}%',
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
          // Sem o corte, o fundo da linha em destaque sairia dos cantos redondos.
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E6EF)),
          ),
          child: _buildCorpoPorLinha(type),
        ),
        if (type == InvestigationType.quilometragem) ...[
          const SizedBox(height: 8),
          const Text(
            avisoKmPorLinha,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildCorpoPorLinha(InvestigationType type) {
    if (_carregandoPorLinha) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_erroPorLinha != null) {
      return ErroCarregamento(
        mensagem: _erroPorLinha!,
        onTentarNovamente: () => setState(_buscarPorLinha),
      );
    }

    final dados = _porLinha;
    if (dados == null || dados.linhas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Nenhuma linha encontrada.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < dados.linhas.length; i++)
          _buildLineRow(
            dados.linhas[i],
            dados.totais,
            type,
            i == dados.linhas.length - 1,
          ),
      ],
    );
  }

  /// barra null: a linha não rodou no período, então não há barra.
  ({String texto, double? barra}) _resumoDaLinha(
    PorLinhaItem linha,
    PorLinhaTotais totais,
    InvestigationType type,
  ) {
    const naoRodou = (texto: 'Não rodou no período', barra: null);

    if (type == InvestigationType.viagens) {
      if (linha.programadas == 0) return naoRodou;
      return (
        texto: '${Formatters.number(linha.viagens)} de '
            '${Formatters.number(linha.programadas)} programadas',
        barra: linha.viagens / linha.programadas,
      );
    }

    // Km > 0 aqui garante total > 0: a divisão é segura.
    if (linha.quilometragem == 0) return naoRodou;
    final parte = linha.quilometragem / totais.quilometragem;
    return (
      texto: '${Formatters.number(linha.quilometragem)} km · '
          '${Formatters.percentage(parte * 100, showSign: false)} do total',
      barra: parte.toDouble(),
    );
  }

  Widget _buildLineRow(
    PorLinhaItem linha,
    PorLinhaTotais totais,
    InvestigationType type,
    bool isLast,
  ) {
    final (:texto, :barra) = _resumoDaLinha(linha, totais, type);
    final escolhida = linha.linha == _linhaEscolhida;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        // O bloco continua com todas as linhas, para comparar; a escolhida só
        // ganha destaque.
        color: escolhida ? AppColors.primaryLight : null,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap: no celular o que não couber desce de linha, sem estourar.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                // Em texto também: só a cor não basta para quem não a distingue.
                escolhida
                    ? 'Linha ${linha.linha} · selecionada'
                    : 'Linha ${linha.linha}',
                style: TextStyle(
                  fontWeight: escolhida ? FontWeight.w800 : FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                texto,
                style: TextStyle(
                  fontWeight: barra == null ? FontWeight.w400 : FontWeight.w800,
                  color: barra == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (barra != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: barra,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              color: AppColors.primary,
              backgroundColor: const Color(0xFFE9EDF4),
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
          analysisTitle: 'Evolução da quilometragem',
          analysisDescription:
              'Compare a quilometragem realizada ao longo do período e identifique desvios relevantes.',
        );
      case InvestigationType.viagens:
        return const _InvestigationConfig(
          title: 'Viagens',
          description:
              'Acompanhe a execução das viagens previstas e identifique viagens não realizadas.',
          icon: Icons.directions_bus,
          analysisTitle: 'Viagens realizadas',
          analysisDescription:
              'Acompanhe a execução das viagens e localize desvios ao longo do período.',
        );
      case InvestigationType.pagantes:
        return const _InvestigationConfig(
          title: 'Passageiros Pagantes',
          description:
              'Acompanhe a demanda de passageiros pagantes do sistema.',
          icon: Icons.people,
          analysisTitle: 'Evolução dos passageiros pagantes',
          analysisDescription:
              'Observe a evolução da demanda e compare o comportamento das linhas.',
        );
      case InvestigationType.gratuidades:
        return const _InvestigationConfig(
          title: 'Gratuidades',
          description:
              'Acompanhe os passageiros não pagantes e sua distribuição no sistema.',
          icon: Icons.card_membership,
          analysisTitle: 'Evolução das gratuidades',
          analysisDescription:
              'Observe a evolução dos passageiros não pagantes e identifique concentrações.',
        );
      case InvestigationType.financeiro:
        return const _InvestigationConfig(
          title: 'Financeiro',
          description:
              'Acompanhe a arrecadação tarifária e os registros financeiros consolidados.',
          icon: Icons.attach_money,
          analysisTitle: 'Evolução financeira',
          analysisDescription:
              'Compare a arrecadação ao longo do período operacional.',
        );
      case InvestigationType.operacaoLinhas:
        return const _InvestigationConfig(
          title: 'Operação das linhas',
          description: 'Compare as 10 linhas do sistema pelo programado e realizado.',
          icon: Icons.directions_bus_filled_outlined,
          analysisTitle: 'Programado × realizado',
          analysisDescription: 'Verifique quais linhas cumpriram, fizeram menos ou fizeram mais viagens.',
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

/// Viagens programadas que não foram cumpridas no período, uma por uma.
/// Tem estado próprio: carregar, filtrar ou paginar aqui não reconstrói nem
/// derruba o resto da tela.
class _ViagensNaoCumpridasSection extends StatefulWidget {
  final OperacaoApi api;
  final PeriodoConsulta periodo;

  /// Código da linha ("06"), ou null para todas.
  final String? linha;

  const _ViagensNaoCumpridasSection({
    super.key,
    required this.api,
    required this.periodo,
    this.linha,
  });

  @override
  State<_ViagensNaoCumpridasSection> createState() =>
      _ViagensNaoCumpridasSectionState();
}

class _ViagensNaoCumpridasSectionState
    extends State<_ViagensNaoCumpridasSection> {
  /// null: "Todas".
  String? _tipo;

  /// Vêm só da busca sem filtro de tipo, porque com filtro a API devolve
  /// apenas a contagem daquele tipo. null: ainda não chegaram.
  Map<String, int>? _contagens;
  int _totalGeral = 0;

  List<ViagemNaoCumprida> _itens = const [];

  /// Total do filtro atual: é ele que diz se ainda há página para carregar.
  int _total = 0;
  int _pagina = 1;
  bool _carregando = true;
  String? _erro;

  /// Identifica a busca mais recente. Uma resposta com número menor é velha.
  int _buscaAtual = 0;

  @override
  void initState() {
    super.initState();
    _buscarPagina(1);
  }

  Future<void> _buscarPagina(int pagina) async {
    final busca = ++_buscaAtual;
    final tipo = _tipo;

    try {
      final resposta = await widget.api.viagensNaoCumpridas(
        dataInicio: widget.periodo.inicio,
        dataFim: widget.periodo.fim,
        tipo: tipo,
        linha: widget.linha,
        pagina: pagina,
      );
      if (!mounted || busca != _buscaAtual) return;

      setState(() {
        if (tipo == null) {
          _contagens = resposta.totalPorTipo;
          _totalGeral = resposta.total;
        }
        _itens = pagina == 1 ? resposta.itens : [..._itens, ...resposta.itens];
        _total = resposta.total;
        _pagina = pagina;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted || busca != _buscaAtual) return;

      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  void _recarregar() {
    setState(() {
      _itens = const [];
      _total = 0;
      _erro = null;
      _carregando = true;
    });
    _buscarPagina(1);
  }

  void _carregarMais() {
    setState(() {
      _erro = null;
      _carregando = true;
    });
    _buscarPagina(_pagina + 1);
  }

  void _selecionarTipo(String? tipo) {
    if (tipo == _tipo) return;
    _tipo = tipo;
    _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    final contagens = _contagens;
    final linha = widget.linha;
    final daLinha = linha == null ? '' : ' da Linha $linha';

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
          const Text(
            'Viagens não cumpridas',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          if (_totalGeral > 0)
            Text(
              _totalGeral == 1
                  ? '1 viagem programada$daLinha não foi cumprida no período.'
                  : '${Formatters.number(_totalGeral)} viagens programadas'
                      '$daLinha não foram cumpridas no período.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          const Text(
            'A lista vem dos relatórios da SEMOB, que não informam o motivo de '
            'cada falha.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          if (contagens != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _botaoTipo('Todas', null, _totalGeral),
                _botaoTipo('Não realizadas', 'nao_realizada',
                    contagens['nao_realizada'] ?? 0),
                _botaoTipo('Não iniciadas', 'nao_iniciada',
                    contagens['nao_iniciada'] ?? 0),
                _botaoTipo('Não terminadas', 'nao_terminada',
                    contagens['nao_terminada'] ?? 0),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ..._buildLista(),
        ],
      ),
    );
  }

  Widget _botaoTipo(String rotulo, String? tipo, int quantidade) {
    final selecionado = _tipo == tipo;

    return OutlinedButton(
      onPressed: quantidade == 0 ? null : () => _selecionarTipo(tipo),
      style: OutlinedButton.styleFrom(
        foregroundColor: selecionado ? Colors.white : AppColors.textPrimary,
        backgroundColor: selecionado ? AppColors.primary : Colors.white,
        side: BorderSide(
          color: selecionado ? AppColors.primary : const Color(0xFFD9DEE7),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      child: Text('$rotulo (${Formatters.number(quantidade)})'),
    );
  }

  List<Widget> _buildLista() {
    if (_itens.isEmpty) {
      if (_carregando) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];
      }
      if (_erro != null) {
        return [
          ErroCarregamento(mensagem: _erro!, onTentarNovamente: _recarregar),
        ];
      }
      // Com linha, a frase é outra: uma linha que não rodou não teve viagem
      // programada, e "todas foram realizadas" passaria a ideia errada.
      final linha = widget.linha;
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              linha == null
                  ? 'Todas as viagens programadas do período foram realizadas.'
                  : 'Nenhuma viagem programada da Linha $linha deixou de ser '
                      'cumprida no período.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ];
    }

    return [
      for (final viagem in _itens)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ViagemNaoCumpridaCard(viagem: viagem),
        ),
      // Falha ao carregar mais: o que já veio continua na tela.
      if (_erro != null)
        ErroCarregamento(mensagem: _erro!, onTentarNovamente: _carregarMais)
      else if (_itens.length < _total)
        Center(
          child: _carregando
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                )
              : OutlinedButton(
                  onPressed: _carregarMais,
                  child: const Text('Carregar mais'),
                ),
        ),
    ];
  }
}

class _ViagemNaoCumpridaCard extends StatelessWidget {
  final ViagemNaoCumprida viagem;

  const _ViagemNaoCumpridaCard({required this.viagem});

  String _doisDigitos(int n) => n.toString().padLeft(2, '0');

  String get _data => '${_doisDigitos(viagem.data.day)}/'
      '${_doisDigitos(viagem.data.month)}/${viagem.data.year}';

  /// "23:55", ou "00:40 (11/09)" quando cai em outro dia que não o da viagem.
  /// Usa os campos do horário direto: ele já está no horário de São Paulo.
  String _horario(DateTime? h) {
    if (h == null) return '—';
    final hora = '${_doisDigitos(h.hour)}:${_doisDigitos(h.minute)}';
    return DateUtils.isSameDay(h, viagem.data)
        ? hora
        : '$hora (${_doisDigitos(h.day)}/${_doisDigitos(h.month)})';
  }

  /// (fundo, texto) do selo. As cores semânticas já têm contraste legível.
  (Color, Color) get _coresDoTipo => switch (viagem.tipo) {
        'nao_realizada' => (AppColors.dangerBg, AppColors.dangerText),
        'nao_iniciada' => (AppColors.warningBg, AppColors.warningText),
        'nao_terminada' => (AppColors.infoBg, AppColors.infoText),
        _ => (AppColors.borderSubtle, AppColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    final (fundoSelo, textoSelo) = _coresDoTipo;

    // O fundo fica no Material, e não num Container, para o efeito de toque
    // do ExpansionTile aparecer: um Container por cima o esconderia.
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE1E6EF)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        expandedAlignment: Alignment.centerLeft,
        // Wrap: no celular o que não couber desce de linha, sem estourar.
        title: Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Linha ${viagem.linha}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: fundoSelo,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                viagem.tipoRotulo,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textoSelo,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _resumo(_data),
              _resumo(
                '${_horario(viagem.inicioProgramado)} → '
                '${_horario(viagem.fimProgramado)}',
              ),
              _resumo('Sentido: ${rotuloSentido(viagem.sentido)}'),
              _resumo('Tabela ${viagem.tabela}'),
            ],
          ),
        ),
        children: [
          Wrap(
            spacing: 28,
            runSpacing: 12,
            children: [
              _campo('Motorista', viagem.motorista),
              _campo('Veículo', viagem.prefixo ?? '—'),
              _campo('Atendimento', viagem.atendimento),
              _campo('Atividade', viagem.atividade),
              _campo('Início realizado', _horario(viagem.inicioRealizado)),
              _campo('Fim realizado', _horario(viagem.fimRealizado)),
              // Mostrados como vêm: o significado dos códigos ainda é uma
              // pergunta para a SEMOB.
              _campo('Status de saída', viagem.statusSaida ?? '—'),
              _campo('Status de chegada', viagem.statusChegada ?? '—'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumo(String texto) => Text(
        texto,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      );

  Widget _campo(String rotulo, String valor) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
}

/// Abaixo disso, a tela avisa que não dá para concluir um padrão por horário.
/// É um critério prático, ajustável, e não um valor estatístico.
const _minimoFalhasParaPadrao = 10;

/// Na ordem do empilhamento, de baixo para cima. As cores são as mesmas famílias
/// dos selos da lista, na versão forte: os tons de texto dos selos são escuros e
/// parecidos demais entre si para distinguir pedaços de uma barra.
final _tiposDeFalha = <({
  String rotulo,
  Color cor,
  int Function(FalhasPorHora) valor,
})>[
  (
    rotulo: 'Não realizadas',
    cor: AppColors.danger,
    valor: (f) => f.naoRealizada,
  ),
  (
    rotulo: 'Não iniciadas',
    cor: AppColors.warning,
    valor: (f) => f.naoIniciada,
  ),
  (
    rotulo: 'Não terminadas',
    cor: AppColors.info,
    valor: (f) => f.naoTerminada,
  ),
];

/// Falhas por hora programada de saída e cumprimento por turno.
class _FalhasPorHorarioSection extends StatefulWidget {
  final OperacaoApi api;
  final PeriodoConsulta periodo;

  /// Código da linha ("06"), ou null para todas.
  final String? linha;

  const _FalhasPorHorarioSection({
    super.key,
    required this.api,
    required this.periodo,
    this.linha,
  });

  @override
  State<_FalhasPorHorarioSection> createState() =>
      _FalhasPorHorarioSectionState();
}

class _FalhasPorHorarioSectionState extends State<_FalhasPorHorarioSection> {
  // Estados separados para as duas rotas: se o cumprimento falhar, o gráfico de
  // falhas continua na tela, e vice-versa.
  PorHora? _horas;
  bool _carregandoHoras = true;
  String? _erroHoras;
  int _buscaHoras = 0;

  Cumprimento? _turnos;
  bool _carregandoTurnos = true;
  String? _erroTurnos;
  int _buscaTurnos = 0;

  @override
  void initState() {
    super.initState();
    _buscarHoras();
    // Com linha, nem chama: a rota só tem a cidade inteira.
    if (widget.linha == null) _buscarTurnos();
  }

  Future<void> _buscarHoras() async {
    final busca = ++_buscaHoras;

    try {
      final resposta = await widget.api.porHora(
        dataInicio: widget.periodo.inicio,
        dataFim: widget.periodo.fim,
        linha: widget.linha,
      );
      if (!mounted || busca != _buscaHoras) return;

      setState(() {
        _horas = resposta;
        _carregandoHoras = false;
      });
    } catch (e) {
      if (!mounted || busca != _buscaHoras) return;

      setState(() {
        _erroHoras = e.toString();
        _carregandoHoras = false;
      });
    }
  }

  Future<void> _buscarTurnos() async {
    final busca = ++_buscaTurnos;

    try {
      final resposta = await widget.api.cumprimento(
        dataInicio: widget.periodo.inicio,
        dataFim: widget.periodo.fim,
      );
      if (!mounted || busca != _buscaTurnos) return;

      setState(() {
        _turnos = resposta;
        _carregandoTurnos = false;
      });
    } catch (e) {
      if (!mounted || busca != _buscaTurnos) return;

      setState(() {
        _erroTurnos = e.toString();
        _carregandoTurnos = false;
      });
    }
  }

  void _tentarHorasDeNovo() {
    setState(() {
      _erroHoras = null;
      _carregandoHoras = true;
    });
    _buscarHoras();
  }

  void _tentarTurnosDeNovo() {
    setState(() {
      _erroTurnos = null;
      _carregandoTurnos = true;
    });
    _buscarTurnos();
  }

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Falhas por horário',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildFalhas(),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE1E6EF)),
          const SizedBox(height: 18),
          const Text(
            'Cumprimento por turno',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ..._buildTurnos(),
        ],
      ),
    );
  }

  List<Widget> _buildFalhas() {
    if (_carregandoHoras) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_erroHoras != null) {
      return [
        ErroCarregamento(
          mensagem: _erroHoras!,
          onTentarNovamente: _tentarHorasDeNovo,
        ),
      ];
    }

    final horas = _horas!.horas;
    final totais = [
      for (final tipo in _tiposDeFalha)
        horas.fold<int>(0, (soma, h) => soma + tipo.valor(h.falhas)),
    ];
    final total = totais.fold<int>(0, (soma, t) => soma + t);

    return [
      if (total == 0)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'Nenhuma falha no período.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        )
      else ...[
        if (total < _minimoFalhasParaPadrao) ...[
          _avisoPoucasFalhas(total),
          const SizedBox(height: 14),
        ],
        _GraficoFalhas(horas: horas),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            for (var i = 0; i < _tiposDeFalha.length; i++)
              _itemLegenda(_tiposDeFalha[i].cor, _tiposDeFalha[i].rotulo,
                  totais[i]),
          ],
        ),
      ],
      const SizedBox(height: 12),
      const Text(
        'Mostra a quantidade de falhas pela hora programada de saída. Nos '
        'horários de pico saem mais viagens, então é natural que apareçam mais '
        'falhas.',
        style: TextStyle(
          fontSize: 12,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
    ];
  }

  Widget _avisoPoucasFalhas(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        'Poucas falhas no período ($total). Não dá para concluir um padrão por '
        'horário.',
        style: const TextStyle(fontSize: 13, color: AppColors.warningText),
      ),
    );
  }

  Widget _itemLegenda(Color cor, String rotulo, int total) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$rotulo: ${Formatters.number(total)}',
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  List<Widget> _buildTurnos() {
    // Não mostra o número da cidade ao lado do gráfico da linha: confundiria.
    if (widget.linha != null) {
      return const [
        Text(
          'O cumprimento por turno só existe para a cidade inteira.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ];
    }
    if (_carregandoTurnos) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_erroTurnos != null) {
      return [
        ErroCarregamento(
          mensagem: _erroTurnos!,
          onTentarNovamente: _tentarTurnosDeNovo,
        ),
      ];
    }

    final turnos = _turnos!;

    return [
      LayoutBuilder(
        builder: (context, constraints) {
          const espaco = 10.0;
          // Três colunas onde couber; no celular, um bloco embaixo do outro.
          final largura = constraints.maxWidth >= 600
              ? (constraints.maxWidth - 2 * espaco) / 3
              : constraints.maxWidth;

          return Wrap(
            spacing: espaco,
            runSpacing: espaco,
            children: [
              SizedBox(
                width: largura,
                child: _blocoTurno('Manhã', turnos.manha),
              ),
              SizedBox(
                width: largura,
                child: _blocoTurno('Tarde', turnos.tarde),
              ),
              SizedBox(
                width: largura,
                child: _blocoTurno('Noite', turnos.noite),
              ),
              SizedBox(
                width: constraints.maxWidth,
                child: _blocoTurno('Total do período', turnos.total),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 10),
      const Text(
        'Divisão de turnos dos relatórios da SEMOB. Os horários de cada turno '
        'não foram informados.',
        style: TextStyle(
          fontSize: 12,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
    ];
  }

  Widget _blocoTurno(String nome, CumprimentoTurno turno) {
    final percentual = turno.percentual;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nome,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.cumprimento(turno.realizadas, turno.programadas),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            percentual == null
                ? 'Sem viagens programadas'
                : '${Formatters.number(turno.realizadas)} de '
                    '${Formatters.number(turno.programadas)} programadas',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (percentual != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: turno.realizadas / turno.programadas,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              color: AppColors.primary,
              backgroundColor: const Color(0xFFE9EDF4),
            ),
          ],
        ],
      ),
    );
  }
}

/// Barras empilhadas de 0h a 23h. Passar o mouse ou tocar mostra os números.
class _GraficoFalhas extends StatefulWidget {
  final List<PorHoraItem> horas;

  const _GraficoFalhas({required this.horas});

  @override
  State<_GraficoFalhas> createState() => _GraficoFalhasState();
}

class _GraficoFalhasState extends State<_GraficoFalhas> {
  static const _larguraDica = 170.0;

  /// Posição em [widget.horas] da barra apontada; null: nenhuma.
  int? _apontada;

  void _apontar(double x, double largura) {
    final area = largura - _FalhasPainter.margemEsquerda;
    final coluna = (x - _FalhasPainter.margemEsquerda) / area * widget.horas.length;
    final nova = coluna < 0
        ? null
        : math.min(coluna.floor(), widget.horas.length - 1);

    if (nova != _apontada) setState(() => _apontada = nova);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth;
          final apontada = _apontada;

          return Stack(
            children: [
              MouseRegion(
                onHover: (e) => _apontar(e.localPosition.dx, largura),
                onExit: (_) => setState(() => _apontada = null),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (e) => _apontar(e.localPosition.dx, largura),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _FalhasPainter(
                      horas: widget.horas,
                      apontada: apontada,
                    ),
                  ),
                ),
              ),
              if (apontada != null)
                Positioned(
                  top: 0,
                  left: _posicaoDaDica(apontada, largura),
                  width: _larguraDica,
                  // Não pode roubar o mouse: a dica fica por cima do gráfico.
                  child: IgnorePointer(child: _dica(widget.horas[apontada])),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Ao lado da barra, para não cobri-la; na metade direita, à esquerda dela.
  double _posicaoDaDica(int indice, double largura) {
    final area = largura - _FalhasPainter.margemEsquerda;
    final coluna = area / widget.horas.length;
    final centro = _FalhasPainter.margemEsquerda + coluna * (indice + 0.5);
    final desejada = indice < widget.horas.length / 2
        ? centro + 12
        : centro - 12 - _larguraDica;

    return desejada.clamp(0.0, math.max(0.0, largura - _larguraDica));
  }

  Widget _dica(PorHoraItem hora) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFD9DEE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${hora.hora}h',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          for (final tipo in _tiposDeFalha)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: tipo.cor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${tipo.rotulo}: ${tipo.valor(hora.falhas)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
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
}

/// Maior múltiplo "redondo" (1, 2, 5, 10, 20...) que divide o eixo em no máximo
/// 5 faixas. Como é inteiro e o eixo sai de 0, as marcas são sempre inteiras.
int _passoDoEixo(int maximo) {
  var base = 1;
  while (true) {
    for (final fator in const [1, 2, 5]) {
      final passo = base * fator;
      if (maximo / passo <= 5) return passo;
    }
    base *= 10;
  }
}

class _FalhasPainter extends CustomPainter {
  static const margemEsquerda = 30.0;
  static const _margemBaixo = 22.0;
  static const _margemTopo = 8.0;

  /// Espaço branco entre os pedaços empilhados.
  static const _vao = 2.0;

  final List<PorHoraItem> horas;
  final int? apontada;

  const _FalhasPainter({required this.horas, required this.apontada});

  int _totalDa(PorHoraItem h) =>
      _tiposDeFalha.fold(0, (soma, t) => soma + t.valor(h.falhas));

  @override
  void paint(Canvas canvas, Size size) {
    final maximo = horas.map(_totalDa).fold(1, math.max);
    final passo = _passoDoEixo(maximo);
    final topo = (maximo / passo).ceil() * passo;

    final altura = size.height - _margemBaixo - _margemTopo;
    final base = _margemTopo + altura;
    final coluna = (size.width - margemEsquerda) / horas.length;
    final grade = Paint()
      ..color = const Color(0xFFEEF1F6)
      ..strokeWidth = 1;

    for (var v = 0; v <= topo; v += passo) {
      final y = base - altura * v / topo;
      canvas.drawLine(Offset(margemEsquerda, y), Offset(size.width, y), grade);
      _escrever(canvas, '$v', Offset(margemEsquerda - 6, y), alinharDireita: true);
    }

    for (var i = 0; i < horas.length; i++) {
      final centro = margemEsquerda + coluna * (i + 0.5);

      if (i == apontada) {
        canvas.drawRect(
          Rect.fromLTWH(centro - coluna / 2, _margemTopo, coluna, altura),
          Paint()..color = AppColors.primary.withValues(alpha: 0.08),
        );
      }

      // De 3 em 3 horas: as 24 não caberiam, legíveis, num celular.
      if (horas[i].hora % 3 == 0) {
        _escrever(canvas, '${horas[i].hora}h', Offset(centro, base + 12));
      }

      _desenharBarra(canvas, horas[i], centro, coluna, base, altura / topo);
    }
  }

  void _desenharBarra(
    Canvas canvas,
    PorHoraItem hora,
    double centro,
    double coluna,
    double base,
    double alturaPorFalha,
  ) {
    final largura = math.min(coluna * 0.72, 24.0);
    final presentes = [
      for (final tipo in _tiposDeFalha)
        if (tipo.valor(hora.falhas) > 0) tipo,
    ];
    var y = base;

    for (final tipo in presentes) {
      final eUltimo = identical(tipo, presentes.last);
      final cheia = tipo.valor(hora.falhas) * alturaPorFalha;
      // O vão sai do próprio pedaço: a altura total da barra continua fiel.
      final desenhada = eUltimo ? cheia : math.max(cheia - _vao, 1.0);
      final raio = Radius.circular(
        eUltimo ? math.min(4.0, math.min(largura / 2, desenhada)) : 0,
      );

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(centro - largura / 2, y - desenhada, largura, desenhada),
          topLeft: raio,
          topRight: raio,
        ),
        Paint()..color = tipo.cor,
      );
      y -= cheia;
    }
  }

  void _escrever(
    Canvas canvas,
    String texto,
    Offset posicao, {
    bool alinharDireita = false,
  }) {
    final pintor = TextPainter(
      text: TextSpan(
        text: texto,
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    pintor.paint(
      canvas,
      Offset(
        alinharDireita ? posicao.dx - pintor.width : posicao.dx - pintor.width / 2,
        posicao.dy - pintor.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_FalhasPainter old) =>
      old.horas != horas || old.apontada != apontada;
}

/// O que o gráfico desenha. Um null em [valores] é um buraco (dia sem dado),
/// não zero: a linha é interrompida e a barra não é desenhada.
class _SerieGrafico {
  final List<double?> valores;
  final List<String> rotulos;

  /// Só a quilometragem por hora usa; nos outros casos fica 0.
  final num kmImprodutivo;

  const _SerieGrafico({
    required this.valores,
    required this.rotulos,
    required this.kmImprodutivo,
  });
}

/// "78,5" e "479,6": uma casa decimal com vírgula, no padrão brasileiro.
final _umDecimal = NumberFormat('#,##0.0', 'pt_BR');

/// Com muitos pontos (24 horas, um mês) os rótulos se sobrepõem. Mostra no
/// máximo uns 8, espaçados por igual, sempre com o primeiro e o último. O
/// penúltimo visível precisa ficar a um passo inteiro do último para não colar.
bool _mostrarRotulo(int i, int total) {
  const maximo = 8;
  final passo = (total / maximo).ceil();
  if (i == 0 || i == total - 1) return true;
  return i % passo == 0 && total - 1 - i >= passo;
}

class _ChartMessage extends StatelessWidget {
  final String mensagem;

  const _ChartMessage(this.mensagem);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final _ChartType type;
  final List<double?> values;
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
    // Os desenhos abaixo precisam de ao menos um valor para achar mínimo e máximo.
    if (values.every((v) => v == null)) {
      return const _ChartMessage('Sem dados neste período');
    }

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
  final List<double?> values;
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
  final List<double?> values;
  final List<String> labels;
  final Color color;

  const _BarChart({
    required this.values,
    required this.labels,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.whereType<double>().fold(0.0, math.max);
    // Com 24 ou 31 barras o espaço de 7px de cada lado não cabe no celular.
    final gap = values.length > 12 ? 1.5 : 7.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 38),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final value = values[i];
              final mostrar = _mostrarRotulo(i, values.length);
              // maxValue 0 (tudo zero): barra de altura 0, sem dividir por zero.
              final height =
                  value == null || maxValue <= 0 ? 0.0 : 205 * (value / maxValue);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gap),
                  child: Column(
                    children: [
                      _rotulo(
                        mostrar && value != null
                            ? value.toStringAsFixed(0)
                            : '',
                        AppColors.textSecondary,
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          // Buraco: nenhuma barra, nem de altura zero.
                          child: value == null
                              ? null
                              : Container(
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
                      _rotulo(mostrar ? labels[i] : '', AppColors.textMuted),
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

  /// Altura fixa (as barras ficam alinhadas com ou sem rótulo) e largura livre:
  /// a coluna de uma barra estreita é menor que "01/07", então o texto pode
  /// passar por cima das vizinhas, que nesse ponto estão sem rótulo.
  Widget _rotulo(String texto, Color cor) {
    return SizedBox(
      height: 14,
      child: OverflowBox(
        maxWidth: 60,
        child: Text(
          texto,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: cor),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double?> values;
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

    // Mínimo e máximo só entre os dias com dado: um buraco não é zero.
    final presentes = values.whereType<double>();
    if (presentes.isEmpty) return;
    final maxValue = presentes.reduce(math.max);
    final minValue = presentes.reduce(math.min);
    // Pelo menos 1: com todos os valores iguais (ou todos zero) não divide por zero.
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
    // false logo depois de um buraco: o próximo ponto recomeça a linha (moveTo).
    var tracando = false;

    for (int i = 0; i < values.length; i++) {
      final x = chart.left +
          chart.width * i / math.max(1, values.length - 1);

      if (_mostrarRotulo(i, values.length)) {
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

      final value = values[i];
      if (value == null) {
        tracando = false;
        continue;
      }

      final normalized = (value - minValue) / range;
      final y = chart.bottom - normalized * chart.height;

      if (tracando) {
        path.lineTo(x, y);
      } else {
        path.moveTo(x, y);
      }
      tracando = true;

      final pointPaint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), 4.5, pointPaint);
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
  final String analysisTitle;
  final String analysisDescription;

  const _InvestigationConfig({
    required this.title,
    required this.description,
    required this.icon,
    required this.analysisTitle,
    required this.analysisDescription,
  });
}
