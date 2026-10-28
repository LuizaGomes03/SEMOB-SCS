import { Router } from "express";
import * as operacaoController from "../controllers/operacao.controller";

const router = Router();

// GET /api/operacao/indicadores?dataInicio=2026-09-01&dataFim=2026-09-30&comparacao=anterior|semana_anterior|mes_anterior
router.get("/indicadores", operacaoController.indicadores);

// GET /api/operacao/relatorio?dataInicio=...&dataFim=...&agrupamento=diario|semanal|mensal
router.get("/relatorio", operacaoController.relatorio);

// GET /api/operacao/saldo?dataInicio=...&dataFim=...&agrupamento=diario|semanal|mensal
router.get("/saldo", operacaoController.saldo);

// GET /api/operacao/ultima-data
router.get("/ultima-data", operacaoController.ultimaData);

// GET /api/operacao/por-hora?dataInicio=...&dataFim=...&linha=02
router.get("/por-hora", operacaoController.porHora);

// GET /api/operacao/cumprimento?dataInicio=...&dataFim=...
router.get("/cumprimento", operacaoController.cumprimento);

// GET /api/operacao?dataInicio=...&dataFim=...&busca=01&ordenarPor=quilometragem&ordem=desc&pagina=1&limite=20
router.get("/", operacaoController.listarPorLinha);

export default router;