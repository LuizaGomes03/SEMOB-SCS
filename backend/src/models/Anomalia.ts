import mongoose, { Schema, Document } from "mongoose";

export interface IAnomalia extends Document {
  linha?: { codigo?: string; nome?: string };
  descricao: string;
  severidade: "critico" | "atencao";
  status: "aberta" | "em_analise" | "resolvida";
  dataOcorrencia: Date;
  resolucao?: {
    responsavel?: string;
    observacao?: string;
    dataResolucao?: Date;
  };
}

const anomaliaSchema = new Schema<IAnomalia>(
  {
    linha: { codigo: String, nome: String },
    descricao: { type: String, required: true },
    severidade: {
      type: String,
      enum: ["critico", "atencao"],
      required: true,
    },
    status: {
      type: String,
      enum: ["aberta", "em_analise", "resolvida"],
      default: "aberta",
    },
    dataOcorrencia: { type: Date, required: true, default: Date.now },
    resolucao: {
      responsavel: String,
      observacao: String,
      dataResolucao: Date,
    },
  },
  { timestamps: true }
);

export default mongoose.model<IAnomalia>("Anomalia", anomaliaSchema);