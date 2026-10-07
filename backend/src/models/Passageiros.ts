import mongoose, { Schema, Document } from "mongoose";

export interface IPassageiros extends Document {
    data: Date;
    catraca: number;
    antecipados: number;
    naoPagantes: number;
    totalPassageiros: number;
}

const passageirosSchema = new Schema<IPassageiros>(
    {
        data: { type: Date, required: true },
        catraca: { type: Number, required: true },
        antecipados: { type: Number, required: true },
        naoPagantes: { type: Number, required: true },
        totalPassageiros: { type: Number, required: true },
    },
    { collection: "passageiros" }
);

passageirosSchema.index({ data: 1 }, { unique: true });

export default mongoose.model<IPassageiros>("Passageiros", passageirosSchema);