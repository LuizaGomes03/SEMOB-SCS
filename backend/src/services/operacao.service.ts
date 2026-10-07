import ResumoGeral from "../models/ResumoGeral";
import Passageiros from "../models/Passageiros";
import ResumoLinha from "../models/ResumoLinha";
import VendaUtilizacao from "../models/VendaUtilizacao";

interface Periodo {
  dataInicio: Date;
  dataFim: Date;
}

// Arredonda para 2 casas: somar valores em reais em ponto flutuante acumula erro.
const arredondarReais = (valor: number) => Math.round(valor * 100) / 100;

export async function getIndicadores({ dataInicio, dataFim }: Periodo) {
  const periodo = { data: { $gte: dataInicio, $lte: dataFim } };

  // As três consultas são independentes, então rodam ao mesmo tempo.
  const [[operacao], [passageiros], [financeiro]] = await Promise.all([
    ResumoGeral.aggregate([
      { $match: periodo },
      {
        $group: {
          _id: null,
          quilometragem: { $sum: "$kmTotal" },
          viagens: { $sum: "$nrViagensRealiz" },
          viagensProgramadas: { $sum: "$nrViagensProgr" },
          dias: { $sum: 1 },
        },
      },
    ]),
    Passageiros.aggregate([
      { $match: periodo },
      {
        $group: {
          _id: null,
          pagantes: { $sum: { $add: ["$catraca", "$antecipados"] } },
          naoPagantes: { $sum: "$naoPagantes" },
          dias: { $sum: 1 },
        },
      },
    ]),
    VendaUtilizacao.aggregate([
      { $match: periodo },
      {
        $group: {
          _id: null,
          vendas: { $sum: "$totalVendas" },
          utilizacao: { $sum: "$totalUtilizacao" },
          dias: { $sum: 1 },
        },
      },
    ]),
  ]);

  return {
    quilometragem: Math.round((operacao?.quilometragem ?? 0) * 10) / 10,
    viagens: operacao?.viagens ?? 0,
    viagensProgramadas: operacao?.viagensProgramadas ?? 0,
    passageirosPagantes: passageiros?.pagantes ?? 0,
    passageirosNaoPagantes: passageiros?.naoPagantes ?? 0,
    creditosVendidos: arredondarReais(financeiro?.vendas ?? 0),
    creditosUtilizados: arredondarReais(financeiro?.utilizacao ?? 0),
    diasOperacao: operacao?.dias ?? 0,
    diasPassageiros: passageiros?.dias ?? 0,
    diasFinanceiro: financeiro?.dias ?? 0,
  };
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
  const periodo = { data: { $gte: dataInicio, $lte: dataFim } };
  // A mesma chave nas três consultas: é ela que permite juntar os resultados depois.
  const chave = { $dateToString: { format: formato, date: "$data" } };

  const [operacao, passageiros, financeiro] = await Promise.all([
    ResumoGeral.aggregate([
      { $match: periodo },
      {
        $group: {
          _id: chave,
          inicio: { $min: "$data" },
          fim: { $max: "$data" },
          quilometragem: { $sum: "$kmTotal" },
          viagens: { $sum: "$nrViagensRealiz" },
          viagensProgramadas: { $sum: "$nrViagensProgr" },
          dias: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]),
    Passageiros.aggregate([
      { $match: periodo },
      {
        $group: {
          _id: chave,
          pagantes: { $sum: { $add: ["$catraca", "$antecipados"] } },
          naoPagantes: { $sum: "$naoPagantes" },
          dias: { $sum: 1 },
        },
      },
    ]),
    VendaUtilizacao.aggregate([
      { $match: periodo },
      {
        $group: {
          _id: chave,
          vendas: { $sum: "$totalVendas" },
          utilizacao: { $sum: "$totalUtilizacao" },
          dias: { $sum: 1 },
        },
      },
    ]),
  ]);

  const passageirosPorChave = new Map(passageiros.map((p) => [p._id, p]));
  const financeiroPorChave = new Map(financeiro.map((f) => [f._id, f]));

  return operacao.map((o) => {
    const p = passageirosPorChave.get(o._id);
    const f = financeiroPorChave.get(o._id);

    return {
      periodo: o._id,
      inicio: o.inicio,
      fim: o.fim,
      quilometragem: Math.round(o.quilometragem * 10) / 10,
      viagens: o.viagens,
      viagensProgramadas: o.viagensProgramadas,
      passageirosPagantes: p ? p.pagantes : null,
      passageirosNaoPagantes: p ? p.naoPagantes : null,
      creditosVendidos: f ? arredondarReais(f.vendas) : null,
      creditosUtilizados: f ? arredondarReais(f.utilizacao) : null,
      diasOperacao: o.dias,
      diasPassageiros: p ? p.dias : 0,
      diasFinanceiro: f ? f.dias : 0,
    };
  });
}

interface ListarPorLinhaParams extends Periodo {
  busca?: string;
  ordenarPor?: string;
  ordem?: string;
  pagina: number;
  limite: number;
}

const camposOrdenacao = new Map([
  ["data", "data"],
  ["linha", "linha"],
  ["quilometragem", "kmTotal"],
  ["viagens", "nrViagens"],
]);

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
    const texto = busca.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    filtro.linha = { $regex: texto, $options: "i" };
  }

  const campo = camposOrdenacao.get(ordenarPor || "data") || "data";
  const sort: Record<string, 1 | -1> = { [campo]: ordem === "asc" ? 1 : -1 };
  if (campo !== "data") sort.data = -1;
  if (campo !== "linha") sort.linha = 1;

  const paginaAtual = Math.max(1, Math.floor(pagina) || 1);
  const porPagina = Math.min(100, Math.max(1, Math.floor(limite) || 20));

  const [registros, total] = await Promise.all([
    ResumoLinha.find(filtro)
      .sort(sort)
      .skip((paginaAtual - 1) * porPagina)
      .limit(porPagina)
      .lean(),
    ResumoLinha.countDocuments(filtro),
  ]);

  const itens = registros.map((r) => ({
    data: r.data,
    linha: r.linha,
    quilometragem: r.kmTotal,
    viagens: r.nrViagens,
  }));

  return { itens, total, pagina: paginaAtual, limite: porPagina };
}