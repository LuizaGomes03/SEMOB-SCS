import { Router } from "express";
import Anomalia from "../models/Anomalia";

const router = Router();

// GET /api/anomalias?status=aberta&severidade=critico
router.get("/", async (req, res, next) => {
  try {
    const { status, severidade } = req.query as Record<string, string>;
    const filtro: Record<string, string> = {};
    if (status) filtro.status = status;
    if (severidade) filtro.severidade = severidade;

    const anomalias = await Anomalia.find(filtro).sort({ dataOcorrencia: -1 });
    res.json(anomalias);
  } catch (err) {
    next(err);
  }
});

// POST /api/anomalias
router.post("/", async (req, res, next) => {
  try {
    const anomalia = await Anomalia.create(req.body);
    res.status(201).json(anomalia);
  } catch (err) {
    next(err);
  }
});

// PATCH /api/anomalias/:id/resolver
router.patch("/:id/resolver", async (req, res, next) => {
  try {
    const anomalia = await Anomalia.findByIdAndUpdate(
      req.params.id,
      {
        status: "resolvida",
        resolucao: { ...req.body, dataResolucao: new Date() },
      },
      { new: true }
    );

    if (!anomalia) return res.status(404).json({ erro: "Anomalia não encontrada" });
    res.json(anomalia);
  } catch (err) {
    next(err);
  }
});

export default router;