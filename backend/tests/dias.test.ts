import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { lerDias, filtroPeriodo, classificarDia, tiposDia, TipoDia } from "../src/utils/dias";
import { feriados } from "../src/dados/feriados";
import { ErroHttp } from "../src/utils/datas";

// Simula a requisição do Express: só a query string importa para lerDias.
const req = (query: Record<string, unknown>) => ({ query }) as any;
const d = (texto: string) => new Date(texto);

function erroDe(fn: () => unknown): ErroHttp {
  try {
    fn();
  } catch (e) {
    assert.ok(e instanceof ErroHttp, "deveria lançar ErroHttp");
    return e;
  }
  assert.fail("deveria ter lançado erro");
}

// Aplica o filtro do Mongo a um documento { data } sem banco. Entende só os operadores
// que filtroPeriodo usa; qualquer outro lança erro, para o teste não passar por engano
// se o filtro mudar e este avaliador ficar para trás.
function casa(filtro: Record<string, any>, data: Date): boolean {
  return Object.entries(filtro).every(([chave, valor]) => {
    if (chave === "$or") return (valor as object[]).some((f) => casa(f, data));
    if (chave === "$expr") return expr(valor);
    if (chave === "data") {
      return Object.entries(valor).every(([op, v]: [string, any]) => {
        if (op === "$gte") return data >= v;
        if (op === "$lte") return data <= v;
        if (op === "$in") return v.some((x: Date) => x.getTime() === data.getTime());
        if (op === "$nin") return !v.some((x: Date) => x.getTime() === data.getTime());
        throw new Error(`operador não simulado: ${op}`);
      });
    }
    throw new Error(`chave não simulada: ${chave}`);
  });

  function expr(e: any): any {
    if (e?.$dayOfWeek === "$data") return data.getUTCDay() + 1; // sem timezone = UTC
    if (e?.$in) return expr(e.$in[1]).includes(expr(e.$in[0]));
    if (Array.isArray(e) || typeof e === "number") return e;
    throw new Error(`expressão não simulada: ${JSON.stringify(e)}`);
  }
}

// Os tipos em que o filtro do Mongo coloca o dia, um filtro por tipo.
const tiposPeloFiltro = (data: Date) =>
  tiposDia.filter((t) => casa(filtroPeriodo(d("2026-01-01"), d("2026-12-31"), t), data));

describe("Cenário: Valor de dias inválido", () => {
  it("responde 400 listando os valores aceitos", () => {
    const erro = erroDe(() => lerDias(req({ dias: "feriado" })));
    assert.equal(erro.status, 400);
    assert.match(erro.message, /util, sexta, sabado, domingo_feriado/);
  });

  it("rejeita o parâmetro repetido (?dias=util&dias=sabado)", () => {
    const erro = erroDe(() => lerDias(req({ dias: ["util", "sabado"] })));
    assert.equal(erro.status, 400);
  });

  it("aceita os quatro valores", () => {
    for (const t of tiposDia) assert.equal(lerDias(req({ dias: t })), t);
  });

  it("sem dias, ou com ?dias= vazio, não filtra", () => {
    assert.equal(lerDias(req({})), undefined);
    assert.equal(lerDias(req({ dias: "" })), undefined);
  });
});

describe("Cenário: Consulta sem filtro de dias", () => {
  it("devolve exatamente o filtro de período de antes", () => {
    const inicio = d("2026-07-01");
    const fim = d("2026-09-14");
    assert.deepEqual(filtroPeriodo(inicio, fim), { data: { $gte: inicio, $lte: fim } });
    assert.deepEqual(filtroPeriodo(inicio, fim, undefined), { data: { $gte: inicio, $lte: fim } });
  });
});

describe("Cenário: Filtro de dias mantém o período", () => {
  it("todo tipo de dia continua limitado a dataInicio e dataFim", () => {
    const inicio = d("2026-09-07");
    const fim = d("2026-09-13");
    for (const t of tiposDia) {
      const filtro = filtroPeriodo(inicio, fim, t);
      assert.equal(casa(filtro, d("2026-09-06")), false, `${t} pegou o dia antes do período`);
      assert.equal(casa(filtro, d("2026-09-14")), false, `${t} pegou o dia depois do período`);
    }
  });
});

