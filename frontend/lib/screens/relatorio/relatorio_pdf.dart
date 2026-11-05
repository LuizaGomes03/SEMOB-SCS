import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/feriados.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/periodo.dart';
import '../../models/cumprimento.dart';
import '../../models/indicadores.dart';
import '../../models/por_hora.dart';
import '../../models/por_linha.dart';
import '../../models/saldo.dart';
import '../../models/viagem_nao_cumprida.dart';

enum SecaoRelatorio {
  indicadores,
  operacaoPorLinha,
  cumprimentoEFalhas,
  financeiro,
  listaViagens,
}

/// Tudo o que o PDF mostra. É buscado uma vez pela tela e só lido aqui.
class DadosRelatorio {
  final Indicadores indicadores;
  final PorLinha porLinha;
  final Cumprimento cumprimento;
  final PorHora porHora;
  final Saldo saldo;
  final List<ViagemNaoCumprida> viagens;
  final pw.ImageProvider logo;

  const DadosRelatorio({
    required this.indicadores,
    required this.porLinha,
    required this.cumprimento,
    required this.porHora,
    required this.saldo,
    required this.viagens,
    required this.logo,
  });
}

// A fonte padrão só aceita códigos até 0xFF: um "—" digitado (U+2014) sai como uma
// caixinha com um X. Ela usa a codificação WinAnsi, em que o código 0x97 é o próprio
// travessão. Por isso este código, e não o caractere.
const _traco = '\u0097';

const _azul = PdfColor.fromInt(0xFF183B70);
const _cinza = PdfColor.fromInt(0xFF667085);
const _borda = PdfColor.fromInt(0xFFE1E6EF);

String _doisDigitos(int n) => n.toString().padLeft(2, '0');

// Datas à mão: Formatters.date precisa de initializeDateFormatting, que o app
// não chama.
String _diaMes(DateTime d) => '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}';
String _data(DateTime d) => '${_diaMes(d)}/${d.year}';
String _hora(DateTime? d) =>
    d == null ? _traco : '${_doisDigitos(d.hour)}:${_doisDigitos(d.minute)}';

String _cumprimento(int realizadas, int programadas) =>
    Formatters.cumprimento(realizadas, programadas, semValor: _traco);

/// Sinal explícito: numa variação, "+" diz tanto quanto o número.
String _variacaoEmReais(num? valor) {
  if (valor == null) return _traco;
  return '${valor > 0 ? '+' : ''}${Formatters.currency(valor)}';
}

/// Monta o PDF só com o que já foi buscado: nenhuma chamada de rede aqui.
Future<Uint8List> gerarRelatorioPdf({
  required PdfPageFormat formato,
  required DadosRelatorio dados,
  required Set<SecaoRelatorio> secoes,
  required PeriodoConsulta periodo,
  required DateTime ultimaData,
  required String titulo,
  required DateTime geradoEm,
}) {
  final pdf = pw.Document();
  final rodape = 'Gerado em ${_data(geradoEm)} ${_hora(geradoEm)} · '
      'Fonte: relatórios da SEMOB';
  final notas = [
    // Só faz sentido junto da tabela que tem a coluna "Km produtivo".
    if (secoes.contains(SecaoRelatorio.operacaoPorLinha)) avisoKmPorLinha,
    ..._notasDoPeriodo(periodo, ultimaData),
    ..._notasDeFeriados(
      periodo,
      // A comparação só aparece na seção de indicadores: sem ela, a nota ficaria
      // explicando um número que não está no relatório.
      secoes.contains(SecaoRelatorio.indicadores)
          ? dados.indicadores.comparacao
          : null,
    ),
  ];

  pdf.addPage(
    pw.MultiPage(
      pageFormat: formato,
      margin: const pw.EdgeInsets.all(32),
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(rodape, style: _textoPequeno),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: _textoPequeno,
            ),
          ],
        ),
      ),
      build: (context) => [
        _cabecalho(dados.logo, titulo, periodo, ultimaData),
        if (secoes.contains(SecaoRelatorio.indicadores))
          _inteira(_secaoIndicadores(dados)),
        if (secoes.contains(SecaoRelatorio.operacaoPorLinha))
          _inteira(_secaoOperacao(dados.porLinha)),
        if (secoes.contains(SecaoRelatorio.cumprimentoEFalhas)) ...[
          _inteira(_secaoTurnos(dados.cumprimento)),
          _inteira(_secaoFalhas(dados.porHora)),
        ],
        if (secoes.contains(SecaoRelatorio.financeiro))
          _inteira(_secaoFinanceiro(dados)),
        // A lista é a única que fica solta: é ela que precisa quebrar entre páginas.
        if (secoes.contains(SecaoRelatorio.listaViagens))
          ..._secaoViagens(dados.viagens),
        if (notas.isNotEmpty) _inteira(_secaoNotas(notas)),
      ],
    ),
  );

  return pdf.save();
}

