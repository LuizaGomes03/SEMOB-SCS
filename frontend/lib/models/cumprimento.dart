import '../core/utils/formatters.dart';

class Cumprimento {
  final CumprimentoTurno manha;
  final CumprimentoTurno tarde;
  final CumprimentoTurno noite;
  final CumprimentoTurno total;

  /// Quantos dias com dado entraram na soma.
  final int dias;

  const Cumprimento({
    required this.manha,
    required this.tarde,
    required this.noite,
    required this.total,
    required this.dias,
  });

  factory Cumprimento.fromJson(Map<String, dynamic> json) {
    CumprimentoTurno turno(String nome) =>
        CumprimentoTurno.fromJson(json[nome] as Map<String, dynamic>);

    return Cumprimento(
      manha: turno('manha'),
      tarde: turno('tarde'),
      noite: turno('noite'),
      total: turno('total'),
      dias: (json['dias'] as num).toInt(),
    );
  }
}

class CumprimentoTurno {
  final int programadas;
  final int realizadas;

  /// null quando programadas é 0: sem viagem programada não existe cumprimento.
  /// Calculado aqui, e não lido da API, porque a rota manda o valor arredondado.
  final double? percentual;

  const CumprimentoTurno({
    required this.programadas,
    required this.realizadas,
    required this.percentual,
  });

  factory CumprimentoTurno.fromJson(Map<String, dynamic> json) {
    final programadas = (json['programadas'] as num).toInt();
    final realizadas = (json['realizadas'] as num).toInt();

    return CumprimentoTurno(
      programadas: programadas,
      realizadas: realizadas,
      percentual: Formatters.percentualCortado(realizadas, programadas),
    );
  }
}
