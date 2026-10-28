import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { montarHoras, turno } from "../src/services/porHora.service";

// Só as partes que não dependem do MongoDB: montar o eixo de 24 horas a partir do
// que o aggregate devolveria e calcular o percentual de cumprimento.

describe("Cenário: Eixo de 24 horas", () => {
  it("devolve as 24 horas, de 0 a 23, mesmo sem nenhuma viagem", () => {
    const horas = montarHoras([], []);
    assert.equal(horas.length, 24);
    assert.deepEqual(horas.map((h) => h.hora), Array.from({ length: 24 }, (_, i) => i));
    assert.deepEqual(horas[0], {
      hora: 0,
      viagens: 0,
      quilometragem: 0,
      falhas: { nao_realizada: 0, nao_iniciada: 0, nao_terminada: 0 },
    });
  });

  it("coloca cada hora agregada na sua posição e deixa as outras zeradas", () => {
    const horas = montarHoras(
      [
        { _id: 5, viagens: 40, quilometragem: 512.34 },
        { _id: 23, viagens: 3, quilometragem: 30 },
      ],
      [],
    );
    assert.equal(horas[5].viagens, 40);
    assert.equal(horas[23].viagens, 3);
    assert.equal(horas[4].viagens, 0);
    assert.equal(horas[6].viagens, 0);
  });

  it("arredonda a quilometragem a 1 casa", () => {
    const horas = montarHoras([{ _id: 7, viagens: 1, quilometragem: 10.26 }], []);
    assert.equal(horas[7].quilometragem, 10.3);
  });

  it("separa as falhas por tipo dentro da hora", () => {
    const horas = montarHoras(
      [],
      [
        { _id: { tipo: "nao_realizada", hora: 22 }, total: 2 },
        { _id: { tipo: "nao_terminada", hora: 22 }, total: 1 },
        { _id: { tipo: "nao_iniciada", hora: 6 }, total: 4 },
      ],
    );
    assert.deepEqual(horas[22].falhas, { nao_realizada: 2, nao_iniciada: 0, nao_terminada: 1 });
    assert.deepEqual(horas[6].falhas, { nao_realizada: 0, nao_iniciada: 4, nao_terminada: 0 });
  });

  it("não deixa uma hora compartilhar o objeto de falhas com outra", () => {
    const horas = montarHoras([], [{ _id: { tipo: "nao_realizada", hora: 1 }, total: 5 }]);
    assert.equal(horas[2].falhas.nao_realizada, 0);
  });
});

describe("Cenário: Percentual de cumprimento", () => {
  it("calcula com 1 casa decimal", () => {
    assert.deepEqual(turno(3, 2), { programadas: 3, realizadas: 2, percentual: 66.7 });
  });

  it("100% quando tudo foi realizado", () => {
    assert.equal(turno(532, 532).percentual, 100);
  });

  it("null quando não há viagem programada (nem 0, nem 100)", () => {
    assert.equal(turno(0, 0).percentual, null);
  });
});
