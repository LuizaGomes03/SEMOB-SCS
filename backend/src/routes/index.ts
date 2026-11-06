import { Router } from "express";

import operacaoRoutes from "./operacao.routes";
import anomaliaRoutes from "./anomalia.routes";
import feriadosRoutes from "./feriados.routes";

const router = Router();

router.use("/operacao", operacaoRoutes);
router.use("/anomalias", anomaliaRoutes);
router.use("/feriados", feriadosRoutes);

export default router;