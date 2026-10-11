import mongoose, { Schema, Document } from "mongoose";

// Um documento por viagem programada que não foi cumprida, igual aos três relatórios
// da SEMOB. Os três têm as mesmas colunas, então dividem o mesmo schema.
export interface IViagemNaoCumprida extends Document {
  data: Date;
  linha: string;
  atendimento: string;
  prefixo: string | null;
  atividade: string;
  motorista: string;
  sentido: string;
  tabela: string;
  statusSaida: string | null;
  statusChegada: string | null;
  inicioProgramado: Date;
  inicioRealizado: Date | null;
  fimProgramado: Date;
  fimRealizado: Date | null;
  kmProd: number;
}

const viagemNaoCumpridaSchema = new Schema<IViagemNaoCumprida>({
  data: { type: Date, required: true },
  linha: { type: String, required: true },
  atendimento: { type: String, required: true },
  prefixo: { type: String, default: null },
  atividade: { type: String, required: true },
  motorista: { type: String, required: true },
  sentido: { type: String, required: true },
  tabela: { type: String, required: true },
  statusSaida: { type: String, default: null },
  statusChegada: { type: String, default: null },
  inicioProgramado: { type: Date, required: true },
  inicioRealizado: { type: Date, default: null },
  fimProgramado: { type: Date, required: true },
  fimRealizado: { type: Date, default: null },
  kmProd: { type: Number, required: true },
});

viagemNaoCumpridaSchema.index({ data: 1 });

// Sem início nem fim registrados: a viagem não saiu.
export const ViagemNaoRealizada = mongoose.model<IViagemNaoCumprida>(
  "ViagemNaoRealizada",
  viagemNaoCumpridaSchema,
  "viagens_nao_realizadas"
);

// Sem início registrado, mas com chegada.
export const ViagemNaoIniciada = mongoose.model<IViagemNaoCumprida>(
  "ViagemNaoIniciada",
  viagemNaoCumpridaSchema,
  "viagens_nao_iniciadas"
);

// Com início registrado, mas sem chegada.
export const ViagemNaoTerminada = mongoose.model<IViagemNaoCumprida>(
  "ViagemNaoTerminada",
  viagemNaoCumpridaSchema,
  "viagens_nao_terminadas"
);