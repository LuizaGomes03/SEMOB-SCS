import { Router } from "express";
import * as operacaoController from "../controllers/operacao.controller";

const router = Router();

// Todas as rotas de período, menos /saldo, aceitam ?dias=util|sexta|sabado|domingo_feriado
// para mostrar só um tipo de dia (regras em utils/dias.ts). Sem ele, o período inteiro.

// GET /api/operacao/indicadores?dataInicio=2026-09-01&dataFim=2026-09-30&comparacao=anterior|semana_anterior|mes_anterior
router.get("/indicadores", operacaoController.indicadores);

// GET /api/operacao/relatorio?dataInicio=...&dataFim=...&agrupamento=diario|semanal|mensal&linha=02
// Com linha, passageiros e créditos vêm null: esses dados não existem por linha.
router.get("/relatorio", operacaoController.relatorio);

// GET /api/operacao/saldo?dataInicio=...&dataFim=...&agrupamento=diario|semanal|mensal
router.get("/saldo", operacaoController.saldo);

// GET /api/operacao/ultima-data
router.get("/ultima-data", operacaoController.ultimaData);

// GET /api/operacao/por-hora?dataInicio=...&dataFim=...&linha=02
router.get("/por-hora", operacaoController.porHora);

// GET /api/operacao/por-linha?dataInicio=...&dataFim=...
// programadas = viagens + não cumpridas: conferido contra resumo_geral em 27/10/2026.
router.get("/por-linha", operacaoController.porLinha);

// GET /api/operacao/cumprimento?dataInicio=...&dataFim=...
router.get("/cumprimento", operacaoController.cumprimento);

// GET /api/operacao?dataInicio=...&dataFim=...&busca=01&ordenarPor=quilometragem&ordem=desc&pagina=1&limite=20
router.get("/", operacaoController.listarPorLinha);

export default router;