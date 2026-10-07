import mongoose, { Schema, Document } from "mongoose";

// Um documento por dia, igual ao relatório "Venda x Utilização" da SEMOB (sistema inteiro).
export interface IVendaUtilizacao extends Document {
  data: Date;
  totalVendas: number;
  totalUtilizacao: number;
  creditoCirculante: number;
}

const vendaUtilizacaoSchema = new Schema<IVendaUtilizacao>(
  {
    data: { type: Date, required: true },
    totalVendas: { type: Number, required: true },
    totalUtilizacao: { type: Number, required: true },
    creditoCirculante: { type: Number, required: true },
  },
  { collection: "venda_utilizacao" }
);

vendaUtilizacaoSchema.index({ data: 1 }, { unique: true });

export default mongoose.model<IVendaUtilizacao>("VendaUtilizacao", vendaUtilizacaoSchema);