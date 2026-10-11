import {
  ViagemNaoRealizada,
  ViagemNaoIniciada,
  ViagemNaoTerminada,
} from "../models/ViagemNaoCumprida";

const modelPorTipo = {
  nao_realizada: ViagemNaoRealizada,
  nao_iniciada: ViagemNaoIniciada,
  nao_terminada: ViagemNaoTerminada,
};

export type TipoAnomalia = keyof typeof modelPorTipo;

export const tiposAnomalia = Object.keys(modelPorTipo) as TipoAnomalia[];

interface ListarAnomaliasParams {
  dataInicio: Date;
  dataFim: Date;
  tipo?: TipoAnomalia;
  linha?: string;
  pagina: number;
  limite: number;
}

export async function listarAnomalias({
  dataInicio,
  dataFim,
  tipo,
  linha,
  pagina,
  limite,
}: ListarAnomaliasParams) {
  const filtro: Record<string, unknown> = { data: { $gte: dataInicio, $lte: dataFim } };
  if (linha) filtro.linha = linha;

  // O que cada coleção faz antes de se juntar às outras: filtra e ganha o campo "tipo",
  // que é a única coisa que diz de qual relatório o documento veio.
  const ramo = (t: TipoAnomalia) => [{ $match: filtro }, { $set: { tipo: t } }];

  // Com ?tipo=... entra só uma coleção; sem ele, entram as três.
  const [primeiro, ...demais] = tipo ? [tipo] : tiposAnomalia;

  const paginaAtual = Math.max(1, Math.floor(pagina) || 1);
  const porPagina = Math.min(100, Math.max(1, Math.floor(limite) || 20));

  const [resultado] = await modelPorTipo[primeiro].aggregate([
    ...ramo(primeiro),
    ...demais.map((t) => ({
      $unionWith: { coll: modelPorTipo[t].collection.name, pipeline: ramo(t) },
    })),
    {
      // Três contas sobre o mesmo conjunto, numa ida só ao banco.
      $facet: {
        itens: [
          { $sort: { inicioProgramado: -1, linha: 1, tipo: 1 } },
          { $skip: (paginaAtual - 1) * porPagina },
          { $limit: porPagina },
          { $project: { _id: 0 } },
        ],
        total: [{ $count: "n" }],
        porTipo: [{ $group: { _id: "$tipo", n: { $sum: 1 } } }],
      },
    },
  ]);

  const totalPorTipo: Partial<Record<TipoAnomalia, number>> = {};
  for (const t of tipo ? [tipo] : tiposAnomalia) {
    totalPorTipo[t] = resultado.porTipo.find((p: { _id: string }) => p._id === t)?.n ?? 0;
  }

  return {
    itens: resultado.itens,
    total: resultado.total[0]?.n ?? 0,
    totalPorTipo,
    pagina: paginaAtual,
    limite: porPagina,
  };
}