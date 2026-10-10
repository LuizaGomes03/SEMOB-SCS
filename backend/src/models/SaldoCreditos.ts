import mongoose, { Schema, Document } from "mongoose";

export interface ISaldoCreditos extends Document {
  data: Date;
  serie: string;
  creditosTransferidos: number;
  saldoFinal: number;
}

const saldoCreditosSchema = new Schema<ISaldoCreditos>(
  {
    data: { type: Date, required: true },
    serie: { type: String, required: true },
    creditosTransferidos: { type: Number, required: true },
    saldoFinal: { type: Number, required: true },
  },
  { collection: "saldo_creditos" }
);

saldoCreditosSchema.index({ data: 1, serie: 1 }, { unique: true });

export default mongoose.model<ISaldoCreditos>("SaldoCreditos", saldoCreditosSchema);