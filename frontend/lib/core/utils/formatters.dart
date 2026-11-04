import 'package:intl/intl.dart';

/// Formatadores utilitários para números, moedas e datas no padrão brasileiro
class Formatters {
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'pt_BR');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String number(num value) => _numberFormat.format(value);

  static String currency(num value) => _currencyFormat.format(value);

  static String percentage(num value, {bool showSign = true}) {
    final formatted = value.toStringAsFixed(1).replaceAll('.', ',');
    if (showSign && value > 0) {
      return '+$formatted%';
    }
    return '$formatted%';
  }

  /// Cumprimento em %, cortado em uma casa decimal; null sem viagem programada.
  /// Só para cumprimento: variação pode ser negativa e tem outra regra.
  ///
  /// Corta em vez de arredondar para que 100,0% só apareça sem nenhuma falha:
  /// 8.066 de 8.068 é 99,97%, e arredondado viraria um 100,0% com duas viagens
  /// perdidas.
  ///
  /// A conta é só com inteiros porque o ponto flutuante erra justamente no corte:
  /// 29 / 50 * 100 dá 57,99999..., e o floor mostraria 57,9% em vez de 58,0%.
  /// Já 29 * 1000 ~/ 50 dá exatamente 580 décimos.
  static double? percentualCortado(int realizadas, int programadas) =>
      programadas == 0 ? null : (realizadas * 1000 ~/ programadas) / 10;

  /// O mesmo cumprimento como texto: "99,9%", ou [semValor] sem viagem programada.
  /// O PDF passa o próprio [semValor]: a fonte dele não desenha este travessão.
  static String cumprimento(
    int realizadas,
    int programadas, {
    String semValor = '—',
  }) {
    final valor = percentualCortado(realizadas, programadas);
    return valor == null ? semValor : percentage(valor, showSign: false);
  }

  static String date(DateTime date) => DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
}
