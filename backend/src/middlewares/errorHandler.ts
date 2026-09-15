import { Request, Response, NextFunction } from "express";

interface ErroComStatus extends Error {
  status?: number;
}

export function errorHandler(err: ErroComStatus, req: Request, res: Response, next: NextFunction) {
  console.error("[erro]", err);

  const status = err.status || 500;
  res.status(status).json({
    erro: err.message || "Erro interno no servidor",
  });
}