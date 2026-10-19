/// A API manda datas só com o dia ("2026-09-14"). Montar o DateTime à mão
/// evita qualquer conversão de fuso: 14/09 continua 14/09 em UTC-3.
DateTime parseDia(String valor) {
  final p = valor.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

String formatarDia(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';