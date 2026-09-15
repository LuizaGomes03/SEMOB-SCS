import { Router } from "express";
import * as operacaoController from "../controllers/operacao.controller";

const router = Router();

// GET /api/operacao/indicadores?dataInicio=2026-09-01&dataFim=2026-09-30
router.get("/indicadores", operacaoController.indicadores);

// GET /api/operacao/relatorio?dataInicio=...&dataFim=...&agrupamento=diario|semanal|mensal
router.get("/relatorio", operacaoController.relatorio);

// GET /api/operacao?dataInicio=...&dataFim=...&busca=001&ordenarPor=quilometragem&ordem=desc&pagina=1&limite=20
router.get("/", operacaoController.listarPorLinha);

export default router;