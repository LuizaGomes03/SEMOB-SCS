class OperacaoItem {
  final String id;
  final String date;
  final String lineId;
  final String lineCode;
  final String lineName;
  final int km;
  final int kmProgramado;
  final int viagens;
  final int viagensProgramadas;
  final int pagantes;
  final int naoPagantes;
  final double financeiro;
  final String status;
  final String statusDesc;
  final int veiculosAtivos;

  const OperacaoItem({
    required this.id,
    required this.date,
    required this.lineId,
    required this.lineCode,
    required this.lineName,
    required this.km,
    required this.kmProgramado,
    required this.viagens,
    required this.viagensProgramadas,
    required this.pagantes,
    required this.naoPagantes,
    required this.financeiro,
    required this.status,
    required this.statusDesc,
    required this.veiculosAtivos,
  });

  int get totalPassageiros => pagantes + naoPagantes;

  double get percentualPagantes =>
      totalPassageiros == 0 ? 0 : (pagantes / totalPassageiros) * 100;
}
