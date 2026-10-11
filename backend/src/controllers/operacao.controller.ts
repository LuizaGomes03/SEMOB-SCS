import { Request, Response, NextFunction } from "express";
import * as operacaoService from "../services/operacao.service";
import { parseDatas } from "../utils/datas";

export async function indicadores(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const dados = await operacaoService.getIndicadores({ dataInicio, dataFim });
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