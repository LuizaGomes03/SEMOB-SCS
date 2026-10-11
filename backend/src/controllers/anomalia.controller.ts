import { Request, Response, NextFunction } from "express";
import * as anomaliaService from "../services/anomalia.service";
import { parseDatas } from "../utils/datas";

export async function listar(req: Request, res: Response, next: NextFunction) {
  try {
    const { dataInicio, dataFim } = parseDatas(req);
    const { tipo, linha, pagina = "1", limite = "20" } = req.query as Record<string, string>;

    if (tipo && !anomaliaService.tiposAnomalia.includes(tipo as anomaliaService.TipoAnomalia)) {
      return res.status(400).json({
        erro: `Tipo inválido. Use um de: ${anomaliaService.tiposAnomalia.join(", ")}`,
      });
    }

    const dados = await anomaliaService.listarAnomalias({
      dataInicio,
      dataFim,
      tipo: tipo as anomaliaService.TipoAnomalia | undefined,
      linha,
      pagina: Number(pagina),
      limite: Number(limite),
    });

    res.json(dados);
  } catch (err) {
    next(err);
  }
}