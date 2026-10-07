import mongoose, { Schema, Document } from "mongoose";

export interface IResumoGeral extends Document {
  data: Date;
  diaSem: string;
  nrVeiculos: number;
  nrMaxVeicFx: number;
  nrViagensProgr: number;
  nrViagensRealiz: number;
  difViagens: number;
  kmProd: number;
  kmImprod: number;
  kmTotal: number;
}

const resumoGeralSchema = new Schema<IResumoGeral>(
  {
    data: { type: Date, required: true },
    diaSem: { type: String, required: true },
    nrVeiculos: { type: Number, required: true },
    nrMaxVeicFx: { type: Number, required: true },
    nrViagensProgr: { type: Number, required: true },
    nrViagensRealiz: { type: Number, required: true },
    difViagens: { type: Number, required: true },
    kmProd: { type: Number, required: true },
    kmImprod: { type: Number, required: true },
    kmTotal: { type: Number, required: true },
  },
  { collection: "resumo_geral" }
);

resumoGeralSchema.index({ data: 1 }, { unique: true });

export default mongoose.model<IResumoGeral>("ResumoGeral", resumoGeralSchema);