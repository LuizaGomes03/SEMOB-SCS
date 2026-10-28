import mongoose, { Schema, Document } from "mongoose";

// Um documento por dia: viagens programadas e realizadas em cada turno.
export interface IFatorCumprimentoViagem extends Document {
  data: Date;
  manhaProgr: number;
  manhaRealiz: number;
  tardeProgr: number;
  tardeRealiz: number;
  noiteProgr: number;
  noiteRealiz: number;
  programadas: number;
  realizadas: number;
}

const fatorCumprimentoViagemSchema = new Schema<IFatorCumprimentoViagem>(
  {
    data: { type: Date, required: true },
    manhaProgr: { type: Number, required: true },
    manhaRealiz: { type: Number, required: true },
    tardeProgr: { type: Number, required: true },
    tardeRealiz: { type: Number, required: true },
    noiteProgr: { type: Number, required: true },
    noiteRealiz: { type: Number, required: true },
    programadas: { type: Number, required: true },
    realizadas: { type: Number, required: true },
  },
  { collection: "fator_cumprimento_viagem" }
);

// Um dia aparece uma vez só: um segundo documento do mesmo dia dobraria a soma do período.
fatorCumprimentoViagemSchema.index({ data: 1 }, { unique: true });

export default mongoose.model<IFatorCumprimentoViagem>(
  "FatorCumprimentoViagem",
  fatorCumprimentoViagemSchema
);
