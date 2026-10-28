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

String _diaMes(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// "08/09 a 14/09/2026", ou "14/09/2026" quando é um dia só.
/// Dashboard e detalhes usam esta mesma função para mostrar o mesmo texto.
String rotuloPeriodo(DateTime inicio, DateTime fim) => inicio == fim
    ? '${_diaMes(inicio)}/${inicio.year}'
    : '${_diaMes(inicio)} a ${_diaMes(fim)}/${fim.year}';

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