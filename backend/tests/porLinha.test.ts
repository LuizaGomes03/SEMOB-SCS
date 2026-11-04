import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { montarPorLinha } from "../src/services/operacao.service";

// Só a parte que não depende do MongoDB: juntar a lista de linhas do banco inteiro
// com o que os aggregates do período devolveriam.

describe("Cenário: Linhas sem nada no período", () => {
  it("devolve a linha que não rodou, com tudo zero", () => {
    const { linhas } = montarPorLinha(["06", "11"], [{ _id: "06", quilometragem: 100, viagens: 10, dias: 1 }], []);
    assert.deepEqual(linhas[1], {
      linha: "11",
      quilometragem: 0,
      viagens: 0,
      naoCumpridas: 0,
      programadas: 0,
      dias: 0,
    });
  });

  it("com o período vazio, todas as linhas vêm zeradas e os totais também", () => {
    const { linhas, totais } = montarPorLinha(["01", "02"], [], []);
    assert.equal(linhas.length, 2);
    assert.deepEqual(totais, { quilometragem: 0, viagens: 0, naoCumpridas: 0, programadas: 0 });
  });

  it("sem nenhuma linha no banco, devolve lista vazia e totais zero", () => {
    const { linhas, totais } = montarPorLinha([], [], []);
    assert.deepEqual(linhas, []);
    assert.deepEqual(totais, { quilometragem: 0, viagens: 0, naoCumpridas: 0, programadas: 0 });
  });
});

describe("Cenário: Programadas", () => {
  it("soma as viagens feitas com as não cumpridas", () => {
    const { linhas } = montarPorLinha(
      ["06"],
      [{ _id: "06", quilometragem: 100, viagens: 10, dias: 2 }],
      [{ _id: "06", total: 2 }],
    );
    assert.equal(linhas[0].viagens, 10);
    assert.equal(linhas[0].naoCumpridas, 2);
    assert.equal(linhas[0].programadas, 12);
    assert.equal(linhas[0].dias, 2);
  });

  it("linha com programadas e nenhuma viagem feita: viagens 0, programadas N", () => {
    const { linhas } = montarPorLinha(["03"], [], [{ _id: "03", total: 4 }]);
    assert.equal(linhas[0].viagens, 0);
    assert.equal(linhas[0].programadas, 4);
    assert.equal(linhas[0].dias, 0);
  });
});

describe("Cenário: Linha fora da lista", () => {
  it("inclui a linha que só aparece nas não cumpridas", () => {
    const { linhas } = montarPorLinha(["01"], [], [{ _id: "09", total: 1 }]);
    assert.deepEqual(linhas.map((l) => l.linha), ["01", "09"]);
    assert.equal(linhas[1].programadas, 1);
  });

  it("não repete a linha que aparece nas três fontes", () => {
    const { linhas } = montarPorLinha(
      ["01"],
      [{ _id: "01", quilometragem: 1, viagens: 1, dias: 1 }],
      [{ _id: "01", total: 1 }],
    );
    assert.equal(linhas.length, 1);
  });
});

describe("Cenário: Ordem", () => {
  it("ordena pelo código, com 10 e 11 depois de 09", () => {
    const { linhas } = montarPorLinha(["11", "02", "10", "01", "09"], [], []);
    assert.deepEqual(linhas.map((l) => l.linha), ["01", "02", "09", "10", "11"]);
  });
});

describe("Cenário: Totais", () => {
  it("soma as linhas e não inclui dias", () => {
    const { totais } = montarPorLinha(
      ["01", "02"],
      [
        { _id: "01", quilometragem: 100, viagens: 10, dias: 3 },
        { _id: "02", quilometragem: 50, viagens: 5, dias: 3 },
      ],
      [{ _id: "02", total: 2 }],
    );
    assert.deepEqual(totais, { quilometragem: 150, viagens: 15, naoCumpridas: 2, programadas: 17 });
  });

  it("arredonda a quilometragem a 1 casa, por linha e no total", () => {
    const { linhas, totais } = montarPorLinha(
      ["01", "02"],
      [
        { _id: "01", quilometragem: 0.1 + 0.2, viagens: 0, dias: 1 },
        { _id: "02", quilometragem: 10.26, viagens: 0, dias: 1 },
      ],
      [],
    );
    assert.equal(linhas[0].quilometragem, 0.3);
    assert.equal(linhas[1].quilometragem, 10.3);
    assert.equal(totais.quilometragem, 10.6);
  });

  it("o total vem da soma sem arredondar, não da soma dos arredondados", () => {
    const { totais } = montarPorLinha(
      ["01", "02"],
      [
        { _id: "01", quilometragem: 0.04, viagens: 0, dias: 1 },
        { _id: "02", quilometragem: 0.04, viagens: 0, dias: 1 },
      ],
      [],
    );
    assert.equal(totais.quilometragem, 0.1);
  });
});