/// Só as notas que valem para o período pedido.
List<String> _notasDoPeriodo(PeriodoConsulta periodo, DateTime ultimaData) {
  final semFinanceiro = [
    for (final dia in const [3, 4, 5, 11, 12]) DateTime(2026, 7, dia),
  ];
  final hoje = DateTime(ultimaData.year, ultimaData.month, ultimaData.day);

  return [
    if (periodo.inicio.isBefore(DateTime(2026, 7, 15)))
      'Dados de passageiros e de utilização de créditos só existem a partir de '
          '15/07/2026.',
    if (semFinanceiro.any(
      (d) => !d.isBefore(periodo.inicio) && !d.isAfter(periodo.fim),
    ))
      'Não há dados financeiros de 03, 04, 05, 11 e 12/07/2026.',
    if (periodo.fim.isAfter(hoje)) 'Os dados vão até ${_data(hoje)}.',
  ];
}

List<String> _notasDeFeriados(
  PeriodoConsulta periodo,
  ComparacaoIndicadores? comparacao,
) {
  final noPeriodo = feriadosNoPeriodo(periodo.inicio, periodo.fim);

  // Sem nenhuma variação, a tabela mostra só o traço: não há o que explicar.
  final temVariacao =
      comparacao?.variacaoPercentual.values.any((v) => v != null) ?? false;
  final naComparacao = temVariacao
      ? feriadosNoPeriodo(comparacao!.dataInicio, comparacao.dataFim)
      : const <Feriado>[];

  return [
    if (noPeriodo.isNotEmpty)
      'O período inclui feriado(s): ${formatarFeriados(noPeriodo)}. '
          'A operação nesses dias costuma ser menor.',
    if (naComparacao.isNotEmpty)
      'O período de comparação inclui feriado(s): '
          '${formatarFeriados(naComparacao)}.',
  ];
}

const _textoPequeno = pw.TextStyle(fontSize: 8, color: _cinza);
const _frase = pw.TextStyle(fontSize: 9, color: _cinza);

