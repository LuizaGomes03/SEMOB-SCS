import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/periodo.dart';
import '../../models/indicadores.dart';
import '../../services/operacao_api.dart';
import '../../widgets/common/erro_carregamento.dart';
import '../detalhes/detalhes_screen.dart';

// Cores de estado. Ficam aqui até existirem em AppColors.
const _kAlerta = Color(0xFFB3261E);
const _kAlertaBorda = Color(0xFFE5484D);
const _kAlertaFundo = Color(0xFFFDECEC);
const _kAlertaCard = Color(0xFFFFFBFB);
const _kPositivo = Color(0xFF1E7B34);
const _kNegativo = Color(0xFFC62828);

class DashboardScreen extends StatefulWidget {
  final OperacaoApi api;
  final PeriodoConsulta periodo;
  final int versaoDados;
  final bool isRefreshing;
  final ValueChanged<InvestigationType> onOpenInvestigation;
  final Function(dynamic) onSelectAlert;

  const DashboardScreen({
    super.key,
    required this.api,
    required this.periodo,
    required this.versaoDados,
    required this.isRefreshing,
    required this.onOpenInvestigation,
    required this.onSelectAlert,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Indicadores> _indicadores;

  /// Limite de variação (em %, valor absoluto) a partir do qual o indicador
  /// é tratado como anomalia. Provisório: o ideal é a API devolver a regra
  /// (ou a faixa esperada) e este mapa deixar de existir.
  static const Map<InvestigationType, double> _limiaresAnomalia = {
    InvestigationType.quilometragem: 3.0,
    InvestigationType.viagens: 3.0,
    InvestigationType.pagantes: 5.0,
    InvestigationType.gratuidades: 8.0,
    InvestigationType.financeiro: 5.0,
  };

  /// Abaixo desta altura o card fica apertado demais; aí a tela volta a rolar
  /// (só acontece no celular ou em janelas muito baixas).
  static const double _alturaMinimaCard = 170;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.periodo != widget.periodo ||
        oldWidget.versaoDados != widget.versaoDados) {
      _buscar();
    }
  }

