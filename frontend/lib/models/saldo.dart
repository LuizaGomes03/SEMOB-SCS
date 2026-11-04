import '../core/utils/dia.dart';

/// O resumo do saldo no período. Saldo é uma foto do fim do dia: não se soma.
class Saldo {
  /// null: não há registro antes do período começar.
  final num? saldoInicial;

  /// null: não há nenhum registro até o fim do período.
  final num? saldoFinal;

  /// O dia do saldo final. Pode ser anterior ao fim do período, quando o último
  /// dia não tem registro.
  final DateTime? dataSaldoFinal;

  /// null: falta o saldo inicial ou o final para calcular.
  final num? variacao;

  final num creditosTransferidos;
  final int dias;

  const Saldo({
    required this.saldoInicial,
    required this.saldoFinal,
    required this.dataSaldoFinal,
    required this.variacao,
    required this.creditosTransferidos,
    required this.dias,
  });

  /// Recebe o objeto "resumo" da resposta da rota.
  factory Saldo.fromJson(Map<String, dynamic> json) {
    final data = json['dataSaldoFinal'] as String?;

    return Saldo(
      saldoInicial: json['saldoInicial'] as num?,
      saldoFinal: json['saldoFinal'] as num?,
      // A rota manda "2026-09-14T00:00:00.000Z", e é só o dia: sem converter fuso.
      dataSaldoFinal: data == null ? null : parseDia(data.substring(0, 10)),
      variacao: json['variacao'] as num?,
      creditosTransferidos: json['creditosTransferidos'] as num,
      dias: (json['dias'] as num).toInt(),
    );
  }
}
