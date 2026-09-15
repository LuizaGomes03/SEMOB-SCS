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

  static String date(DateTime date) => DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
}
