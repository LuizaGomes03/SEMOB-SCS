import mongoose, { Schema, Document } from "mongoose";

export interface IResumoLinha extends Document {
  data: Date;
  linha: string;
  kmTotal: number;
  nrViagens: number;
}

const resumoLinhaSchema = new Schema<IResumoLinha>(
  {
    data: { type: Date, required: true },
    linha: { type: String, required: true },
    kmTotal: { type: Number, required: true },
    nrViagens: { type: Number, required: true },
  },
  { collection: "resumo_linha" }
);

// A combinação dia + linha é que não pode repetir.
resumoLinhaSchema.index({ data: 1, linha: 1 }, { unique: true });

export default mongoose.model<IResumoLinha>("ResumoLinha", resumoLinhaSchema);