  void _buscar() {
    _indicadores = widget.api.indicadores(
      dataInicio: widget.periodo.inicio,
      dataFim: widget.periodo.fim,
      comparacao: widget.periodo.comparacao,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Indicadores>(
      future: _indicadores,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErroCarregamento(
            mensagem: snapshot.error.toString(),
            onTentarNovamente: () => setState(_buscar),
          );
        }
        return _buildConteudo(snapshot.data!);
      },
    );
  }

  // ================================================================
  // REGRA DE ANOMALIA
  // ================================================================

  _DashboardKpi _kpi({
    required String title,
    required String valor,
    required String detalhe,
    String? unidade,
    required double? variacao,
    required bool semDados,
    required IconData icon,
    required InvestigationType type,
    bool maiorMelhor = true,
    List<double>? serie,
  }) {
    final limiar = _limiaresAnomalia[type];
    final isAnomaly = !semDados &&
        variacao != null &&
        limiar != null &&
        variacao.abs() >= limiar;

    String? mensagem;
    if (isAnomaly) {
      final sentido = variacao < 0 ? 'Queda' : 'Alta';
      mensagem = '$sentido fora do esperado (limite ±${_pct(limiar)})';
    }

    return _DashboardKpi(
      title: title,
      valor: valor,
      detalhe: detalhe,
      unidade: unidade,
      variacao: variacao,
      semDados: semDados,
      icon: icon,
      type: type,
      maiorMelhor: maiorMelhor,
      serie: serie,
      isAnomaly: isAnomaly,
      anomalyMessage: mensagem,
    );
  }

  String _pct(double v) => '${v.toStringAsFixed(1).replaceAll('.', ',')}%';

  // ================================================================
  // CONTEÚDO
  // ================================================================

  Widget _buildConteudo(Indicadores dados) {
    final variacao =
        dados.comparacao?.variacaoPercentual ?? const <String, double?>{};

    final cards = [
      _kpi(
        title: 'Quilometragem',
        valor: Formatters.number(dados.quilometragem),
        unidade: 'km',
        detalhe: 'rodados no período',
        variacao: variacao['quilometragem'],
        semDados: dados.diasOperacao == 0,
        icon: Icons.route,
        type: InvestigationType.quilometragem,
      ),
      _kpi(
        title: 'Viagens',
        valor: Formatters.number(dados.viagens),
        detalhe:
            'de ${Formatters.number(dados.viagensProgramadas)} programadas',
        variacao: variacao['viagens'],
        semDados: dados.diasOperacao == 0,
        icon: Icons.directions_bus,
        type: InvestigationType.viagens,
      ),
      _kpi(
        title: 'Passageiros Pagantes',
        valor: Formatters.number(dados.passageirosPagantes),
        detalhe: 'passageiros',
        variacao: variacao['passageirosPagantes'],
        semDados: dados.diasPassageiros == 0,
        icon: Icons.people,
        type: InvestigationType.pagantes,
      ),
      _kpi(
        title: 'Gratuidades',
        valor: Formatters.number(dados.passageirosNaoPagantes),
        detalhe: 'passageiros não pagantes',
        variacao: variacao['passageirosNaoPagantes'],
        semDados: dados.diasPassageiros == 0,
        icon: Icons.card_membership,
        type: InvestigationType.gratuidades,
        // Aumento de gratuidades não é "bom": a seta de alta fica vermelha.
        maiorMelhor: false,
      ),
      _kpi(
        title: 'Financeiro',
        valor: Formatters.currency(dados.creditosVendidos),
        detalhe:
            'em créditos vendidos · ${Formatters.currency(dados.creditosUtilizados)} utilizados',
        variacao: variacao['creditosVendidos'],
        semDados: dados.diasFinanceiro == 0,
        icon: Icons.attach_money,
        type: InvestigationType.financeiro,
      ),
    ];

    final rotuloComparacao = _rotuloComparacao(dados.comparacao);

    return LayoutBuilder(
      builder: (context, viewport) {
        final width = viewport.maxWidth;
        final horizontalPadding = width < 600
            ? 14.0
            : width < 1000
                ? 22.0
                : 28.0;
        final verticalPadding = width < 600 ? 12.0 : 16.0;

        // Desktop/TV: 3 colunas; telas médias: 2; celular: 1.
        final columns = width < 520
            ? 1
            : width >= 1200
                ? 3
                : 2;
        final rows = (cards.length / columns).ceil();
        final spacing = width < 600 ? 12.0 : 16.0;

        // Sem título nem "Período" aqui: a data já aparece no selo
        // "Dados de referência" do topo, e o espaço vai todo para os cards.

        final dica = Padding(
          padding: EdgeInsets.only(top: spacing),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app_outlined,
                    color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selecione um indicador para abrir a investigação detalhada.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        Widget grade(double cardWidth, double cardHeight) => Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: cards.map((card) {
                return SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _buildKpiCard(
                    card,
                    rotuloComparacao,
                    altura: cardHeight,
                    largura: cardWidth,
                  ),
                );
              }).toList(),
            );

        final larguraUtil = width - horizontalPadding * 2;
        final cardWidth =
            (larguraUtil - ((columns - 1) * spacing)) / columns;

        // Modo "tela única": os cards dividem a altura disponível, sem rolagem.
        // Estimativa da altura da dica para saber se cabe antes de montar.
        final alturaFixa = 16 + 44;
        final alturaGrade = viewport.maxHeight -
            verticalPadding * 2 -
            alturaFixa;
        final alturaCardTelaUnica =
            (alturaGrade - (rows - 1) * spacing) / rows;
        final cabeNaTela = viewport.hasBoundedHeight &&
            columns > 1 &&
            alturaCardTelaUnica >= _alturaMinimaCard;

        if (cabeNaTela) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, area) {
                      final h =
                          (area.maxHeight - (rows - 1) * spacing) / rows;
                      return grade(cardWidth, h);
                    },
                  ),
                ),
                dica,
              ],
            ),
          );
        }

        // Fallback (celular / janela baixa): rolagem com altura fixa.
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [grade(cardWidth, 210), dica],
          ),
        );
      },
    );
  }

  // ================================================================
  // CARD
  // ================================================================

  Widget _buildKpiCard(
    _DashboardKpi item,
    String rotuloComparacao, {
    required double altura,
    required double largura,
  }) {
    final anomalia = item.isAnomaly;
    final variacao = item.semDados ? null : item.variacao;
    final serie = item.semDados ? null : item.serie;

    // Tamanhos crescem com o card, para aproveitar a tela inteira.
    final cardPadding = (altura * 0.08).clamp(14.0, 24.0);
    final titleSize = (altura * 0.065).clamp(13.0, 20.0);
    final valueSize = (altura * 0.2).clamp(30.0, 64.0);
    final detailSize = (altura * 0.06).clamp(13.0, 19.0);
    final variationSize = (altura * 0.12).clamp(18.0, 40.0);
    final comparacaoSize = (variationSize * 0.55).clamp(13.0, 22.0);

    // No card em anomalia, a variação usa a cor do alerta (o card inteiro
    // já diz "fora do esperado"). Verde/vermelho por direção só no card normal.
    final corVariacao = variacao == null
        ? AppColors.textMuted
        : anomalia
            ? _kAlerta
            : _corVariacao(variacao, item.maiorMelhor);

    return Semantics(
      button: true,
      label: anomalia
          ? '${item.title}: anomalia. ${item.anomalyMessage ?? ''}'
          : item.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isRefreshing
              ? null
              : () => widget.onOpenInvestigation(item.type),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: anomalia ? _kAlertaCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: anomalia
                    ? _kAlertaBorda
                    : AppColors.primary.withValues(alpha: 0.15),
                width: anomalia ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (anomalia ? _kAlerta : Colors.black)
                      .withValues(alpha: anomalia ? 0.08 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho: ícone e título discretos; selo de estado à direita.
                Row(
                  children: [
                    Icon(
                      item.icon,
                      size: titleSize + 4,
                      color: anomalia ? _kAlerta : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: titleSize,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (anomalia) _SeloAnomalia(fontSize: titleSize * 0.8),
                  ],
                ),
                SizedBox(height: altura * 0.04),

                // Valor principal + unidade. scaleDown evita cortar números longos.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        item.semDados ? '—' : item.valor,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: valueSize,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: anomalia ? _kAlerta : AppColors.textPrimary,
                        ),
                      ),
                      if (item.unidade != null && !item.semDados) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.unidade!,
                          style: TextStyle(
                            fontSize: valueSize * 0.4,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Contexto: na anomalia, diz o que está fora do normal.
                Text(
                  item.semDados
                      ? 'Sem dados neste período'
                      : anomalia && item.anomalyMessage != null
                          ? item.anomalyMessage!
                          : item.detalhe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: detailSize,
                    height: 1.25,
                    color: anomalia
                        ? const Color(0xFF8E2424)
                        : AppColors.textSecondary,
                    fontWeight: anomalia ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const Spacer(),

                // Minigráfico opcional (precisa de série diária vinda da API).
                if (serie != null && serie.length > 1) ...[
                  SizedBox(
                    height: (altura * 0.14).clamp(28.0, 56.0),
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _SparklinePainter(
                        valores: serie,
                        destacarUltimo: anomalia,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Rodapé: variação em destaque vs. período de comparação.
                if (variacao != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          variacao > 0
                              ? Icons.trending_up
                              : variacao < 0
                                  ? Icons.trending_down
                                  : Icons.trending_flat,
                          size: variationSize * 1.1,
                          color: corVariacao,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          Formatters.percentage(variacao),
                          style: TextStyle(
                            color: corVariacao,
                            fontSize: variationSize,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          rotuloComparacao,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: comparacaoSize,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Verde quando a variação vai na direção boa do indicador, vermelho na ruim.
  Color _corVariacao(double v, bool maiorMelhor) {
    if (v == 0) return AppColors.textMuted;
    final melhorou = maiorMelhor ? v > 0 : v < 0;
    return melhorou ? _kPositivo : _kNegativo;
  }

  // ================================================================
  // RÓTULOS
  // ================================================================

  String _diaMes(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _rotuloComparacao(ComparacaoIndicadores? c) {
    if (c == null) return '';
    return c.dataInicio == c.dataFim
        ? 'vs. ${_diaMes(c.dataInicio)}'
        : 'vs. ${_diaMes(c.dataInicio)} – ${_diaMes(c.dataFim)}';
  }
}

// ==================================================================
// COMPONENTES DO CARD
// ==================================================================

class _SeloAnomalia extends StatelessWidget {
  final double fontSize;

  const _SeloAnomalia({this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.7,
        vertical: fontSize * 0.35,
      ),
      decoration: BoxDecoration(
        color: _kAlertaFundo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kAlertaBorda.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: fontSize + 2, color: _kAlerta),
          const SizedBox(width: 4),
          Text(
            'Anomalia',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: _kAlerta,
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> valores;
  final bool destacarUltimo;

  _SparklinePainter({required this.valores, required this.destacarUltimo});

  @override
  void paint(Canvas canvas, Size size) {
    var minV = valores.first;
    var maxV = valores.first;
    for (final v in valores) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final amplitude = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    const margem = 4.0;
    final altura = size.height - margem * 2;
    final passo = size.width / (valores.length - 1);

    Offset ponto(int i) => Offset(
          i * passo,
          margem + altura - ((valores[i] - minV) / amplitude) * altura,
        );

    final path = Path()..moveTo(ponto(0).dx, ponto(0).dy);
    for (var i = 1; i < valores.length; i++) {
      final p = ponto(i);
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.textMuted
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(
      ponto(valores.length - 1),
      4,
      Paint()..color = destacarUltimo ? _kAlertaBorda : AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.valores != valores || old.destacarUltimo != destacarUltimo;
}

// ==================================================================
// MODELO INTERNO DO CARD
// ==================================================================

class _DashboardKpi {
  final String title;
  final String valor;
  final String detalhe;
  final String? unidade;
  final double? variacao;
  final bool semDados;
  final IconData icon;
  final InvestigationType type;

  /// false quando aumentar é ruim (ex.: gratuidades). Afeta só a cor da seta.
  final bool maiorMelhor;

  /// Série diária do período para o minigráfico. Opcional.
  final List<double>? serie;

  final bool isAnomaly;
  final String? anomalyMessage;

  const _DashboardKpi({
    required this.title,
    required this.valor,
    required this.detalhe,
    this.unidade,
    required this.variacao,
    required this.semDados,
    required this.icon,
    required this.type,
    this.maiorMelhor = true,
    this.serie,
    this.isAnomaly = false,
    this.anomalyMessage,
  });
}