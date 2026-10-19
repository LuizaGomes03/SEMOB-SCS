import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/utils/dia.dart';
import '../models/indicadores.dart';
import '../models/ultima_data.dart';

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

  Future<Map<String, dynamic>> _get(
    String caminho, [
    Map<String, String>? query,
  ]) async {
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

    return corpo as Map<String, dynamic>;
  }

  Future<UltimaData> ultimaData() async {
    return UltimaData.fromJson(await _get('/operacao/ultima-data'));
  }

  /// comparacao: 'anterior', 'semana_anterior' ou 'mes_anterior'.
  Future<Indicadores> indicadores({
    required DateTime dataInicio,
    required DateTime dataFim,
    String comparacao = 'anterior',
  }) async {
    return Indicadores.fromJson(await _get('/operacao/indicadores', {
      'dataInicio': formatarDia(dataInicio),
      'dataFim': formatarDia(dataFim),
      'comparacao': comparacao,
    }));
  }
}