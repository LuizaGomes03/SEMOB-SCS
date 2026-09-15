import mongoose, { Schema, Document } from "mongoose";

export interface IOperacao extends Document {
  linha: { codigo: string; nome: string };
  data: Date;
  quilometragem: number;
  viagens: number;
  passageiros: { pagantes: number; naoPagantes: number };
  financeiro: { receitaTarifaria: number };
  fonte: "mock" | "smart_data";
}

const operacaoSchema = new Schema<IOperacao>(
  {
    linha: {
      codigo: { type: String, required: true },
      nome: { type: String, required: true },
    },
    data: { type: Date, required: true },
    quilometragem: { type: Number, required: true, default: 0 },
    viagens: { type: Number, required: true, default: 0 },
    passageiros: {
      pagantes: { type: Number, required: true, default: 0 },
      naoPagantes: { type: Number, required: true, default: 0 },
    },
    financeiro: {
      receitaTarifaria: { type: Number, required: true, default: 0 },
    },
    fonte: {
      type: String,
      enum: ["mock", "smart_data"],
      default: "mock",
    },
  },
  { timestamps: true }
);

operacaoSchema.index({ "linha.codigo": 1, data: 1 });
operacaoSchema.index({ data: 1 });

export default mongoose.model<IOperacao>("Operacao", operacaoSchema);