import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/dia.dart';
import '../../core/utils/periodo.dart';
import '../../models/viagem_nao_cumprida.dart';
import '../../services/operacao_api.dart';
import '../../widgets/common/erro_carregamento.dart';
import 'relatorio_pdf.dart';

enum ReportType { resumo, operacional, detalhado }

class RelatorioScreen extends StatefulWidget {
  final OperacaoApi api;
  final PeriodoConsulta periodo;
  final DateTime ultimaData;
  final String dataReferenceLabel;

  const RelatorioScreen({
    super.key,
    required this.api,
    required this.periodo,
    required this.ultimaData,
    required this.dataReferenceLabel,
  });

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  /// O que cada tipo marca ao ser escolhido. Depois o usuário pode ajustar.
  static const _secoesDoTipo = {
    ReportType.resumo: {SecaoRelatorio.indicadores},
    ReportType.operacional: {
      SecaoRelatorio.indicadores,
      SecaoRelatorio.operacaoPorLinha,
      SecaoRelatorio.cumprimentoEFalhas,
    },
    ReportType.detalhado: {
      SecaoRelatorio.indicadores,
      SecaoRelatorio.operacaoPorLinha,
      SecaoRelatorio.cumprimentoEFalhas,
      SecaoRelatorio.financeiro,
      SecaoRelatorio.listaViagens,
    },
  };

  static const _nomesDasSecoes = {
    SecaoRelatorio.indicadores: 'Indicadores principais',
    SecaoRelatorio.operacaoPorLinha: 'Operação por linha',
    SecaoRelatorio.cumprimentoEFalhas: 'Cumprimento e falhas',
    SecaoRelatorio.financeiro: 'Financeiro',
    SecaoRelatorio.listaViagens: 'Lista de viagens não cumpridas',
  };

  ReportType _reportType = ReportType.resumo;
  Set<SecaoRelatorio> _secoes = {..._secoesDoTipo[ReportType.resumo]!};

  DadosRelatorio? _dados;
  String? _erro;

  /// Fora de _dados: o logo não muda, e tentar de novo não o carrega outra vez.
  pw.ImageProvider? _logo;

  /// Identifica a busca mais recente. Uma resposta com número menor é velha.
  int _buscaAtual = 0;

  String get _reportTitle {
    switch (_reportType) {
      case ReportType.resumo:
        return 'Resumo Executivo';
      case ReportType.operacional:
        return 'Relatório Operacional';
      case ReportType.detalhado:
        return 'Relatório Detalhado';
    }
  }

  String get _nomeDoArquivo => 'relatorio_semob_scs_'
      '${formatarDia(widget.periodo.inicio)}_a_'
      '${formatarDia(widget.periodo.fim)}.pdf';

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  Future<void> _buscar() async {
    final busca = ++_buscaAtual;
    final periodo = widget.periodo;
    final api = widget.api;

    try {
      // Cada Future já começa a rodar aqui, ao ser criado: é isso que faz as
      // chamadas irem em paralelo. Guardar cada um numa variável mantém o tipo,
      // que a lista do Future.wait perderia.
      final indicadores = api.indicadores(
        dataInicio: periodo.inicio,
        dataFim: periodo.fim,
        comparacao: periodo.comparacao,
      );
      final porLinha =
          api.porLinha(dataInicio: periodo.inicio, dataFim: periodo.fim);
      final cumprimento =
          api.cumprimento(dataInicio: periodo.inicio, dataFim: periodo.fim);
      final porHora =
          api.porHora(dataInicio: periodo.inicio, dataFim: periodo.fim);
      final saldo = api.saldo(dataInicio: periodo.inicio, dataFim: periodo.fim);
      final viagens = _buscarTodasAsViagens();
      final logo = _carregarLogo();

      await Future.wait<Object?>([
        indicadores,
        porLinha,
        cumprimento,
        porHora,
        saldo,
        viagens,
        logo,
      ]);

      final dados = DadosRelatorio(
        indicadores: await indicadores,
        porLinha: await porLinha,
        cumprimento: await cumprimento,
        porHora: await porHora,
        saldo: await saldo,
        viagens: await viagens,
        logo: await logo,
      );
      if (!mounted || busca != _buscaAtual) return;

      setState(() => _dados = dados);
    } catch (e) {
      if (!mounted || busca != _buscaAtual) return;

      setState(() => _erro = e.toString());
    }
  }

