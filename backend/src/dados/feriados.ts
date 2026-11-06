// Lista montada pelo grupo, a mesma de frontend/lib/core/utils/feriados.dart.
// A lista oficial ainda é uma pergunta para a SEMOB.
//
// Pontos facultativos (Carnaval, Corpus Christi) ficam de fora porque não se sabe
// se a operação muda nesses dias.
//
// Só tem 2026: para outros anos, acrescente as datas aqui e no frontend.

export type TipoFeriado = "nacional" | "estadual" | "municipal";

export interface Feriado {
  // AAAA-MM-DD, o mesmo formato que as rotas recebem em dataInicio e dataFim.
  data: string;
  nome: string;
  tipo: TipoFeriado;
}

// Agrupada por tipo, como no frontend, para ficar fácil conferir uma com a outra.
const lista: Feriado[] = [
  // Nacionais
  { data: "2026-01-01", nome: "Confraternização Universal", tipo: "nacional" },
  { data: "2026-04-03", nome: "Sexta-feira Santa", tipo: "nacional" },
  { data: "2026-04-21", nome: "Tiradentes", tipo: "nacional" },
  { data: "2026-05-01", nome: "Dia do Trabalho", tipo: "nacional" },
  { data: "2026-09-07", nome: "Independência", tipo: "nacional" },
  { data: "2026-10-12", nome: "Nossa Senhora Aparecida", tipo: "nacional" },
  { data: "2026-11-02", nome: "Finados", tipo: "nacional" },
  { data: "2026-11-15", nome: "Proclamação da República", tipo: "nacional" },
  { data: "2026-11-20", nome: "Consciência Negra", tipo: "nacional" },
  { data: "2026-12-25", nome: "Natal", tipo: "nacional" },
  // Estadual (SP)
  { data: "2026-07-09", nome: "Revolução Constitucionalista", tipo: "estadual" },
  // Municipal (São Caetano do Sul)
  { data: "2026-07-28", nome: "Aniversário da cidade", tipo: "municipal" },
];

// Em ordem de data. Comparar o texto AAAA-MM-DD já ordena certo: ano, mês e dia têm
// tamanho fixo, então a ordem alfabética é a ordem do calendário.
export const feriados: readonly Feriado[] = [...lista].sort((a, b) => a.data.localeCompare(b.data));

// As mesmas datas como Date de meia-noite UTC, igual ao campo "data" das collections.
// new Date("AAAA-MM-DD") lê o texto em UTC, então não há risco de cair no dia anterior.
export const datasFeriados: readonly Date[] = feriados.map((f) => new Date(f.data));
