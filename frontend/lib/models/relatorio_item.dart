import '../core/utils/dia.dart';

class RelatorioItem {
  
  final String periodo;
  final DateTime inicio;
  final DateTime fim;

  final num quilometragem;
  final num viagens;
  final num viagensProgramadas;
  final num? passageirosPagantes;
  final num? passageirosNaoPagantes;
  final num? creditosVendidos;
  final num? creditosUtilizados;

  final int diasOperacao;
  final int diasPassageiros;
  final int diasFinanceiro;

  const RelatorioItem({
    required this.periodo,
    required this.inicio,
    required this.fim,
    required this.quilometragem,
    required this.viagens,
    required this.viagensProgramadas,
    this.passageirosPagantes,
    this.passageirosNaoPagantes,
    this.creditosVendidos,
    this.creditosUtilizados,
    required this.diasOperacao,
    required this.diasPassageiros,
    required this.diasFinanceiro,
  });

  factory RelatorioItem.fromJson(Map<String, dynamic> json) {
    DateTime dia(dynamic v) => parseDia((v as String).substring(0, 10));

    return RelatorioItem(
      periodo: json['periodo'] as String,
      inicio: dia(json['inicio']),
      fim: dia(json['fim']),
      quilometragem: json['quilometragem'] as num,
      viagens: json['viagens'] as num,
      viagensProgramadas: json['viagensProgramadas'] as num,
      passageirosPagantes: json['passageirosPagantes'] as num?,
      passageirosNaoPagantes: json['passageirosNaoPagantes'] as num?,
      creditosVendidos: json['creditosVendidos'] as num?,
      creditosUtilizados: json['creditosUtilizados'] as num?,
      diasOperacao: (json['diasOperacao'] as num).toInt(),
      diasPassageiros: (json['diasPassageiros'] as num).toInt(),
      diasFinanceiro: (json['diasFinanceiro'] as num).toInt(),
    );
  }
}