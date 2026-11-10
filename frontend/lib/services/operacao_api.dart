import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/utils/dia.dart';
import '../models/cumprimento.dart';
import '../models/feriado.dart';
import '../models/indicadores.dart';
import '../models/por_hora.dart';
import '../models/por_linha.dart';
import '../models/saldo.dart';
import '../models/ultima_data.dart';
import '../models/relatorio_item.dart';
import '../models/viagem_nao_cumprida.dart';

class ApiException implements Exception {
  final String mensagem;
  final int? statusCode;

  ApiException(this.mensagem, {this.statusCode});

  @override
  String toString() => mensagem;
}

class OperacaoApi {
  OperacaoApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> _get(String caminho, [Map<String, String>? query]) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$caminho')
        .replace(queryParameters: query);

    final http.Response resposta;
    try {
      resposta = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException('A API demorou demais para responder.');
    } catch (_) {
      throw ApiException('Não foi possível conectar à API ($uri).');
    }

    dynamic corpo;
    try {
      // utf8.decode: sem isso, acentos ("Não") podem chegar quebrados.
      corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
    } on FormatException {
      throw ApiException(
        'Resposta inválida da API (status ${resposta.statusCode}).',
        statusCode: resposta.statusCode,
      );
    }

    if (resposta.statusCode != 200) {
      final erro = corpo is Map && corpo['erro'] is String
          ? corpo['erro'] as String
          : 'Erro ${resposta.statusCode} na API.';
      throw ApiException(erro, statusCode: resposta.statusCode);
    }

    return corpo;
  }

  Future<UltimaData> ultimaData() async {
    final corpo = await _get('/operacao/ultima-data') as Map<String, dynamic>;
    return UltimaData.fromJson(corpo);
  }

  /// Fica fora de /operacao: a rota é /api/feriados.
  Future<List<Feriado>> feriados() async {
    final corpo = await _get('/feriados') as List<dynamic>;
    return corpo
        .map((item) => Feriado.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // dias, em todas as rotas que aceitam: 'util', 'sexta', 'sabado' ou
  // 'domingo_feriado' (TipoDia.valorApi). null: todos os dias. Vai com "?dias"
  // no mapa para a chave nem aparecer na URL quando for null: a API trata
  // "sem dias" como todos os dias, mas recusa (400) um valor vazio ou inválido.

  /// comparacao: 'anterior', 'semana_anterior' ou 'mes_anterior'.
  /// Com dias, a comparação também é filtrada (regra do backend).
  Future<Indicadores> indicadores({
    required DateTime dataInicio,
    required DateTime dataFim,
    String comparacao = 'anterior',
    String? dias,
  }) async {
    return Indicadores.fromJson(
      await _get('/operacao/indicadores', {
        'dataInicio': formatarDia(dataInicio),
        'dataFim': formatarDia(dataFim),
        'comparacao': comparacao,
        'dias': ?dias,
      }),
    );
  }

  /// agrupamento: 'diario', 'semanal' ou 'mensal'.
  /// linha: código da linha ("02"). Com ela, passageiros e créditos vêm null.
  Future<List<RelatorioItem>> relatorio({
    required DateTime dataInicio,
    required DateTime dataFim,
    String agrupamento = 'diario',
    String? linha,
    String? dias,
  }) async {
    final corpo = await _get('/operacao/relatorio', {
      'dataInicio': formatarDia(dataInicio),
      'dataFim': formatarDia(dataFim),
      'agrupamento': agrupamento,
      'linha': ?linha,
      'dias': ?dias,
    }) as List<dynamic>;

    return corpo
        .map((item) => RelatorioItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// linha: código da linha ("02"). Sem ela, soma todas as linhas.
  Future<PorHora> porHora({
    required DateTime dataInicio,
    required DateTime dataFim,
    String? linha,
    String? dias,
  }) async {
    final corpo = await _get('/operacao/por-hora', {
      'dataInicio': formatarDia(dataInicio),
      'dataFim': formatarDia(dataFim),
      // "?linha": a chave só entra no mapa se linha não for null.
      'linha': ?linha,
      'dias': ?dias,
    }) as Map<String, dynamic>;

    return PorHora.fromJson(corpo);
  }

  /// Não aceita linha: esse dado só existe para a cidade inteira.
  Future<Cumprimento> cumprimento({
    required DateTime dataInicio,
    required DateTime dataFim,
    String? dias,
  }) async {
    final corpo = await _get('/operacao/cumprimento', {
      'dataInicio': formatarDia(dataInicio),
      'dataFim': formatarDia(dataFim),
      'dias': ?dias,
    }) as Map<String, dynamic>;

    return Cumprimento.fromJson(corpo);
  }

  /// Todas as linhas do banco, mesmo as que não rodaram no período.
  Future<PorLinha> porLinha({
    required DateTime dataInicio,
    required DateTime dataFim,
    String? dias,
  }) async {
    final corpo = await _get('/operacao/por-linha', {
      'dataInicio': formatarDia(dataInicio),
      'dataFim': formatarDia(dataFim),
      'dias': ?dias,
    }) as Map<String, dynamic>;

    return PorLinha.fromJson(corpo);
  }

  /// tipo: 'nao_realizada', 'nao_iniciada' ou 'nao_terminada'. Sem ele, todos.
  /// linha: código exato da linha ("02"). Sem ela, todas.
  Future<ViagensNaoCumpridas> viagensNaoCumpridas({
    required DateTime dataInicio,
    required DateTime dataFim,
    String? tipo,
    String? linha,
    String? dias,
    int pagina = 1,
    int limite = 20,
  }) async {
    final corpo = await _get('/anomalias', {
      'dataInicio': formatarDia(dataInicio),
      'dataFim': formatarDia(dataFim),
      'tipo': ?tipo,
      'linha': ?linha,
      'dias': ?dias,
      'pagina': pagina.toString(),
      'limite': limite.toString(),
    }) as Map<String, dynamic>;

    return ViagensNaoCumpridas.fromJson(corpo);
  }

  /// Só o resumo do período: a lista de "periodos" da rota não é usada.
  Future<Saldo> saldo({
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    final corpo = await _get('/operacao/saldo', {
      'dataInicio': formatarDia(dataInicio),
      'dataFim': formatarDia(dataFim),
      'agrupamento': 'diario',
    }) as Map<String, dynamic>;

    return Saldo.fromJson(corpo['resumo'] as Map<String, dynamic>);
  }
}