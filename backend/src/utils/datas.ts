import { Request } from "express";

// Erro com status HTTP. Lançado de qualquer lugar, o errorHandler responde com esse status.
export class ErroHttp extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

// Só aceita AAAA-MM-DD. Fora desse formato o JavaScript lê a data no fuso local
// ("2026-9-14" vira 14/09 às 03:00 UTC) e o filtro perde parte do dia sem avisar.
const FORMATO_DATA = /^\d{4}-\d{2}-\d{2}$/;

function lerData(valor: unknown, nome: string) {
  if (typeof valor !== "string" || !FORMATO_DATA.test(valor)) {
    throw new ErroHttp(400, `${nome} deve estar no formato AAAA-MM-DD`);
  }

  const data = new Date(valor);
  // "2026-02-31" passa no formato, mas o JavaScript transforma em 03/03. Se a data
  // convertida não volta igual ao texto, o dia não existe.
  if (isNaN(data.getTime()) || data.toISOString().slice(0, 10) !== valor) {
    throw new ErroHttp(400, `${nome} não é uma data válida: ${valor}`);
  }

  return data;
}

// Lê dataInicio e dataFim da query string. Sem os parâmetros, o período é "tudo até hoje".
export function parseDatas(req: Request) {
  const dataInicio = req.query.dataInicio !== undefined ? lerData(req.query.dataInicio, "dataInicio") : new Date(0);
  const dataFim = req.query.dataFim !== undefined ? lerData(req.query.dataFim, "dataFim") : new Date();

  if (dataInicio > dataFim) {
    throw new ErroHttp(400, "dataInicio não pode ser depois de dataFim");
  }

  return { dataInicio, dataFim };
}

export const tiposComparacao = ["anterior", "semana_anterior", "mes_anterior"] as const;
export type TipoComparacao = (typeof tiposComparacao)[number];

const UM_DIA = 24 * 60 * 60 * 1000;

const somarDias = (data: Date, dias: number) => new Date(data.getTime() + dias * UM_DIA);

// Último dia do mês de uma data (dia 0 do mês seguinte é o último dia deste).
const ultimoDiaDoMes = (ano: number, mes: number) => new Date(Date.UTC(ano, mes + 1, 0)).getUTCDate();

// Volta a data um mês. Se o dia não existe no mês anterior (31/10 → 31/09), usa o último dia dele.
function voltarUmMes(data: Date) {
  const ano = data.getUTCFullYear();
  const mes = data.getUTCMonth() - 1;
  const dia = Math.min(data.getUTCDate(), ultimoDiaDoMes(ano, mes));
  return new Date(Date.UTC(ano, mes, dia));
}

// Calcula o período com que o período pedido vai ser comparado.
// - anterior: o mesmo número de dias, logo antes (07–13/09 → 31/08–06/09).
// - semana_anterior: as mesmas datas, 7 dias antes. Para um dia só, compara segunda com segunda.
// - mes_anterior: as mesmas datas, um mês antes. Mês inteiro compara com mês inteiro.
export function periodoAnterior(dataInicio: Date, dataFim: Date, tipo: TipoComparacao) {
  if (tipo === "semana_anterior") {
    return { dataInicio: somarDias(dataInicio, -7), dataFim: somarDias(dataFim, -7) };
  }

  if (tipo === "mes_anterior") {
    const inicio = voltarUmMes(dataInicio);
    let fim = voltarUmMes(dataFim);
    // Se o período vai até o fim do mês, o anterior também vai (30/09 → 31/08, e não 30/08).
    const fimDoMes = dataFim.getUTCDate() === ultimoDiaDoMes(dataFim.getUTCFullYear(), dataFim.getUTCMonth());
    if (fimDoMes) {
      fim = new Date(Date.UTC(fim.getUTCFullYear(), fim.getUTCMonth(), ultimoDiaDoMes(fim.getUTCFullYear(), fim.getUTCMonth())));
    }
    return { dataInicio: inicio, dataFim: fim };
  }

  // As datas são inclusivas: 07/09 a 13/09 tem 7 dias, não 6.
  const dias = Math.round((dataFim.getTime() - dataInicio.getTime()) / UM_DIA) + 1;
  const fim = somarDias(dataInicio, -1);
  return { dataInicio: somarDias(fim, -(dias - 1)), dataFim: fim };
}