  void _tentarDeNovo() {
    setState(() => _erro = null);
    _buscar();
  }

  /// A rota limita cada página a 100: pede a próxima até chegar ao total.
  Future<List<ViagemNaoCumprida>> _buscarTodasAsViagens() async {
    final itens = <ViagemNaoCumprida>[];
    var pagina = 1;

    while (true) {
      final resposta = await widget.api.viagensNaoCumpridas(
        dataInicio: widget.periodo.inicio,
        dataFim: widget.periodo.fim,
        pagina: pagina,
        limite: 100,
      );
      itens.addAll(resposta.itens);

      // Página vazia também encerra: sem isso, um total que mudou no meio da
      // busca faria o laço pedir páginas para sempre.
      if (resposta.itens.isEmpty || itens.length >= resposta.total) return itens;
      pagina++;
    }
  }

  Future<pw.ImageProvider> _carregarLogo() async {
    final jaCarregado = _logo;
    if (jaCarregado != null) return jaCarregado;

    final bytes = await rootBundle.load('assets/images/logo_semob_scs.png');
    return _logo = pw.MemoryImage(bytes.buffer.asUint8List());
  }

  // Só lê o que já foi buscado, sem nenhuma chamada de rede: o PdfPreview chama
  // este método de novo a cada redesenho, e buscar aqui faria as chamadas se
  // repetirem a cada clique numa caixa.
  Future<Uint8List> _buildPdf(PdfPageFormat format) {
    return gerarRelatorioPdf(
      formato: format,
      dados: _dados!,
      secoes: _secoes,
      periodo: widget.periodo,
      ultimaData: widget.ultimaData,
      titulo: _reportTitle,
      geradoEm: DateTime.now(),
    );
  }

  Future<void> _generatePdf() async {
    await Printing.layoutPdf(
      onLayout: _buildPdf,
      name: _nomeDoArquivo,
    );
  }

  void _escolherTipo(ReportType? tipo) {
    if (tipo == null) return;

    setState(() {
      _reportType = tipo;
      _secoes = {..._secoesDoTipo[tipo]!};
    });
  }

  void _alternarSecao(SecaoRelatorio secao, bool marcada) {
    setState(() {
      // Conjunto novo em vez de alterar o atual: o PDF que estiver sendo gerado
      // continua lendo o que tinha quando começou.
      _secoes = marcada ? {..._secoes, secao} : ({..._secoes}..remove(secao));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerar relatório')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relatório SEMOB-SCS',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Período: '
                  '${rotuloPeriodo(widget.periodo.inicio, widget.periodo.fim)}',
                ),
                Text(widget.dataReferenceLabel),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo de relatório',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RadioGroup<ReportType>(
                          groupValue: _reportType,
                          onChanged: _escolherTipo,
                          child: const Column(
                            children: [
                              RadioListTile<ReportType>(
                                value: ReportType.resumo,
                                title: Text('Resumo executivo'),
                              ),
                              RadioListTile<ReportType>(
                                value: ReportType.operacional,
                                title: Text('Relatório operacional'),
                              ),
                              RadioListTile<ReportType>(
                                value: ReportType.detalhado,
                                title: Text('Relatório detalhado'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        for (final secao in SecaoRelatorio.values)
                          CheckboxListTile(
                            value: _secoes.contains(secao),
                            onChanged: (marcada) =>
                                _alternarSecao(secao, marcada ?? false),
                            title: Text(_nomesDasSecoes[secao]!),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pré-visualização',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(height: 520, child: _buildPreview()),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            // Sem os dados não há o que gerar.
                            onPressed: _dados == null ? null : _generatePdf,
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text('Gerar relatório PDF'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_erro != null) {
      return ErroCarregamento(
        mensagem: _erro!,
        onTentarNovamente: _tentarDeNovo,
      );
    }
    if (_dados == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PdfPreview(
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      allowPrinting: false,
      allowSharing: false,
      pdfFileName: _nomeDoArquivo,
      // Uma função nova a cada build, de propósito: é a mudança dela que avisa o
      // PdfPreview para redesenhar. Com "build: _buildPdf", marcar uma caixa não
      // atualizaria a pré-visualização.
      build: (format) => _buildPdf(format),
    );
  }
}
