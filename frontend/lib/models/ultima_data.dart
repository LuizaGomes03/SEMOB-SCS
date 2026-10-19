import '../core/utils/dia.dart';

class UltimaData {
  final DateTime? ultimaData;
  final Map<String, DateTime?> porFonte;

  const UltimaData({required this.ultimaData, required this.porFonte});

  factory UltimaData.fromJson(Map<String, dynamic> json) {
    DateTime? dia(dynamic v) => v == null ? null : parseDia(v as String);

    return UltimaData(
      ultimaData: dia(json['ultimaData']),
      porFonte: (json['porFonte'] as Map<String, dynamic>)
          .map((fonte, valor) => MapEntry(fonte, dia(valor))),
    );
  }
}