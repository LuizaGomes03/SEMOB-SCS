import { Router } from "express";

import operacaoRoutes from "./operacao.routes";
import anomaliaRoutes from "./anomalia.routes";
// próximos módulos: passageiros, financeiro, relatorios, notificacoes, auth...

const router = Router();

router.use("/operacao", operacaoRoutes);
router.use("/anomalias", anomaliaRoutes);

export default router;