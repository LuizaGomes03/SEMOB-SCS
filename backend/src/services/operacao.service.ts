import Operacao from "../models/Operacao.ts";

interface Periodo {
  dataInicio: Date;
  dataFim: Date;
}

export async function getIndicadores({ dataInicio, dataFim }: Periodo) {
  const [resultado] = await Operacao.aggregate([
    { $match: { data: { $gte: dataInicio, $lte: dataFim } } },
    {
      $group: {
        _id: null,
        quilometragem: { $sum: "$quilometragem" },
        viagens: { $sum: "$viagens" },
        passageirosPagantes: { $sum: "$passageiros.pagantes" },
        passageirosNaoPagantes: { $sum: "$passageiros.naoPagantes" },
        receitaTarifaria: { $sum: "$financeiro.receitaTarifaria" },
      },
    },
  ]);

  return (
    resultado || {
      quilometragem: 0,
      viagens: 0,
      passageirosPagantes: 0,
      passageirosNaoPagantes: 0,
      receitaTarifaria: 0,
    }
  );
}

type Agrupamento = "diario" | "semanal" | "mensal";

export async function getRelatorioPorPeriodo({
  dataInicio,
  dataFim,
  agrupamento,
}: Periodo & { agrupamento: Agrupamento }) {
  const formatoPorAgrupamento: Record<Agrupamento, string> = {
    diario: "%Y-%m-%d",
    semanal: "%G-W%V",
    mensal: "%Y-%m",
  };

  const formato = formatoPorAgrupamento[agrupamento] || formatoPorAgrupamento.diario;

  return Operacao.aggregate([
    { $match: { data: { $gte: dataInicio, $lte: dataFim } } },
    {
      $group: {
        _id: { $dateToString: { format: formato, date: "$data" } },
        quilometragem: { $sum: "$quilometragem" },
        viagens: { $sum: "$viagens" },
        passageirosPagantes: { $sum: "$passageiros.pagantes" },
        passageirosNaoPagantes: { $sum: "$passageiros.naoPagantes" },
        receitaTarifaria: { $sum: "$financeiro.receitaTarifaria" },
      },
    },
    { $sort: { _id: 1 } },
  ]);
}

interface ListarPorLinhaParams extends Periodo {
  busca?: string;
  ordenarPor?: string;
  ordem?: string;
  pagina: number;
  limite: number;
}

export async function listarPorLinha({
  dataInicio,
  dataFim,
  busca,
  ordenarPor,
  ordem,
  pagina,
  limite,
}: ListarPorLinhaParams) {
  const filtro: Record<string, unknown> = { data: { $gte: dataInicio, $lte: dataFim } };

  if (busca) {
    filtro.$or = [
      { "linha.codigo": { $regex: busca, $options: "i" } },
      { "linha.nome": { $regex: busca, $options: "i" } },
    ];
  }

  const sort: Record<string, 1 | -1> = { [ordenarPor || "data"]: ordem === "asc" ? 1 : -1 };
  const skip = (pagina - 1) * limite;

  const [itens, total] = await Promise.all([
    Operacao.find(filtro).sort(sort).skip(skip).limit(limite),
    Operacao.countDocuments(filtro),
  ]);

  return { itens, total, pagina, limite };
}