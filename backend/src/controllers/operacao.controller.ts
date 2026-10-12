import { Request, Response, NextFunction } from "express";
import * as operacaoService from "../services/operacao.service";
import { parseDatas, periodoAnterior, tiposComparacao, TipoComparacao } from "../utils/datas";

export async function indicadores(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const comparacao = (req.query.comparacao as string) || "anterior";

    if (!tiposComparacao.includes(comparacao as TipoComparacao)) {
      return res.status(400).json({
        erro: `Comparação inválida. Use uma de: ${tiposComparacao.join(", ")}`,
      });
    }

    if (!req.query.dataInicio) {
      const dados = await operacaoService.getIndicadores({ dataInicio, dataFim });
      return res.json({ ...dados, comparacao: null });
    }

    const anterior = periodoAnterior(dataInicio, dataFim, comparacao as TipoComparacao);
    const dados = await operacaoService.getIndicadoresComComparacao({
      dataInicio,
      dataFim,
      anterior,
      tipo: comparacao,
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
    const dados = await operacaoService.getRelatorioPorPeriodo({ dataInicio, dataFim, agrupamento });
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

    const dados = await operacaoService.listarPorLinha({
      dataInicio,
      dataFim,
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