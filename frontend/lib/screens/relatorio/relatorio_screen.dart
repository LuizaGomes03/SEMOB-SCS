import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../mock/mock_transporte_data.dart';

enum ReportType { resumo, operacional, detalhado }

class RelatorioScreen extends StatefulWidget {
  final String selectedPeriod;
  final String periodLabel;
  final String dataReferenceLabel;

  const RelatorioScreen({
    super.key,
    required this.selectedPeriod,
    required this.periodLabel,
    required this.dataReferenceLabel,
  });

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  ReportType _reportType = ReportType.resumo;
  bool _includeKpis = true;
  bool _includeOperations = true;
  bool _includeFinancial = true;

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

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final dynamic rawData =
        MockTransporteData.getKpisByPeriod(widget.selectedPeriod);

    final dynamic rawOperations = MockTransporteData.operacoes;
    final List<dynamic> operations =
        rawOperations is List ? rawOperations.take(10).toList() : [];

    final kpis = <Map<String, String>>[
      {
        'nome': 'Quilometragem',
        'valor': _readKpi(rawData, 'km'),
        'unidade': 'km',
      },
      {
        'nome': 'Viagens',
        'valor': _readKpi(rawData, 'viagens'),
        'unidade': 'viagens',
      },
      {
        'nome': 'Passageiros pagantes',
        'valor': _readKpi(rawData, 'pagantes'),
        'unidade': 'passageiros',
      },
      {
        'nome': 'Gratuidades',
        'valor': _readKpi(rawData, 'naoPagantes'),
        'unidade': 'passageiros',
      },
      {
        'nome': 'Financeiro',
        'valor': _readKpi(rawData, 'financeiro'),
        'unidade': 'R\$',
      },
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              color: PdfColor.fromHex('#183B70'),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SEMOB-SCS',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Dashboard de Operação de Transporte',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              _reportTitle,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Período: ${widget.periodLabel}'),
            pw.Text(widget.dataReferenceLabel),
            pw.SizedBox(height: 18),
          ];

          if (_includeKpis) {
            widgets.addAll([
              pw.Text(
                'Indicadores principais',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: const ['Indicador', 'Valor', 'Unidade'],
                data: kpis
                    .map(
                      (kpi) => [
                        kpi['nome']!,
                        kpi['valor']!,
                        kpi['unidade']!,
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellPadding: const pw.EdgeInsets.all(6),
              ),
              pw.SizedBox(height: 20),
            ]);
          }

          if (_includeOperations) {
            widgets.addAll([
              pw.Text(
                'Operação das linhas',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (operations.isEmpty)
                pw.Text('Nenhum dado operacional disponível.')
              else
                pw.Table.fromTextArray(
                  headers: const [
                    'Linha',
                    'Viagens',
                    'Programadas',
                    'Km',
                    'Pagantes',
                  ],
                  data: operations.map((item) {
                    return [
                      _read(item, 'lineCode'),
                      _read(item, 'viagens'),
                      _read(item, 'viagensProgramadas'),
                      _read(item, 'km'),
                      _read(item, 'pagantes'),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellPadding: const pw.EdgeInsets.all(5),
                ),
              pw.SizedBox(height: 20),
            ]);
          }

          if (_includeFinancial) {
            widgets.addAll([
              pw.Text(
                'Financeiro',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Valor consolidado do período: '
                '${_readKpi(rawData, 'financeiro')} R\$',
              ),
              pw.SizedBox(height: 20),
            ]);
          }

          if (_reportType == ReportType.detalhado) {
            widgets.addAll([
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                'Observação',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Este relatório utiliza os dados atualmente disponibilizados '
                'pelo módulo de demonstração do projeto SEMOB-SCS.',
              ),
            ]);
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  String _readKpi(dynamic data, String key) {
    if (data is Map) {
      final value = data[key];
      if (value == null) return '-';

      try {
        final dynamic rawValue = value.value;
        if (rawValue == null) return value.toString();

        if (rawValue is num) {
          return rawValue.toStringAsFixed(rawValue % 1 == 0 ? 0 : 2);
        }

        return rawValue.toString();
      } catch (_) {
        return value.toString();
      }
    }

    return '-';
  }

  String _read(dynamic item, String field) {
    try {
      switch (field) {
        case 'lineCode':
          return item.lineCode?.toString() ?? '-';
        case 'viagens':
          return item.viagens?.toString() ?? '-';
        case 'viagensProgramadas':
          return item.viagensProgramadas?.toString() ?? '-';
        case 'km':
          return item.km?.toString() ?? '-';
        case 'pagantes':
          return item.pagantes?.toString() ?? '-';
        default:
          return '-';
      }
    } catch (_) {
      return '-';
    }
  }

  Future<void> _generatePdf() async {
    await Printing.layoutPdf(
      onLayout: (format) => _buildPdf(format),
      name: 'relatorio_semob_scs.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerar relatório')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
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
                    Text(widget.periodLabel),
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
                            RadioListTile<ReportType>(
                              value: ReportType.resumo,
                              groupValue: _reportType,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _reportType = value);
                                }
                              },
                              title: const Text('Resumo executivo'),
                            ),
                            RadioListTile<ReportType>(
                              value: ReportType.operacional,
                              groupValue: _reportType,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _reportType = value);
                                }
                              },
                              title: const Text('Relatório operacional'),
                            ),
                            RadioListTile<ReportType>(
                              value: ReportType.detalhado,
                              groupValue: _reportType,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _reportType = value);
                                }
                              },
                              title: const Text('Relatório detalhado'),
                            ),
                            const Divider(),
                            CheckboxListTile(
                              value: _includeKpis,
                              onChanged: (value) {
                                setState(() => _includeKpis = value ?? false);
                              },
                              title: const Text('Indicadores principais'),
                            ),
                            CheckboxListTile(
                              value: _includeOperations,
                              onChanged: (value) {
                                setState(
                                  () => _includeOperations = value ?? false,
                                );
                              },
                              title: const Text('Operação das 10 linhas'),
                            ),
                            CheckboxListTile(
                              value: _includeFinancial,
                              onChanged: (value) {
                                setState(
                                  () => _includeFinancial = value ?? false,
                                );
                              },
                              title: const Text('Financeiro'),
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
                            SizedBox(
                              height: 520,
                              child: PdfPreview(
                                canChangeOrientation: false,
                                canChangePageFormat: false,
                                canDebug: false,
                                allowPrinting: false,
                                allowSharing: false,
                                build: (format) => _buildPdf(format),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _generatePdf,
                                icon: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                ),
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
          );
        },
      ),
    );
  }
}
