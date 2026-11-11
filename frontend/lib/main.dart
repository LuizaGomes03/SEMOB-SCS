import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';

// async: o main pode esperar (await) antes de abrir o app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega os nomes de mês, dia da semana etc. em português que o DateFormat
  // usa (Formatters.date). Sem isto, DateFormat(..., 'pt_BR') lança
  // LocaleDataException na primeira data formatada.
  // Precisa ser antes do runApp porque, depois dele, qualquer tela pode
  // formatar uma data já no primeiro build. Com o await, nada é desenhado
  // antes de os dados estarem prontos. É rápido: os dados vêm dentro do
  // próprio pacote intl, não da internet.
  await initializeDateFormatting('pt_BR');

  runApp(const SemobApp());
}
