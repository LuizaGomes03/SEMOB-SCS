import '../core/utils/dia.dart';

/// Um feriado vindo de GET /api/feriados.
class Feriado {
  /// Só o dia, sem hora (montado pelo parseDia), para comparar com ==.
  final DateTime dia;
  final String nome;

  /// 'nacional', 'estadual' ou 'municipal'.
  final String tipo;

  const Feriado({required this.dia, required this.nome, required this.tipo});

  factory Feriado.fromJson(Map<String, dynamic> json) => Feriado(
        dia: parseDia(json['data'] as String),
        nome: json['nome'] as String,
        tipo: json['tipo'] as String,
      );
}
