import { Request, Response, NextFunction } from "express";
import * as operacaoService from "../services/operacao.service";
import * as porHoraService from "../services/porHora.service";
import { parseDatas, periodoAnterior, tiposComparacao, TipoComparacao } from "../utils/datas";
import { lerDias } from "../utils/dias";

export async function indicadores(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const dias = lerDias(req);
    const comparacao = (req.query.comparacao as string) || "anterior";

    if (!tiposComparacao.includes(comparacao as TipoComparacao)) {
      return res.status(400).json({
        erro: `Comparação inválida. Use uma de: ${tiposComparacao.join(", ")}`,
      });
    }

    if (!req.query.dataInicio) {
      const dados = await operacaoService.getIndicadores({ dataInicio, dataFim, dias });
      return res.json({ ...dados, comparacao: null });
    }

    const anterior = periodoAnterior(dataInicio, dataFim, comparacao as TipoComparacao);
    const dados = await operacaoService.getIndicadoresComComparacao({
      dataInicio,
      dataFim,
      anterior,
      tipo: comparacao,
      dias,
    });
    res.json(dados);
  } catch (err) {
    next(err);
  }
}

export async function relatorio(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const agrupamento = (req.query.agrupamento as "diario" | "semanal" | "mensal") || "diario";
    // "?linha=" vazio vira undefined: senão o filtro procuraria a linha "" e voltaria vazio.
    const linha = (req.query.linha as string) || undefined;
    const dias = lerDias(req);
    const dados = await operacaoService.getRelatorioPorPeriodo({ dataInicio, dataFim, agrupamento, linha, dias });
    res.json(dados);
  } catch (err) {
    next(err);
  }
}

export async function listarPorLinha(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const {
      busca,
      ordenarPor,
      ordem,
      pagina = "1",
      limite = "20",
    } = req.query as Record<string, string>;
    const dias = lerDias(req);

    const dados = await operacaoService.listarPorLinha({
      dataInicio,
      dataFim,
      dias,
      busca,
      ordenarPor,
      ordem,
      pagina: Number(pagina),
      limite: Number(limite),
    });

    res.json(dados);
  } catch (err) {
    next(err);
  }
}

export async function saldo(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const agrupamento = (req.query.agrupamento as "diario" | "semanal" | "mensal") || "diario";
    // ?dias= é ignorado aqui: saldo é foto do fim do dia e não se filtra por tipo de dia.
    const dados = await operacaoService.getSaldo({ dataInicio, dataFim, agrupamento });
    res.json(dados);
  } catch (err) {
    next(err);
  }
}

export async function ultimaData(_req: Request, res: Response, next: NextFunction) {
  try {
    const dados = await operacaoService.getUltimaData();
    res.json(dados);
  } catch (err) {
    next(err);
  }
}

export async function porHora(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    // "?linha=" vazio vira undefined: senão o filtro procuraria a linha "" e voltaria tudo zerado.
    const linha = (req.query.linha as string) || undefined;
    const dias = lerDias(req);
    const dados = await porHoraService.getPorHora({ dataInicio, dataFim, linha, dias });
    res.json(dados);
  } catch (err) {
    next(err);
  }
}

export async function porLinha(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const dias = lerDias(req);
    const dados = await operacaoService.getPorLinha({ dataInicio, dataFim, dias });
    res.json(dados);
  } catch (err) {
    next(err);
  }
}

export async function cumprimento(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const dias = lerDias(req);
    const dados = await porHoraService.getCumprimento({ dataInicio, dataFim, dias });
    res.json(dados);
  } catch (err) {
    next(err);
  }
}
