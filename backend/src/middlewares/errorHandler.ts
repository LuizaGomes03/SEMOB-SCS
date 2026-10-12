import { Request, Response, NextFunction } from "express";

interface ErroComStatus extends Error {
  status?: number;
}

export function errorHandler(err: ErroComStatus, req: Request, res: Response, next: NextFunction) {
  
  const status = err.status || 500;

  // Erro 4xx é pedido errado do cliente, não falha do servidor: não precisa de stack trace no log.
  if (status >= 500) console.error("[erro]", err);

  res.status(status).json({
    erro: err.message || "Erro interno no servidor",
  });
}