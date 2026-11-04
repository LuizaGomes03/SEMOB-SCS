/// Explica por que a soma das linhas fica abaixo do total dos indicadores. Numa
/// constante só: a tela e o PDF precisam dizer exatamente a mesma coisa.
const avisoKmPorLinha = 'O km por linha não inclui o km improdutivo (sem '
    'passageiros), que não é informado por linha.';

class PorLinha {
  /// Todas as linhas do banco, em ordem de código. Quem não rodou no período
  /// vem com tudo zero.
  final List<PorLinhaItem> linhas;
  final PorLinhaTotais totais;

  const PorLinha({required this.linhas, required this.totais});

  factory PorLinha.fromJson(Map<String, dynamic> json) {
    return PorLinha(
      linhas: (json['linhas'] as List<dynamic>)
          .map((l) => PorLinhaItem.fromJson(l as Map<String, dynamic>))
          .toList(),
      totais: PorLinhaTotais.fromJson(json['totais'] as Map<String, dynamic>),
    );
  }
}

class PorLinhaItem {
  /// Código com zero à esquerda: "06".
  final String linha;
  final num quilometragem;
  final int viagens;
  final int naoCumpridas;

  /// Viagens feitas + não cumpridas.
  final int programadas;

  /// Quantos dias a linha operou no período.
  final int dias;

  const PorLinhaItem({
    required this.linha,
    required this.quilometragem,
    required this.viagens,
    required this.naoCumpridas,
    required this.programadas,
    required this.dias,
  });

  factory PorLinhaItem.fromJson(Map<String, dynamic> json) {
    return PorLinhaItem(
      linha: json['linha'] as String,
      quilometragem: json['quilometragem'] as num,
      viagens: (json['viagens'] as num).toInt(),
      naoCumpridas: (json['naoCumpridas'] as num).toInt(),
      programadas: (json['programadas'] as num).toInt(),
      dias: (json['dias'] as num).toInt(),
    );
  }
}

class PorLinhaTotais {
  final num quilometragem;
  final int viagens;
  final int naoCumpridas;
  final int programadas;

  const PorLinhaTotais({
    required this.quilometragem,
    required this.viagens,
    required this.naoCumpridas,
    required this.programadas,
  });

  factory PorLinhaTotais.fromJson(Map<String, dynamic> json) {
    return PorLinhaTotais(
      quilometragem: json['quilometragem'] as num,
      viagens: (json['viagens'] as num).toInt(),
      naoCumpridas: (json['naoCumpridas'] as num).toInt(),
      programadas: (json['programadas'] as num).toInt(),
    );
  }
}
