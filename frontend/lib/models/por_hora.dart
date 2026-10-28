class PorHora {
  /// Sempre as 24 horas (0 a 23), no horário de São Paulo.
  final List<PorHoraItem> horas;

  /// Quantos dias com operação entraram na soma.
  final int dias;

  /// Km rodado sem passageiro: não tem horário, então não entra em [horas].
  /// Por isso a soma das horas fica abaixo da quilometragem do dia.
  final num kmImprodutivoSemHora;

  const PorHora({
    required this.horas,
    required this.dias,
    required this.kmImprodutivoSemHora,
  });

  factory PorHora.fromJson(Map<String, dynamic> json) {
    return PorHora(
      horas: (json['horas'] as List<dynamic>)
          .map((h) => PorHoraItem.fromJson(h as Map<String, dynamic>))
          .toList(),
      dias: (json['dias'] as num).toInt(),
      kmImprodutivoSemHora: json['kmImprodutivoSemHora'] as num,
    );
  }
}

class PorHoraItem {
  final int hora;
  final num viagens;
  final num quilometragem;
  final FalhasPorHora falhas;

  const PorHoraItem({
    required this.hora,
    required this.viagens,
    required this.quilometragem,
    required this.falhas,
  });

  factory PorHoraItem.fromJson(Map<String, dynamic> json) {
    return PorHoraItem(
      hora: (json['hora'] as num).toInt(),
      viagens: json['viagens'] as num,
      quilometragem: json['quilometragem'] as num,
      falhas: FalhasPorHora.fromJson(json['falhas'] as Map<String, dynamic>),
    );
  }
}

class FalhasPorHora {
  final int naoRealizada;
  final int naoIniciada;
  final int naoTerminada;

  const FalhasPorHora({
    required this.naoRealizada,
    required this.naoIniciada,
    required this.naoTerminada,
  });

  factory FalhasPorHora.fromJson(Map<String, dynamic> json) {
    return FalhasPorHora(
      naoRealizada: (json['nao_realizada'] as num).toInt(),
      naoIniciada: (json['nao_iniciada'] as num).toInt(),
      naoTerminada: (json['nao_terminada'] as num).toInt(),
    );
  }
}
