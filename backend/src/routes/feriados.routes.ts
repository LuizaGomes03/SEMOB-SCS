import { Router } from "express";
import * as feriadosController from "../controllers/feriados.controller";

const router = Router();

// GET /api/feriados → [{ data: "2026-07-09", nome: "Revolução Constitucionalista", tipo: "estadual" }, ...]
router.get("/", feriadosController.listar);

export default router;
