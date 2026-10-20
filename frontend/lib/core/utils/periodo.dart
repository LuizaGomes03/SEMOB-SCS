import 'package:flutter/material.dart' show DateTimeRange;

/// O que o dashboard pede à API: o período e com o que ele é comparado.
class PeriodoConsulta {
  final DateTime inicio;
  final DateTime fim;
  final String comparacao;

  const PeriodoConsulta({
    required this.inicio,
    required this.fim,
    required this.comparacao,
  });

  // Igualdade por valor: o dashboard só busca de novo quando o período muda de fato.
  @override
  bool operator ==(Object other) =>
      other is PeriodoConsulta &&
      other.inicio == inicio &&
      other.fim == fim &&
      other.comparacao == comparacao;

  @override
  int get hashCode => Object.hash(inicio, fim, comparacao);
}

DateTime _soDia(DateTime d) => DateTime(d.year, d.month, d.day);

PeriodoConsulta periodoDaConsulta({
  required String botao,
  required DateTime ultimaData,
  DateTimeRange? personalizado,
}) {
  final hoje = _soDia(ultimaData);

  switch (botao) {
    case 'semana':
      return PeriodoConsulta(
        inicio: DateTime(hoje.year, hoje.month, hoje.day - 6),
        fim: hoje,
        comparacao: 'anterior',
      );
    case 'mes':
    case 'mês':
      return PeriodoConsulta(
        inicio: DateTime(hoje.year, hoje.month, 1),
        fim: hoje,
        comparacao: 'mes_anterior',
      );
    case 'personalizado':
      if (personalizado != null) {
        return PeriodoConsulta(
          inicio: _soDia(personalizado.start),
          fim: _soDia(personalizado.end),
          comparacao: 'anterior',
        );
      }
  }

  // 'hoje' (e qualquer valor inesperado)
  return PeriodoConsulta(inicio: hoje, fim: hoje, comparacao: 'semana_anterior');
}