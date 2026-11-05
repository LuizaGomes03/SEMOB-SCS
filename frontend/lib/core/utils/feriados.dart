// Lista montada pelo grupo em 04/11/2026.
//
// Pontos facultativos (Carnaval, Corpus Christi) ficam de fora porque não se sabe
// se a operação muda nesses dias. A lista oficial ainda é uma pergunta para a SEMOB.
//
// Só tem 2026: para outros anos, acrescente as datas em _feriados.

typedef Feriado = ({DateTime dia, String nome});

/// As chaves são só o dia, sem hora, como as datas montadas pelo parseDia.
final Map<DateTime, String> _feriados = {
  // Nacionais
  DateTime(2026, 1, 1): 'Confraternização Universal',
  DateTime(2026, 4, 3): 'Sexta-feira Santa',
  DateTime(2026, 4, 21): 'Tiradentes',
  DateTime(2026, 5, 1): 'Dia do Trabalho',
  DateTime(2026, 9, 7): 'Independência',
  DateTime(2026, 10, 12): 'Nossa Senhora Aparecida',
  DateTime(2026, 11, 2): 'Finados',
  DateTime(2026, 11, 15): 'Proclamação da República',
  DateTime(2026, 11, 20): 'Consciência Negra',
  DateTime(2026, 12, 25): 'Natal',
  // Estadual (SP)
  DateTime(2026, 7, 9): 'Revolução Constitucionalista',
  // Municipal (São Caetano do Sul)
  DateTime(2026, 7, 28): 'Aniversário da cidade',
};

/// Dois DateTime só são iguais se a hora também for: sem isto, 07/09 às 10h não
/// acharia o feriado de 07/09.
DateTime _soDia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Nome do feriado daquele dia, ou null se não for feriado.
String? feriado(DateTime dia) => _feriados[_soDia(dia)];

/// Feriados de [inicio] a [fim], os dois inclusive, em ordem de data.
List<Feriado> feriadosNoPeriodo(DateTime inicio, DateTime fim) {
  final de = _soDia(inicio);
  final ate = _soDia(fim);

  return [
    for (final MapEntry(key: dia, value: nome) in _feriados.entries)
      if (!dia.isBefore(de) && !dia.isAfter(ate)) (dia: dia, nome: nome),
    // O mapa está agrupado por tipo de feriado, não por data.
  ]..sort((a, b) => a.dia.compareTo(b.dia));
}

/// "09/07 (Revolução Constitucionalista), 28/07 (Aniversário da cidade)".
String formatarFeriados(List<Feriado> feriados) => feriados
    .map((f) => '${_doisDigitos(f.dia.day)}/${_doisDigitos(f.dia.month)} '
        '(${f.nome})')
    .join(', ');

/// "inclui feriado: 07/09 (Independência)", no plural quando há mais de um.
String incluiFeriados(List<Feriado> feriados) =>
    'inclui ${feriados.length == 1 ? 'feriado' : 'feriados'}: '
    '${formatarFeriados(feriados)}';

String _doisDigitos(int n) => n.toString().padLeft(2, '0');
