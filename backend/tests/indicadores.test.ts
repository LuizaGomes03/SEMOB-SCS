import { describe, it, mock, afterEach } from "node:test";
import assert from "node:assert/strict";
import ResumoGeral from "../src/models/ResumoGeral";
import Passageiros from "../src/models/Passageiros";
import VendaUtilizacao from "../src/models/VendaUtilizacao";
import { getIndicadores, getIndicadoresComComparacao } from "../src/services/operacao.service";
import { periodoAnterior } from "../src/utils/datas";

// Os testes não usam o MongoDB: o aggregate de cada modelo é substituído por uma
// resposta fixa, e o que se verifica é o cálculo feito pelo serviço.
const simular = (operacao: object[], passageiros: object[], financeiro: object[]) => {
  mock.method(ResumoGeral, "aggregate", async () => operacao);
  mock.method(Passageiros, "aggregate", async () => passageiros);
  mock.method(VendaUtilizacao, "aggregate", async () => financeiro);
};

const setembro = { dataInicio: new Date("2026-09-01"), dataFim: new Date("2026-09-30") };

afterEach(() => mock.restoreAll());

describe("Cenário: Indicadores de um período", () => {
  it("devolve quilometragem, viagens, passageiros e créditos somados", async () => {
    simular(
      [{ quilometragem: 1234.56, viagens: 200, viagensProgramadas: 210, dias: 30 }],
      [{ pagantes: 5000, naoPagantes: 800, dias: 30 }],
      [{ vendas: 1500.126, utilizacao: 1400.5, dias: 30 }],
    );

    const r = await getIndicadores(setembro);

    assert.equal(r.quilometragem, 1234.6); // arredondada para 1 casa
    assert.equal(r.viagens, 200);
    assert.equal(r.viagensProgramadas, 210);
    assert.equal(r.passageirosPagantes, 5000);
    assert.equal(r.passageirosNaoPagantes, 800);
    assert.equal(r.creditosVendidos, 1500.13); // arredondado para 2 casas
    assert.equal(r.creditosUtilizados, 1400.5);
    assert.equal(r.diasOperacao, 30);
  });

  it("consulta o banco com o filtro do período pedido", async () => {
    simular([], [], []);
    await getIndicadores(setembro);

    const chamada = (ResumoGeral.aggregate as any).mock.calls[0];
    const filtro = chamada.arguments[0][0].$match;
    assert.deepEqual(filtro, { data: { $gte: setembro.dataInicio, $lte: setembro.dataFim } });
  });
});

describe("Cenário: Período sem dados", () => {
  it("retorna os valores zerados, sem erro", async () => {
    simular([], [], []);

    const r = await getIndicadores(setembro);

    assert.equal(r.quilometragem, 0);
    assert.equal(r.viagens, 0);
    assert.equal(r.passageirosPagantes, 0);
    assert.equal(r.passageirosNaoPagantes, 0);
    assert.equal(r.creditosVendidos, 0);
    assert.equal(r.creditosUtilizados, 0);
    assert.equal(r.diasOperacao, 0);
  });
});

describe("Cenário: Comparação com o mês anterior", () => {
  it("informa o período comparado (01/08 a 31/08) junto com os indicadores", async () => {
    simular(
      [{ quilometragem: 100, viagens: 10, viagensProgramadas: 10, dias: 30 }],
      [{ pagantes: 100, naoPagantes: 10, dias: 30 }],
      [{ vendas: 100, utilizacao: 100, dias: 30 }],
    );
    const anterior = periodoAnterior(setembro.dataInicio, setembro.dataFim, "mes_anterior");

    const r = await getIndicadoresComComparacao({ ...setembro, anterior, tipo: "mes_anterior" });

    assert.equal(r.comparacao.tipo, "mes_anterior");
    assert.equal(r.comparacao.dataInicio, "2026-08-01");
    assert.equal(r.comparacao.dataFim, "2026-08-31");
    assert.equal(r.viagens, 10);
  });
});
