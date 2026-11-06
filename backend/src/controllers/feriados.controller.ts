import { Request, Response } from "express";
import { feriados } from "../dados/feriados";

// Sem service: a lista é fixa, em memória, e não há consulta ao banco nem cálculo.
// Sem try/catch: não há nada aqui que possa falhar.
export function listar(_req: Request, res: Response) {
  res.json(feriados);
}
