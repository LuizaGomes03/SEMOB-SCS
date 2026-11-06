import { Request } from "express";
import { ErroHttp } from "./datas";
import { datasFeriados } from "../dados/feriados";

// Filtro opcional ?dias=... das rotas de período: mostra só um tipo de dia.
// - util: segunda a sexta, exceto feriados
// - sexta: sexta-feira, exceto feriados (um recorte de util)
// - sabado: sábado, exceto feriados
// - domingo_feriado: todo domingo e todo feriado, mesmo em dia de semana
// Cada dia do calendário cai em exatamente um entre util, sabado e domingo_feriado.
export const tiposDia = ["util", "sexta", "sabado", "domingo_feriado"] as const;
export type TipoDia = (typeof tiposDia)[number];

// Dia da semana na numeração do $dayOfWeek do MongoDB: 1 = domingo ... 7 = sábado.
const DOMINGO = 1;
const SEXTA = 6;
const SABADO = 7;

// A regra de cada tipo, num lugar só. O filtro do Mongo e a função classificarDia
// são montados a partir desta tabela, então não têm como discordar sobre o que é um
// dia útil. "feriados" diz o que fazer com um feriado: tirar do tipo ou incluir nele.
const regras: Record<TipoDia, { diasSemana: number[]; feriados: "excluir" | "incluir" }> = {
  util: { diasSemana: [2, 3, 4, 5, SEXTA], feriados: "excluir" },
  sexta: { diasSemana: [SEXTA], feriados: "excluir" },
  sabado: { diasSemana: [SABADO], feriados: "excluir" },
  domingo_feriado: { diasSemana: [DOMINGO], feriados: "incluir" },
};

// Lê ?dias= da query. Ausente ou vazio ("?dias=") vira undefined, sem filtro, pelo mesmo
// motivo do ?linha= vazio. Repetido (?dias=util&dias=sabado) o Express entrega uma lista,
// e ela também cai no 400: o filtro aceita um tipo de dia só.
export function lerDias(req: Request): TipoDia | undefined {
  const valor = req.query.dias;
  if (valor === undefined || valor === "") return undefined;

  if (typeof valor !== "string" || !tiposDia.includes(valor as TipoDia)) {
    throw new ErroHttp(400, `Dias inválido. Use um de: ${tiposDia.join(", ")}`);
  }

  return valor as TipoDia;
}

// O filtro de data de todas as consultas de período. Sem dias, é exatamente o filtro
// de antes: { data: { $gte, $lte } }.
//
// O dia da semana sai do $dayOfWeek SEM timezone, ou seja, em UTC. Isso é de propósito:
// "data" é meia-noite UTC e representa só o dia (14/09 é 2026-09-14T00:00Z). Calcular
// com o fuso de São Paulo voltaria 3h e jogaria cada data no dia anterior: segunda às
// 00:00Z viraria domingo às 21:00 e entraria como domingo_feriado.
//
// Os feriados são comparados por data exata ($in / $nin), o que só funciona porque
// "data" e datasFeriados são os dois meia-noite UTC.
export function filtroPeriodo(dataInicio: Date, dataFim: Date, dias?: TipoDia) {
  if (!dias) return { data: { $gte: dataInicio, $lte: dataFim } };

  const { diasSemana, feriados } = regras[dias];
  const naSemana = { $expr: { $in: [{ $dayOfWeek: "$data" }, diasSemana] } };

  if (feriados === "excluir") {
    // O $nin fica dentro de "data", junto com o intervalo: o índice por data continua
    // sendo usado para o período, e o resto é conferido só nos documentos dele.
    return { data: { $gte: dataInicio, $lte: dataFim, $nin: [...datasFeriados] }, ...naSemana };
  }

  return {
    data: { $gte: dataInicio, $lte: dataFim },
    $or: [{ data: { $in: [...datasFeriados] } }, naSemana],
  };
}

// A mesma classificação em TypeScript puro, para um dia só. Serve para testar a regra
// sem banco e para conferir o filtro do Mongo dia a dia.
// getUTCDay() conta de 0 = domingo a 6 = sábado; +1 deixa na numeração do $dayOfWeek.
// É UTC pelo mesmo motivo do filtro.
export function classificarDia(data: Date): TipoDia[] {
  const diaSemana = data.getUTCDay() + 1;
  const ehFeriado = datasFeriados.some((f) => f.getTime() === data.getTime());

  return tiposDia.filter((tipo) => {
    const regra = regras[tipo];
    return ehFeriado ? regra.feriados === "incluir" : regra.diasSemana.includes(diaSemana);
  });
}
