import mongoose from "mongoose";

export async function connectDB(): Promise<void> {
  const uri = process.env.MONGO_URI;

  if (!uri) {
    throw new Error("MONGO_URI não definida no .env");
  }

  try {
    await mongoose.connect(uri);
    console.log("[db] Conectado ao MongoDB");
  } catch (err) {
    console.error("[db] Erro ao conectar no MongoDB:", (err as Error).message);
    process.exit(1);
  }
}