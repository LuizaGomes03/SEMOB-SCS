// A lista de feriados vem da API (GET /api/feriados), a mesma que o backend usa
// para o filtro de dias: assim o app e o servidor nunca discordam sobre o que é
// feriado. Para mudar a lista, mude no backend (src/dados/feriados.ts).

import '../../models/feriado.dart';

// Reexporta o modelo: quem já importava este arquivo para usar List<Feriado>
// (dashboard, relatório) continua funcionando sem mudar nenhum import.
export '../../models/feriado.dart';

// Por que uma variável no arquivo (estado global) é aceitável aqui:
// - o app.dart busca a lista e chama definirFeriados ANTES de mostrar qualquer
//   tela, então nenhuma tela chega a ler a lista vazia;
// - depois disso ela não muda durante a execução (só o botão Atualizar a troca,
//   e aí todas as telas são reconstruídas de qualquer jeito).
// Como ninguém precisa "reagir" a uma mudança, não há o que notificar.
//
// A alternativa seria passar a lista pelo construtor de cada tela, ou colocá-la
// num InheritedWidget (ou Provider/Riverpod) no topo do app. Isso deixa explícito
// quem depende dos feriados e facilita testar com uma lista falsa, mas obrigaria
// a mudar a assinatura de todas as telas que usam estas funções.

/// Chave: só o dia. Um mapa, e não a lista, porque feriado(dia) é chamado para
/// cada dia de cada gráfico: procurar no mapa não depende do tamanho da lista.
Map<DateTime, Feriado> _porDia = const {};

/// Em ordem de data, para feriadosNoPeriodo já devolver ordenado.
List<Feriado> _ordenados = const [];

/// Chamada pelo app.dart quando a busca dos feriados chega.
void definirFeriados(List<Feriado> lista) {
  _ordenados = [...lista]..sort((a, b) => a.dia.compareTo(b.dia));
  _porDia = {for (final f in _ordenados) _soDia(f.dia): f};
}

/// Dois DateTime só são iguais se a hora também for: sem isto, 07/09 às 10h não
/// acharia o feriado de 07/09.
DateTime _soDia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Nome do feriado daquele dia, ou null se não for feriado.
String? feriado(DateTime dia) => _porDia[_soDia(dia)]?.nome;

/// Feriados de [inicio] a [fim], os dois inclusive, em ordem de data.
List<Feriado> feriadosNoPeriodo(DateTime inicio, DateTime fim) {
  final de = _soDia(inicio);
  final ate = _soDia(fim);

  return [
    for (final f in _ordenados)
      if (!f.dia.isBefore(de) && !f.dia.isAfter(ate)) f,
  ];
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

/// Os tipos de dia do filtro ?dias= da API. [valorApi] é o texto que vai na URL.
enum TipoDia {
  util('util'),
  sexta('sexta'),
  sabado('sabado'),
  domingoFeriado('domingo_feriado');

  const TipoDia(this.valorApi);

  final String valorApi;
}

/// Se [dia] entra no filtro [tipo], com as mesmas regras do backend:
/// - util: segunda a sexta, exceto feriados;
/// - sexta: sextas, exceto feriados;
/// - sabado: sábados, exceto feriados;
/// - domingoFeriado: todo domingo e todo feriado, mesmo em dia de semana.
///
/// Devolve bool, e não "o tipo do dia", porque um dia pode estar em dois tipos:
/// uma sexta comum é dia útil e também sexta.
///
/// weekday do Dart: 1 = segunda ... 7 = domingo (DateTime.monday ... sunday).
/// O $dayOfWeek do Mongo, usado no backend, é diferente: 1 = domingo ...
/// 7 = sábado. Por isso aqui se usam as constantes do Dart, e não números
/// copiados do backend.
bool diaEhDoTipo(DateTime dia, TipoDia tipo) {
  final d = _soDia(dia);
  final ehFeriado = _porDia.containsKey(d);

  return switch (tipo) {
    TipoDia.util => !ehFeriado && d.weekday <= DateTime.friday,
    TipoDia.sexta => !ehFeriado && d.weekday == DateTime.friday,
    TipoDia.sabado => !ehFeriado && d.weekday == DateTime.saturday,
    TipoDia.domingoFeriado => ehFeriado || d.weekday == DateTime.sunday,
  };
}

/// Os dias de [inicio] a [fim] (inclusive) que entram no filtro [tipo]. São
/// dias do CALENDÁRIO: não diz nada sobre ter havido operação neles.
List<DateTime> diasDoTipo(DateTime inicio, DateTime fim, TipoDia tipo) => [
      // DateTime(ano, mês, dia + 1) em vez de add(Duration(days: 1)): o
      // construtor sempre cai na meia-noite do dia seguinte, mesmo com horário
      // de verão (um add de 24h poderia parar às 23h do mesmo dia).
      for (var d = _soDia(inicio);
          !d.isAfter(_soDia(fim));
          d = DateTime(d.year, d.month, d.day + 1))
        if (diaEhDoTipo(d, tipo)) d,
    ];

/// Quantos dias de [inicio] a [fim] (inclusive) entram no filtro [tipo].
int contarDiasDoTipo(DateTime inicio, DateTime fim, TipoDia tipo) =>
    diasDoTipo(inicio, fim, tipo).length;
