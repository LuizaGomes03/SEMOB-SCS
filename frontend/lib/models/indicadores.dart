import '../core/utils/dia.dart';

class Indicadores {
  final num quilometragem;
  final num viagens;
  final num viagensProgramadas;
  final num passageirosPagantes;
  final num passageirosNaoPagantes;
  final num creditosVendidos;
  final num creditosUtilizados;
  final int diasOperacao;
  final int diasPassageiros;
  final int diasFinanceiro;
  final ComparacaoIndicadores? comparacao;

  const Indicadores({
    required this.quilometragem,
    required this.viagens,
    required this.viagensProgramadas,
    required this.passageirosPagantes,
    required this.passageirosNaoPagantes,
    required this.creditosVendidos,
    required this.creditosUtilizados,
    required this.diasOperacao,
    required this.diasPassageiros,
    required this.diasFinanceiro,
    this.comparacao,
  });

  factory Indicadores.fromJson(Map<String, dynamic> json) {
    final comparacao = json['comparacao'];

    return Indicadores(
      quilometragem: json['quilometragem'] as num,
      viagens: json['viagens'] as num,
      viagensProgramadas: json['viagensProgramadas'] as num,
      passageirosPagantes: json['passageirosPagantes'] as num,
      passageirosNaoPagantes: json['passageirosNaoPagantes'] as num,
      creditosVendidos: json['creditosVendidos'] as num,
      creditosUtilizados: json['creditosUtilizados'] as num,
      diasOperacao: (json['diasOperacao'] as num).toInt(),
      diasPassageiros: (json['diasPassageiros'] as num).toInt(),
      diasFinanceiro: (json['diasFinanceiro'] as num).toInt(),
      comparacao: comparacao == null
          ? null
          : ComparacaoIndicadores.fromJson(comparacao as Map<String, dynamic>),
    );
  }
}

class ComparacaoIndicadores {
  final String tipo;
  final DateTime dataInicio;
  final DateTime dataFim;
  final Indicadores anterior;

  /// null = sem base para comparar. A tela esconde o "x% vs.", não mostra 0%.
  final Map<String, double?> variacaoPercentual;

  const ComparacaoIndicadores({
    required this.tipo,
    required this.dataInicio,
    required this.dataFim,
    required this.anterior,
    required this.variacaoPercentual,
  });

  factory ComparacaoIndicadores.fromJson(Map<String, dynamic> json) {
    return ComparacaoIndicadores(
      tipo: json['tipo'] as String,
      dataInicio: parseDia(json['dataInicio'] as String),
      dataFim: parseDia(json['dataFim'] as String),
      anterior: Indicadores.fromJson(json['anterior'] as Map<String, dynamic>),
      variacaoPercentual: (json['variacaoPercentual'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num?)?.toDouble())),
    );
  }
}