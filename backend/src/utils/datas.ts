import { Request } from "express";

// Lê dataInicio e dataFim da query string. Sem os parâmetros, o período é "tudo até hoje".
export function parseDatas(req: Request) {
  const dataInicio = req.query.dataInicio ? new Date(req.query.dataInicio as string) : new Date(0);
  const dataFim = req.query.dataFim ? new Date(req.query.dataFim as string) : new Date();
  return { dataInicio, dataFim };
}