// Dias conhecidos e os tipos em que cada um tem que cair.
const conhecidos: [string, string, TipoDia[]][] = [
  ["2026-09-14", "segunda", ["util"]],
  ["2026-09-11", "sexta", ["util", "sexta"]],
  ["2026-09-12", "sábado", ["sabado"]],
  ["2026-09-13", "domingo", ["domingo_feriado"]],
  ["2026-09-07", "segunda, feriado da Independência", ["domingo_feriado"]],
  ["2026-07-09", "quinta, feriado estadual", ["domingo_feriado"]],
];

describe("Cenário: Classificação de dias conhecidos", () => {
  for (const [data, descricao, esperado] of conhecidos) {
    it(`${data.split("-").reverse().slice(0, 2).join("/")} (${descricao}) → ${esperado.join(" e ")}`, () => {
      assert.deepEqual(classificarDia(d(data)), esperado, "função pura");
      assert.deepEqual(tiposPeloFiltro(d(data)), esperado, "filtro do Mongo");
    });
  }

  it("07/09 é segunda, mas por ser feriado NÃO entra em util", () => {
    assert.equal(classificarDia(d("2026-09-07")).includes("util"), false);
    assert.equal(casa(filtroPeriodo(d("2026-09-01"), d("2026-09-30"), "util"), d("2026-09-07")), false);
  });
});

describe("Cenário: Função pura e filtro do Mongo concordam no ano inteiro", () => {
  // Todos os dias de 2026, meia-noite UTC como o campo "data".
  const dias2026 = Array.from({ length: 365 }, (_, i) => new Date(Date.UTC(2026, 0, 1 + i)));

  it("os dois dão o mesmo resultado em todos os dias de 2026", () => {
    for (const dia of dias2026) {
      assert.deepEqual(tiposPeloFiltro(dia), classificarDia(dia), dia.toISOString().slice(0, 10));
    }
  });

  it("cada dia cai em exatamente um entre util, sabado e domingo_feriado", () => {
    for (const dia of dias2026) {
      const principais = classificarDia(dia).filter((t) => t !== "sexta");
      assert.equal(principais.length, 1, dia.toISOString().slice(0, 10));
    }
  });

  it("toda sexta do filtro também é dia útil", () => {
    for (const dia of dias2026) {
      const tipos = classificarDia(dia);
      if (tipos.includes("sexta")) assert.ok(tipos.includes("util"), dia.toISOString().slice(0, 10));
    }
  });

  it("domingo_feriado tem os 52 domingos mais os feriados que não caem em domingo", () => {
    const domingoFeriado = dias2026.filter((dia) => classificarDia(dia).includes("domingo_feriado"));
    // Feriado num domingo já foi contado como domingo: não pode contar duas vezes.
    const feriadosEmDomingo = feriados.filter((f) => d(f.data).getUTCDay() === 0).length;
    assert.equal(domingoFeriado.length, 52 + feriados.length - feriadosEmDomingo);
  });
});

describe("Cenário: Lista de feriados", () => {
  it("está em ordem de data, sem datas repetidas", () => {
    const datas = feriados.map((f) => f.data);
    assert.deepEqual(datas, [...datas].sort());
    assert.equal(new Set(datas).size, datas.length);
  });

  it("toda data existe e está no formato AAAA-MM-DD", () => {
    for (const f of feriados) {
      assert.match(f.data, /^\d{4}-\d{2}-\d{2}$/);
      assert.equal(d(f.data).toISOString().slice(0, 10), f.data);
    }
  });

  it("traz o tipo de cada feriado", () => {
    assert.deepEqual(feriados.find((f) => f.data === "2026-07-09"), {
      data: "2026-07-09",
      nome: "Revolução Constitucionalista",
      tipo: "estadual",
    });
    assert.equal(feriados.find((f) => f.data === "2026-07-28")?.tipo, "municipal");
    assert.equal(feriados.find((f) => f.data === "2026-09-07")?.tipo, "nacional");
  });
});
