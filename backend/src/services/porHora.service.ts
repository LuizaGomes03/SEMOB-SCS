import Viagem, { VIAGEM_NORMAL } from "../models/Viagem";
import FatorCumprimentoViagem from "../models/FatorCumprimentoViagem";
import {
  ViagemNaoRealizada,
  ViagemNaoIniciada,
  ViagemNaoTerminada,
} from "../models/ViagemNaoCumprida";

interface Periodo {
  dataInicio: Date;
  dataFim: Date;
}

const modelPorTipoFalha = {
  nao_realizada: ViagemNaoRealizada,
  nao_iniciada: ViagemNaoIniciada,
  nao_terminada: ViagemNaoTerminada,
};

type TipoFalha = keyof typeof modelPorTipoFalha;
const tiposFalha = Object.keys(modelPorTipoFalha) as TipoFalha[];

const arredondarKm = (valor: number) => Math.round(valor * 10) / 10;

// O que sai dos aggregates, antes de virar a resposta.
export interface FeitasPorHora {
  _id: number;
  viagens: number;
  quilometragem: number;
}

export interface FalhasPorHora {
  _id: { tipo: TipoFalha; hora: number };
  total: number;
}

// Monta as 24 horas a partir do que o banco devolveu. O $group só devolve as horas que
// tiveram alguma viagem; sem completar o eixo, o gráfico pularia de 1h para 4h como
// se fossem vizinhas. Por isso parte de 24 horas zeradas e preenche as que vieram.
export function montarHoras(feitas: FeitasPorHora[], falhas: FalhasPorHora[]) {
  const horas = Array.from({ length: 24 }, (_, hora) => ({
    hora,
    viagens: 0,
    quilometragem: 0,
    falhas: { nao_realizada: 0, nao_iniciada: 0, nao_terminada: 0 } as Record<TipoFalha, number>,
  }));

  for (const f of feitas) {
    horas[f._id].viagens = f.viagens;
    horas[f._id].quilometragem = arredondarKm(f.quilometragem);
  }

  for (const f of falhas) {
    horas[f._id.hora].falhas[f._id.tipo] = f.total;
  }

  return horas;
}

export async function getPorHora({ dataInicio, dataFim, linha }: Periodo & { linha?: string }) {
  const filtro: Record<string, unknown> = { data: { $gte: dataInicio, $lte: dataFim } };
  if (linha) filtro.linha = linha;

  const normais = { ...filtro, atividade: VIAGEM_NORMAL };

  // Cada coleção de falha ganha o campo "tipo" antes de se juntar às outras,
  // igual à listagem de anomalias: é ele que diz de qual relatório a viagem veio.
  const ramoFalha = (t: TipoFalha) => [{ $match: filtro }, { $set: { tipo: t } }];
  const [primeiraFalha, ...demaisFalhas] = tiposFalha;

  // As quatro consultas não dependem umas das outras, então rodam ao mesmo tempo.
  const [feitas, [improdutivo], [contagemDias], falhas] = await Promise.all([
    // Só viagens normais: as improdutivas vêm com fxHor 0 e inflariam a meia-noite.
    Viagem.aggregate<FeitasPorHora>([
      { $match: normais },
      { $group: { _id: "$fxHor", viagens: { $sum: 1 }, quilometragem: { $sum: "$kmTotal" } } },
    ]),
    // O km das improdutivas não tem hora, mas faz parte da quilometragem do dia.
    // Vai à parte para que barras + este valor batam com o total dos indicadores.
    // Com filtro de linha, nada casa (elas não têm linha) e o valor fica 0.
    Viagem.aggregate([
      { $match: { ...filtro, atividade: { $ne: VIAGEM_NORMAL } } },
      { $group: { _id: null, km: { $sum: "$kmTotal" } } },
    ]),
    // Quantos dias entraram na soma, para o frontend poder mostrar média por dia.
    Viagem.aggregate([{ $match: normais }, { $group: { _id: "$data" } }, { $count: "dias" }]),
    // Os horários das falhas estão em UTC de verdade: a hora precisa ser lida no fuso
    // de São Paulo, senão uma viagem das 23h55 cai às 2h do dia seguinte.
    modelPorTipoFalha[primeiraFalha].aggregate<FalhasPorHora>([
      ...ramoFalha(primeiraFalha),
      ...demaisFalhas.map((t) => ({
        $unionWith: { coll: modelPorTipoFalha[t].collection.name, pipeline: ramoFalha(t) },
      })),
      {
        $group: {
          _id: {
            tipo: "$tipo",
            hora: { $hour: { date: "$inicioProgramado", timezone: "America/Sao_Paulo" } },
          },
          total: { $sum: 1 },
        },
      },
    ]),
  ]);

  return {
    horas: montarHoras(feitas, falhas),
    dias: contagemDias?.dias ?? 0,
    kmImprodutivoSemHora: arredondarKm(improdutivo?.km ?? 0),
  };
}

// Percentual com 1 casa. Sem viagem programada não existe cumprimento: null, e não
// 0% (pareceria que nada foi feito) nem 100% (pareceria que tudo foi feito).
export function turno(programadas: number, realizadas: number) {
  return {
    programadas,
    realizadas,
    percentual: programadas ? Math.round((realizadas / programadas) * 1000) / 10 : null,
  };
}

export async function getCumprimento({ dataInicio, dataFim }: Periodo) {
  const [soma] = await FatorCumprimentoViagem.aggregate([
    { $match: { data: { $gte: dataInicio, $lte: dataFim } } },
    {
      $group: {
        _id: null,
        manhaProgr: { $sum: "$manhaProgr" },
        manhaRealiz: { $sum: "$manhaRealiz" },
        tardeProgr: { $sum: "$tardeProgr" },
        tardeRealiz: { $sum: "$tardeRealiz" },
        noiteProgr: { $sum: "$noiteProgr" },
        noiteRealiz: { $sum: "$noiteRealiz" },
        programadas: { $sum: "$programadas" },
        realizadas: { $sum: "$realizadas" },
        dias: { $sum: 1 },
      },
    },
  ]);

  // Período sem dado: o aggregate não devolve nada, e tudo vira zero (percentual null).
  const s = soma ?? {};

  return {
    manha: turno(s.manhaProgr ?? 0, s.manhaRealiz ?? 0),
    tarde: turno(s.tardeProgr ?? 0, s.tardeRealiz ?? 0),
    noite: turno(s.noiteProgr ?? 0, s.noiteRealiz ?? 0),
    total: turno(s.programadas ?? 0, s.realizadas ?? 0),
    dias: s.dias ?? 0,
  };
}
