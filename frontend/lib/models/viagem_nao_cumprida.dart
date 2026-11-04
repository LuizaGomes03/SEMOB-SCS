import '../core/utils/dia.dart';

/// A API manda instantes em UTC. Subtrair 3h dá o horário de São Paulo em
/// qualquer computador; toLocal() dependeria do fuso de quem abre a tela.
/// O Brasil não tem horário de verão desde 2019.
///
/// O resultado continua marcado como UTC: use só .hour, .minute, .day etc.
/// Nunca chame toLocal() nele, senão as 3h são descontadas de novo.
DateTime? _horarioSaoPaulo(dynamic valor) => valor == null
    ? null
    : DateTime.parse(valor as String)
        .toUtc()
        .subtract(const Duration(hours: 3));

/// "Ida" ou "Volta". Um código desconhecido aparece como vem, em vez de virar um
/// sentido errado. A tela e o PDF usam esta mesma função para não divergirem.
String rotuloSentido(String codigo) => switch (codigo) {
      'I' => 'Ida',
      'V' => 'Volta',
      _ => codigo,
    };

class ViagemNaoCumprida {
  /// Dia da operação. Uma viagem de 23:55 pode terminar no dia seguinte.
  final DateTime data;
  final String linha;
  final String atendimento;
  final String? prefixo;
  final String atividade;
  final String motorista;
  final String sentido;
  final String tabela;
  final String? statusSaida;
  final String? statusChegada;
  final DateTime? inicioProgramado;
  final DateTime? inicioRealizado;
  final DateTime? fimProgramado;
  final DateTime? fimRealizado;

  /// 'nao_realizada', 'nao_iniciada' ou 'nao_terminada'.
  final String tipo;

  const ViagemNaoCumprida({
    required this.data,
    required this.linha,
    required this.atendimento,
    required this.prefixo,
    required this.atividade,
    required this.motorista,
    required this.sentido,
    required this.tabela,
    required this.statusSaida,
    required this.statusChegada,
    required this.inicioProgramado,
    required this.inicioRealizado,
    required this.fimProgramado,
    required this.fimRealizado,
    required this.tipo,
  });

  factory ViagemNaoCumprida.fromJson(Map<String, dynamic> json) {
    return ViagemNaoCumprida(
      // "2026-09-10T00:00:00.000Z" é só o dia: nada de converter fuso aqui.
      data: parseDia((json['data'] as String).substring(0, 10)),
      linha: json['linha'] as String,
      atendimento: json['atendimento'] as String,
      prefixo: json['prefixo'] as String?,
      atividade: json['atividade'] as String,
      motorista: json['motorista'] as String,
      sentido: json['sentido'] as String,
      tabela: json['tabela'] as String,
      statusSaida: json['statusSaida'] as String?,
      statusChegada: json['statusChegada'] as String?,
      inicioProgramado: _horarioSaoPaulo(json['inicioProgramado']),
      inicioRealizado: _horarioSaoPaulo(json['inicioRealizado']),
      fimProgramado: _horarioSaoPaulo(json['fimProgramado']),
      fimRealizado: _horarioSaoPaulo(json['fimRealizado']),
      tipo: json['tipo'] as String,
    );
  }

  String get tipoRotulo => switch (tipo) {
        'nao_realizada' => 'Não realizada',
        'nao_iniciada' => 'Não iniciada',
        'nao_terminada' => 'Não terminada',
        _ => tipo,
      };
}

class ViagensNaoCumpridas {
  final List<ViagemNaoCumprida> itens;
  final int total;
  final int pagina;
  final int limite;

  /// Com o filtro de tipo, a API só devolve a contagem daquele tipo.
  final Map<String, int> totalPorTipo;

  const ViagensNaoCumpridas({
    required this.itens,
    required this.total,
    required this.pagina,
    required this.limite,
    required this.totalPorTipo,
  });

  factory ViagensNaoCumpridas.fromJson(Map<String, dynamic> json) {
    return ViagensNaoCumpridas(
      itens: (json['itens'] as List<dynamic>)
          .map((i) => ViagemNaoCumprida.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      pagina: (json['pagina'] as num).toInt(),
      limite: (json['limite'] as num).toInt(),
      totalPorTipo: (json['totalPorTipo'] as Map<String, dynamic>).map(
        (tipo, quantidade) => MapEntry(tipo, (quantidade as num).toInt()),
      ),
    );
  }
}
