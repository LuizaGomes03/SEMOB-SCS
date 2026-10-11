import { Router } from "express";
import * as anomaliaController from "../controllers/anomalia.controller";

const router = Router();

// GET /api/anomalias?dataInicio=...&dataFim=...&tipo=nao_realizada|nao_iniciada|nao_terminada&linha=02&pagina=1&limite=20
router.get("/", anomaliaController.listar);

export default router;