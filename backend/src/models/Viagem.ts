import mongoose, { Schema, Document } from "mongoose";

// Valor de "atividade" das viagens com passageiro. O outro valor é "Improdutivas"
// (deslocamento sem linha, sem sentido e sem horário). Fica numa constante porque
// é comparada em mais de um lugar, e um erro de digitação aqui não daria erro nenhum,
// só um resultado vazio.
export const VIAGEM_NORMAL = "Viagem Normal";

// Uma viagem feita por documento. "data" é o dia de operação (meia-noite UTC), e
// fxHor é a hora de saída já no horário de São Paulo.
export interface IViagem extends Document {
  data: Date;
  linha: string | null;
  prefixo: string;
  atividade: string;
  sentido: string | null;
  fxHor: number;
  inicioRealizado: Date | null;
  fimRealizado: Date | null;
  kmProd: number;
  kmImprod: number;
  kmTotal: number;
}

const viagemSchema = new Schema<IViagem>(
  {
    data: { type: Date, required: true },
    // As improdutivas não têm linha nem sentido: o null é dado de verdade, não falta.
    linha: { type: String, default: null },
    prefixo: { type: String, required: true },
    atividade: { type: String, required: true },
    sentido: { type: String, default: null },
    fxHor: { type: Number, required: true },
    inicioRealizado: { type: Date, default: null },
    fimRealizado: { type: Date, default: null },
    kmProd: { type: Number, required: true },
    kmImprod: { type: Number, required: true },
    kmTotal: { type: Number, required: true },
  },
  { collection: "viagens" }
);

// Toda consulta nesta collection filtra por período e às vezes por linha. Sem índice,
// o MongoDB leria os ~91 mil documentos a cada requisição para achar os de um dia.
// Com "data" na frente, o índice serve tanto para o filtro só de período quanto para
// período + linha (a linha é conferida dentro do próprio índice, sem abrir o documento).
// Não é único: o mesmo dia e a mesma linha têm centenas de viagens.
viagemSchema.index({ data: 1, linha: 1 });

export default mongoose.model<IViagem>("Viagem", viagemSchema);
