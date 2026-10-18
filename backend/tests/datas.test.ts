import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { parseDatas, periodoAnterior, ErroHttp } from "../src/utils/datas";

// Simula a requisição do Express: só a query string importa para parseDatas.
const req = (query: Record<string, string>) => ({ query }) as any;
const dia = (data: Date) => data.toISOString().slice(0, 10);
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

describe("Cenário: Consulta com datas válidas", () => {
  it("lê dataInicio e dataFim no formato AAAA-MM-DD", () => {
    const { dataInicio, dataFim } = parseDatas(req({ dataInicio: "2026-09-01", dataFim: "2026-09-30" }));
    assert.equal(dia(dataInicio), "2026-09-01");
    assert.equal(dia(dataFim), "2026-09-30");
  });

  it("sem parâmetros, o período é do início dos tempos até hoje", () => {
    const { dataInicio, dataFim } = parseDatas(req({}));
    assert.equal(dataInicio.getTime(), 0);
    assert.ok(Math.abs(dataFim.getTime() - Date.now()) < 5000);
  });
});

describe("Cenário: Data em formato inválido", () => {
  it("responde 400 informando o formato AAAA-MM-DD", () => {
    const erro = erroDe(() => parseDatas(req({ dataInicio: "2026-9-14" })));
    assert.equal(erro.status, 400);
    assert.match(erro.message, /AAAA-MM-DD/);
  });

  it("rejeita texto que não é data", () => {
    const erro = erroDe(() => parseDatas(req({ dataFim: "ontem" })));
    assert.equal(erro.status, 400);
  });
});

describe("Cenário: Data inexistente", () => {
  it("responde 400 informando que a data não é válida (31 de fevereiro)", () => {
    const erro = erroDe(() => parseDatas(req({ dataFim: "2026-02-31" })));
    assert.equal(erro.status, 400);
    assert.match(erro.message, /não é uma data válida/);
  });

  it("rejeita o mês 13", () => {
    const erro = erroDe(() => parseDatas(req({ dataInicio: "2026-13-01" })));
    assert.equal(erro.status, 400);
  });
});

describe("Cenário: Período invertido", () => {
  it("responde 400 quando dataInicio é posterior a dataFim", () => {
    const erro = erroDe(() => parseDatas(req({ dataInicio: "2026-09-10", dataFim: "2026-09-01" })));
    assert.equal(erro.status, 400);
  });

  it("aceita início e fim no mesmo dia", () => {
    assert.doesNotThrow(() => parseDatas(req({ dataInicio: "2026-09-10", dataFim: "2026-09-10" })));
  });
});

describe("Cenário: Comparação com o período anterior", () => {
  it("anterior: 07 a 13/09 é comparado com 31/08 a 06/09", () => {
    const r = periodoAnterior(d("2026-09-07"), d("2026-09-13"), "anterior");
    assert.equal(dia(r.dataInicio), "2026-08-31");
    assert.equal(dia(r.dataFim), "2026-09-06");
  });

  it("anterior: um único dia é comparado com o dia anterior", () => {
    const r = periodoAnterior(d("2026-09-14"), d("2026-09-14"), "anterior");
    assert.equal(dia(r.dataInicio), "2026-09-13");
    assert.equal(dia(r.dataFim), "2026-09-13");
  });

  it("semana_anterior: as mesmas datas, 7 dias antes", () => {
    const r = periodoAnterior(d("2026-09-01"), d("2026-09-03"), "semana_anterior");
    assert.equal(dia(r.dataInicio), "2026-08-25");
    assert.equal(dia(r.dataFim), "2026-08-27");
  });
});

describe("Cenário: Comparação com o mês anterior", () => {
  it("mês inteiro (01 a 30/09) é comparado com o mês inteiro (01 a 31/08)", () => {
    const r = periodoAnterior(d("2026-09-01"), d("2026-09-30"), "mes_anterior");
    assert.equal(dia(r.dataInicio), "2026-08-01");
    assert.equal(dia(r.dataFim), "2026-08-31");
  });

  it("dia 31 sem equivalente no mês anterior usa o último dia dele (31/10 vira 30/09)", () => {
    const r = periodoAnterior(d("2026-10-31"), d("2026-10-31"), "mes_anterior");
    assert.equal(dia(r.dataInicio), "2026-09-30");
    assert.equal(dia(r.dataFim), "2026-09-30");
  });

  it("virada de ano: janeiro compara com dezembro do ano anterior", () => {
    const r = periodoAnterior(d("2026-01-01"), d("2026-01-31"), "mes_anterior");
    assert.equal(dia(r.dataInicio), "2025-12-01");
    assert.equal(dia(r.dataFim), "2025-12-31");
  });
});