pw.Widget _cabecalho(
  pw.ImageProvider logo,
  String titulo,
  PeriodoConsulta periodo,
  DateTime ultimaData,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 12),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _azul, width: 1.5)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Image(logo, height: 44),
        pw.SizedBox(width: 14),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SEMOB-SCS',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: _cinza,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                titulo,
                style: pw.TextStyle(
                  fontSize: 18,
                  color: _azul,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Período: ${rotuloPeriodo(periodo.inicio, periodo.fim)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              // Com o ano, ao contrário do selo do dashboard: um PDF pode ser
              // lido muito depois, fora do contexto do app.
              pw.Text(
                'Dados de referência: ${_data(ultimaData)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Título e tabela numa peça só: se não couberem no resto da página, vão juntos
/// para a próxima, em vez de o "Total" ficar sozinho lá.
pw.Widget _inteira(List<pw.Widget> filhos) {
  return pw.Inseparable(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: filhos,
    ),
  );
}

pw.Widget _tituloSecao(String texto) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18, bottom: 7),
    child: pw.Text(
      texto,
      style: pw.TextStyle(
        fontSize: 13,
        color: _azul,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

pw.Widget _textoDe(String texto) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Text(texto, style: _frase),
    );

/// pw.Table sabe se dividir entre páginas dentro de um MultiPage, repetindo o
/// cabeçalho. colunasNumericas ficam alinhadas à direita.
pw.Widget _tabela({
  required List<String> titulos,
  required List<List<String>> linhas,
  required List<double> larguras,
  Set<int> colunasNumericas = const {},
  double fonte = 9,
}) {
  final alinhamentos = {
    for (var i = 0; i < titulos.length; i++)
      i: colunasNumericas.contains(i)
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
  };

  return pw.TableHelper.fromTextArray(
    headers: titulos,
    data: linhas,
    columnWidths: {
      for (var i = 0; i < larguras.length; i++)
        i: pw.FlexColumnWidth(larguras[i]),
    },
    cellAlignments: alinhamentos,
    headerAlignments: alinhamentos,
    cellStyle: pw.TextStyle(fontSize: fonte),
    headerStyle: pw.TextStyle(
      fontSize: fonte,
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
    ),
    headerDecoration: const pw.BoxDecoration(color: _azul),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    border: const pw.TableBorder(
      bottom: pw.BorderSide(color: _borda),
      horizontalInside: pw.BorderSide(color: _borda),
    ),
  );
}

// ---------------------------------------------------------------------------
// Indicadores principais
// ---------------------------------------------------------------------------

List<pw.Widget> _secaoIndicadores(DadosRelatorio dados) {
  final i = dados.indicadores;
  final total = dados.cumprimento.total;
  final variacoes = i.comparacao?.variacaoPercentual ?? const <String, double?>{};

  List<String> linha(String nome, String valor, String chave, int dias) {
    if (dias == 0) return [nome, 'Sem dados no período', _traco];
    return [nome, valor, _textoVariacao(variacoes[chave], i.comparacao)];
  }

  return [
    _tituloSecao('Indicadores principais'),
    _tabela(
      titulos: const ['Indicador', 'Valor', 'Variação'],
      larguras: const [3, 3, 3],
      linhas: [
        linha(
          'Quilometragem',
          '${Formatters.number(i.quilometragem)} km',
          'quilometragem',
          i.diasOperacao,
        ),
        linha(
          'Viagens',
          '${Formatters.number(i.viagens)} de '
              '${Formatters.number(i.viagensProgramadas)} programadas',
          'viagens',
          i.diasOperacao,
        ),
        linha(
          'Passageiros pagantes',
          Formatters.number(i.passageirosPagantes),
          'passageirosPagantes',
          i.diasPassageiros,
        ),
        linha(
          'Gratuidades',
          Formatters.number(i.passageirosNaoPagantes),
          'passageirosNaoPagantes',
          i.diasPassageiros,
        ),
        linha(
          'Créditos vendidos',
          Formatters.currency(i.creditosVendidos),
          'creditosVendidos',
          i.diasFinanceiro,
        ),
        linha(
          'Créditos utilizados',
          Formatters.currency(i.creditosUtilizados),
          'creditosUtilizados',
          i.diasFinanceiro,
        ),
      ],
    ),
    _textoDe(
      '${Formatters.number(total.realizadas)} de '
      '${Formatters.number(total.programadas)} viagens programadas realizadas '
      '(${_cumprimento(total.realizadas, total.programadas)})',
    ),
  ];
}

String _textoVariacao(double? variacao, ComparacaoIndicadores? comparacao) {
  if (variacao == null || comparacao == null) return _traco;

  final inicio = comparacao.dataInicio;
  final fim = comparacao.dataFim;
  final rotulo =
      inicio == fim ? _diaMes(inicio) : '${_diaMes(inicio)} a ${_diaMes(fim)}';

  return '${Formatters.percentage(variacao)} vs. $rotulo';
}

// ---------------------------------------------------------------------------
// Operação por linha
// ---------------------------------------------------------------------------

// Larguras das colunas: Linha, Viagens, Programadas, Não cumpridas, Cumprimento, Km.
const _largurasOperacao = [2, 2, 2, 2, 2, 2];

List<pw.Widget> _secaoOperacao(PorLinha dados) {
  return [
    _tituloSecao('Operação por linha'),
    _linhaOperacao(
      const [
        'Linha',
        'Viagens',
        'Programadas',
        'Não cumpridas',
        'Cumprimento',
        'Km produtivo',
      ],
      cabecalho: true,
    ),
    for (final l in dados.linhas)
      if (l.programadas == 0)
        _linhaSemOperacao('Linha ${l.linha}')
      else
        _linhaOperacao([
          'Linha ${l.linha}',
          Formatters.number(l.viagens),
          Formatters.number(l.programadas),
          Formatters.number(l.naoCumpridas),
          _cumprimento(l.viagens, l.programadas),
          Formatters.number(l.quilometragem),
        ]),
    _linhaOperacao([
      'Total',
      Formatters.number(dados.totais.viagens),
      Formatters.number(dados.totais.programadas),
      Formatters.number(dados.totais.naoCumpridas),
      _cumprimento(dados.totais.viagens, dados.totais.programadas),
      Formatters.number(dados.totais.quilometragem),
    ], negrito: true),
  ];
}

// Linhas feitas com pw.Row, e não pw.Table: uma tabela não tem como fazer uma
// célula ocupar várias colunas, e "Não rodou no período" precisa disso.
pw.Widget _caixaDaLinha(pw.Widget filho, {bool cabecalho = false}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    decoration: pw.BoxDecoration(
      color: cabecalho ? _azul : null,
      border: const pw.Border(bottom: pw.BorderSide(color: _borda)),
    ),
    child: filho,
  );
}

pw.Widget _linhaOperacao(
  List<String> celulas, {
  bool cabecalho = false,
  bool negrito = false,
}) {
  final estilo = pw.TextStyle(
    fontSize: 9,
    color: cabecalho ? PdfColors.white : null,
    fontWeight: cabecalho || negrito ? pw.FontWeight.bold : null,
  );

  return _caixaDaLinha(
    pw.Row(
      children: [
        for (var i = 0; i < celulas.length; i++)
          pw.Expanded(
            flex: _largurasOperacao[i],
            child: pw.Text(
              celulas[i],
              style: estilo,
              textAlign: i == 0 ? pw.TextAlign.left : pw.TextAlign.right,
            ),
          ),
      ],
    ),
    cabecalho: cabecalho,
  );
}

pw.Widget _linhaSemOperacao(String rotulo) {
  return _caixaDaLinha(
    pw.Row(
      children: [
        pw.Expanded(
          flex: _largurasOperacao.first,
          child: pw.Text(rotulo, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Expanded(
          flex: _largurasOperacao.skip(1).reduce((a, b) => a + b),
          child: pw.Text(
            'Não rodou no período',
            style: const pw.TextStyle(fontSize: 9, color: _cinza),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Cumprimento e falhas
// ---------------------------------------------------------------------------

List<pw.Widget> _secaoTurnos(Cumprimento c) {
  List<String> turno(String nome, CumprimentoTurno t) => [
        nome,
        Formatters.number(t.programadas),
        Formatters.number(t.realizadas),
        _cumprimento(t.realizadas, t.programadas),
      ];

  return [
    _tituloSecao('Cumprimento e falhas'),
    _tabela(
      titulos: const ['Turno', 'Programadas', 'Realizadas', '%'],
      larguras: const [3, 2, 2, 2],
      colunasNumericas: const {1, 2, 3},
      linhas: [
        turno('Manhã', c.manha),
        turno('Tarde', c.tarde),
        turno('Noite', c.noite),
        turno('Total', c.total),
      ],
    ),
    _textoDe(
      'Divisão de turnos dos relatórios da SEMOB; os horários de cada turno '
      'não foram informados.',
    ),
  ];
}

List<pw.Widget> _secaoFalhas(PorHora porHora) {
  // Soma as 24 horas: a rota traz as falhas separadas por hora programada.
  int somaFalhas(int Function(FalhasPorHora) tipo) =>
      porHora.horas.fold(0, (soma, h) => soma + tipo(h.falhas));

  final naoRealizadas = somaFalhas((f) => f.naoRealizada);
  final naoIniciadas = somaFalhas((f) => f.naoIniciada);
  final naoTerminadas = somaFalhas((f) => f.naoTerminada);

  return [
    pw.SizedBox(height: 10),
    _tabela(
      titulos: const ['Falhas no período', 'Quantidade'],
      larguras: const [3, 2],
      colunasNumericas: const {1},
      linhas: [
        ['Não realizadas', Formatters.number(naoRealizadas)],
        ['Não iniciadas', Formatters.number(naoIniciadas)],
        ['Não terminadas', Formatters.number(naoTerminadas)],
        ['Total', Formatters.number(naoRealizadas + naoIniciadas + naoTerminadas)],
      ],
    ),
  ];
}

// ---------------------------------------------------------------------------
// Financeiro
// ---------------------------------------------------------------------------

List<pw.Widget> _secaoFinanceiro(DadosRelatorio dados) {
  final i = dados.indicadores;
  final saldo = dados.saldo;
  final saldoFinal = saldo.saldoFinal;
  final dataSaldo = saldo.dataSaldoFinal;

  String credito(num valor) => i.diasFinanceiro == 0
      ? 'Sem dados no período'
      : Formatters.currency(valor);

  return [
    _tituloSecao('Financeiro'),
    _tabela(
      titulos: const ['Item', 'Valor'],
      larguras: const [3, 3],
      linhas: [
        ['Créditos vendidos', credito(i.creditosVendidos)],
        ['Créditos utilizados', credito(i.creditosUtilizados)],
        [
          'Saldo no fim do período',
          saldoFinal == null || dataSaldo == null
              ? _traco
              : '${Formatters.currency(saldoFinal)} em ${_data(dataSaldo)}',
        ],
        ['Variação do saldo no período', _variacaoEmReais(saldo.variacao)],
      ],
    ),
    _textoDe(
      'Valores em reais. Venda e utilização não coincidem: o passageiro carrega '
      'o cartão antes de usar.',
    ),
  ];
}

// ---------------------------------------------------------------------------
// Lista de viagens não cumpridas
// ---------------------------------------------------------------------------

List<pw.Widget> _secaoViagens(List<ViagemNaoCumprida> viagens) {
  return [
    _tituloSecao('Lista de viagens não cumpridas'),
    if (viagens.isEmpty)
      pw.Text(
        'Todas as viagens programadas do período foram realizadas.',
        style: const pw.TextStyle(fontSize: 10),
      )
    else ...[
      _tabela(
        fonte: 8,
        titulos: const [
          'Data',
          'Linha',
          'Tabela',
          'Sentido',
          'Programado',
          'Tipo',
          'Motorista',
          'Veículo',
        ],
        larguras: const [5, 3, 3, 3.5, 6, 6, 4, 3.5],
        linhas: [
          for (final v in viagens)
            [
              _data(v.data),
              v.linha,
              v.tabela,
              rotuloSentido(v.sentido),
              // Hífen: a fonte padrão não tem seta nem traço meio.
              '${_hora(v.inicioProgramado)} - ${_hora(v.fimProgramado)}',
              v.tipoRotulo,
              v.motorista,
              v.prefixo ?? _traco,
            ],
        ],
      ),
      _textoDe('O motivo de cada falha não é informado nos relatórios da SEMOB.'),
    ],
  ];
}

List<pw.Widget> _secaoNotas(List<String> notas) {
  return [
    _tituloSecao('Notas sobre os dados'),
    for (final nota in notas)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Text(nota, style: _frase),
      ),
  ];
}
