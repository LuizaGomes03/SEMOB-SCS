/**
 * DADOS MOCKADOS INSTITUCIONAIS — SEMOB-SCS
 * Projeto Integrador Interdisciplinar TTI206
 * Secretaria de Mobilidade Urbana de São Caetano do Sul
 *
 * NOTA: Estes dados são fictícios e estruturados para demonstrar a interface
 * antes da integração com os dados brutos da consolidadora Smart Data.
 */

export const MOCK_LINES = [
  { id: 'todas', code: 'TODAS', name: 'Todas as Linhas Municipais' },
  { id: 'linha-01', code: '01', name: 'Linha 01 - Circular Glicério', fleet: 8, terminal: 'Terminal Rodoviário Nicolau Delic' },
  { id: 'linha-02', code: '02', name: 'Linha 02 - Fundação', fleet: 6, terminal: 'Estação CPTM São Caetano' },
  { id: 'linha-03', code: '03', name: 'Linha 03 - Barcelona', fleet: 6, terminal: 'Bairro Barcelona' },
  { id: 'linha-04', code: '04', name: 'Linha 04 - São José', fleet: 7, terminal: 'Bairro São José' },
  { id: 'linha-05', code: '05', name: 'Linha 05 - Santa Maria / ParkShopping', fleet: 9, terminal: 'Espaço Cerâmica' },
  { id: 'linha-06', code: '06', name: 'Linha 06 - Nova Gerty', fleet: 5, terminal: 'Bairro Nova Gerty' },
  { id: 'linha-07', code: '07', name: 'Linha 07 - Santa Paula', fleet: 6, terminal: 'Bairro Santa Paula' },
  { id: 'linha-08', code: '08', name: 'Linha 08 - Santo Antônio', fleet: 5, terminal: 'Bairro Santo Antônio' },
];

export const MOCK_PERIOD_KPIS = {
  hoje: {
    periodLabel: 'Hoje (14/09/2026)',
    periodCompareLabel: 'vs. mesmo dia na semana anterior',
    km: {
      value: 12450,
      unit: 'km',
      change: 2.4,
      trend: 'up',
      previous: 12160,
      tooltip: 'Quilometragem total aferida por odômetro/GPS dos veículos municipais no dia de hoje.'
    },
    viagens: {
      value: 1245,
      unit: 'viagens',
      change: -0.4,
      trend: 'down',
      previous: 1250,
      tooltip: 'Total de viagens municipais concluídas hoje nas 8 linhas em operação.'
    },
    pagantes: {
      value: 32450,
      unit: 'passageiros',
      change: -0.8,
      trend: 'down',
      previous: 32710,
      tooltip: 'Passageiros que validaram tarifa pública municipal (Cartão São Caetano / QR Code / Dinheiro).'
    },
    naoPagantes: {
      value: 8230,
      unit: 'gratuidades',
      change: 4.5,
      trend: 'up',
      previous: 7875,
      tooltip: 'Beneficiários de gratuidades legais: Idosos 60+, Estudantes com passe livre e PCD.'
    },
    financeiro: {
      value: 162250,
      unit: 'R$',
      change: 1.2,
      trend: 'up',
      previous: 160320,
      tooltip: 'Demonstrativo preliminar de apuração tarifária. Aguarda validação das fórmulas definitivas da SEMOB/Smart Data.'
    },
    taxaCumprimento: '99.6%',
    pontualidadeGeral: '96.2%',
    indiceGratuidade: '20.2%'
  },
  semana: {
    periodLabel: 'Esta Semana (07/09 a 14/09/2026)',
    periodCompareLabel: 'vs. 7 dias anteriores',
    km: {
      value: 86940,
      unit: 'km',
      change: 3.1,
      trend: 'up',
      previous: 84320,
      tooltip: 'Quilometragem total percorrida pela frota municipal nos últimos 7 dias.'
    },
    viagens: {
      value: 8640,
      unit: 'viagens',
      change: 1.8,
      trend: 'up',
      previous: 8490,
      tooltip: 'Total de viagens consolidadas no período semanal.'
    },
    pagantes: {
      value: 226150,
      unit: 'passageiros',
      change: 2.1,
      trend: 'up',
      previous: 221500,
      tooltip: 'Volume de passageiros pagantes na semana.'
    },
    naoPagantes: {
      value: 57410,
      unit: 'gratuidades',
      change: 5.2,
      trend: 'up',
      previous: 54570,
      tooltip: 'Gratuidades e benefícios concedidos no período semanal.'
    },
    financeiro: {
      value: 1130750,
      unit: 'R$',
      change: 2.1,
      trend: 'up',
      previous: 1107500,
      tooltip: 'Total financeiro consolidado semanal (demonstrativo).'
    },
    taxaCumprimento: '98.9%',
    pontualidadeGeral: '95.8%',
    indiceGratuidade: '20.2%'
  },
  mes: {
    periodLabel: 'Mês Atual (Setembro/2026 consolidado)',
    periodCompareLabel: 'vs. mês anterior (Agosto/2026)',
    km: {
      value: 368200,
      unit: 'km',
      change: 1.5,
      trend: 'up',
      previous: 362750,
      tooltip: 'Quilometragem acumulada no mês atual.'
    },
    viagens: {
      value: 36800,
      unit: 'viagens',
      change: 0.9,
      trend: 'up',
      previous: 36470,
      tooltip: 'Viagens realizadas no mês atual.'
    },
    pagantes: {
      value: 965200,
      unit: 'passageiros',
      change: 1.7,
      trend: 'up',
      previous: 949000,
      tooltip: 'Passageiros pagantes acumulados no mês.'
    },
    naoPagantes: {
      value: 244800,
      unit: 'gratuidades',
      change: 3.8,
      trend: 'up',
      previous: 235800,
      tooltip: 'Gratuidades acumuladas no mês.'
    },
    financeiro: {
      value: 4826000,
      unit: 'R$',
      change: 1.7,
      trend: 'up',
      previous: 4745000,
      tooltip: 'Receita tarifária acumulada no mês (demonstrativo).'
    },
    taxaCumprimento: '99.1%',
    pontualidadeGeral: '96.5%',
    indiceGratuidade: '20.2%'
  }
};

// Histórico para gráficos diários
export const MOCK_DAILY_HISTORY = [
  { date: '08/09', label: 'Segunda 08/09', km: 12210, viagens: 1238, pagantes: 31900, naoPagantes: 8010, financeiro: 159500 },
  { date: '09/09', label: 'Terça 09/09', km: 12380, viagens: 1242, pagantes: 32200, naoPagantes: 8120, financeiro: 161000 },
  { date: '10/09', label: 'Quarta 10/09', km: 12400, viagens: 1245, pagantes: 32350, naoPagantes: 8150, financeiro: 161750 },
  { date: '11/09', label: 'Quinta 11/09', km: 12510, viagens: 1250, pagantes: 32800, naoPagantes: 8300, financeiro: 164000 },
  { date: '12/09', label: 'Sexta 12/09', km: 12590, viagens: 1255, pagantes: 33100, naoPagantes: 8380, financeiro: 165500 },
  { date: '13/09', label: 'Sábado 13/09', km: 10400, viagens: 980, pagantes: 24200, naoPagantes: 6200, financeiro: 121000 },
  { date: '14/09', label: 'Hoje 14/09', km: 12450, viagens: 1245, pagantes: 32450, naoPagantes: 8230, financeiro: 162250 }
];

// Dados detalhados da operação por linha e dia
export const MOCK_OPERATIONS_TABLE = [
  {
    id: 'op-001',
    date: '14/09/2026',
    lineId: 'linha-01',
    lineCode: '01',
    lineName: 'Linha 01 - Circular Glicério',
    km: 1820,
    kmProgramado: 1780,
    viagens: 184,
    viagensProgramadas: 184,
    pagantes: 4890,
    naoPagantes: 1220,
    totalPassageiros: 6110,
    percentualPagantes: 80.0,
    financeiro: 24450,
    status: 'Atenção',
    statusDesc: 'Quilometragem +2.2% acima do plano por desvio operacional na Av. Goiás',
    veiculosAtivos: 8
  },
  {
    id: 'op-002',
    date: '14/09/2026',
    lineId: 'linha-02',
    lineCode: '02',
    lineName: 'Linha 02 - Fundação',
    km: 1450,
    kmProgramado: 1460,
    viagens: 142,
    viagensProgramadas: 144,
    pagantes: 3950,
    naoPagantes: 1140,
    totalPassageiros: 5090,
    percentualPagantes: 77.6,
    financeiro: 19750,
    status: 'Regular',
    statusDesc: 'Operação regular dentro de todos os parâmetros',
    veiculosAtivos: 6
  },
  {
    id: 'op-003',
    date: '14/09/2026',
    lineId: 'linha-03',
    lineCode: '03',
    lineName: 'Linha 03 - Barcelona',
    km: 1390,
    kmProgramado: 1400,
    viagens: 138,
    viagensProgramadas: 138,
    pagantes: 3820,
    naoPagantes: 950,
    totalPassageiros: 4770,
    percentualPagantes: 80.1,
    financeiro: 19100,
    status: 'Regular',
    statusDesc: 'Cumprimento de 100% dos horários programados',
    veiculosAtivos: 6
  },
  {
    id: 'op-004',
    date: '14/09/2026',
    lineId: 'linha-04',
    lineCode: '04',
    lineName: 'Linha 04 - São José',
    km: 1310,
    kmProgramado: 1480,
    viagens: 128,
    viagensProgramadas: 142,
    pagantes: 3410,
    naoPagantes: 890,
    totalPassageiros: 4300,
    percentualPagantes: 79.3,
    financeiro: 17050,
    status: 'Crítico',
    statusDesc: '14 viagens suprimidas devido à quebra de 2 veículos da operadora',
    veiculosAtivos: 5
  },
  {
    id: 'op-005',
    date: '14/09/2026',
    lineId: 'linha-05',
    lineCode: '05',
    lineName: 'Linha 05 - Santa Maria / ParkShopping',
    km: 2150,
    kmProgramado: 2120,
    viagens: 210,
    viagensProgramadas: 210,
    pagantes: 5940,
    naoPagantes: 1460,
    totalPassageiros: 7400,
    percentualPagantes: 80.3,
    financeiro: 29700,
    status: 'Regular',
    statusDesc: 'Alta demanda atendida com pontualidade',
    veiculosAtivos: 9
  },
  {
    id: 'op-006',
    date: '14/09/2026',
    lineId: 'linha-06',
    lineCode: '06',
    lineName: 'Linha 06 - Nova Gerty',
    km: 1220,
    kmProgramado: 1220,
    viagens: 122,
    viagensProgramadas: 122,
    pagantes: 3120,
    naoPagantes: 790,
    totalPassageiros: 3910,
    percentualPagantes: 79.8,
    financeiro: 15600,
    status: 'Regular',
    statusDesc: 'Operação estável',
    veiculosAtivos: 5
  },
  {
    id: 'op-007',
    date: '14/09/2026',
    lineId: 'linha-07',
    lineCode: '07',
    lineName: 'Linha 07 - Santa Paula',
    km: 1540,
    kmProgramado: 1540,
    viagens: 156,
    viagensProgramadas: 156,
    pagantes: 3980,
    naoPagantes: 980,
    totalPassageiros: 4960,
    percentualPagantes: 80.2,
    financeiro: 19900,
    status: 'Regular',
    statusDesc: 'Operação padrão',
    veiculosAtivos: 6
  },
  {
    id: 'op-008',
    date: '14/09/2026',
    lineId: 'linha-08',
    lineCode: '08',
    lineName: 'Linha 08 - Santo Antônio',
    km: 1570,
    kmProgramado: 1560,
    viagens: 165,
    viagensProgramadas: 165,
    pagantes: 3940,
    naoPagantes: 800,
    totalPassageiros: 4740,
    percentualPagantes: 83.1,
    financeiro: 19700,
    status: 'Regular',
    statusDesc: 'Cumprimento de 100% da grade',
    veiculosAtivos: 5
  },
  {
    id: 'op-009',
    date: '13/09/2026',
    lineId: 'linha-01',
    lineCode: '01',
    lineName: 'Linha 01 - Circular Glicério',
    km: 1520,
    kmProgramado: 1520,
    viagens: 148,
    viagensProgramadas: 148,
    pagantes: 3620,
    naoPagantes: 910,
    totalPassageiros: 4530,
    percentualPagantes: 79.9,
    financeiro: 18100,
    status: 'Regular',
    statusDesc: 'Operação de sábado sem intercorrências',
    veiculosAtivos: 6
  },
  {
    id: 'op-010',
    date: '13/09/2026',
    lineId: 'linha-05',
    lineCode: '05',
    lineName: 'Linha 05 - Santa Maria / ParkShopping',
    km: 1850,
    kmProgramado: 1850,
    viagens: 175,
    viagensProgramadas: 175,
    pagantes: 4980,
    naoPagantes: 1290,
    totalPassageiros: 6270,
    percentualPagantes: 79.4,
    financeiro: 24900,
    status: 'Regular',
    statusDesc: 'Movimento concentrado no ParkShopping São Caetano',
    veiculosAtivos: 8
  },
  {
    id: 'op-011',
    date: '12/09/2026',
    lineId: 'linha-04',
    lineCode: '04',
    lineName: 'Linha 04 - São José',
    km: 1460,
    kmProgramado: 1480,
    viagens: 140,
    viagensProgramadas: 142,
    pagantes: 3650,
    naoPagantes: 910,
    totalPassageiros: 4560,
    percentualPagantes: 80.0,
    financeiro: 18250,
    status: 'Atenção',
    statusDesc: 'Atraso na liberação de veículo no pico matutino',
    veiculosAtivos: 6
  },
  {
    id: 'op-012',
    date: '11/09/2026',
    lineId: 'linha-02',
    lineCode: '02',
    lineName: 'Linha 02 - Fundação',
    km: 1470,
    kmProgramado: 1460,
    viagens: 144,
    viagensProgramadas: 144,
    pagantes: 4020,
    naoPagantes: 1180,
    totalPassageiros: 5200,
    percentualPagantes: 77.3,
    financeiro: 20100,
    status: 'Regular',
    statusDesc: 'Operação sem falhas',
    veiculosAtivos: 6
  }
];

// Alertas e Anomalias Fictícias com foco em gestão
export const MOCK_ALERTS = [
  {
    id: 'alt-101',
    code: 'ALT-2026-089',
    type: 'Quilometragem',
    title: 'Variação incomum de quilometragem',
    description: 'Veículos da Linha 01 registraram 18.4% a mais de quilometragem aferida em relação ao trajeto homologado.',
    indicator: 'Quilometragem',
    line: 'Linha 01 - Circular Glicério',
    date: '14/09/2026 09:45',
    severity: 'Atenção',
    status: 'Em Análise',
    expectedValue: '1.780 km',
    actualValue: '1.820 km (+40 km)',
    impact: 'Consumo adicional de combustível e eventual desvio de itinerário não comunicado.',
    actionRequired: 'Solicitar justificativa operacional formal à empresa operadora.'
  },
  {
    id: 'alt-102',
    code: 'ALT-2026-090',
    type: 'Viagens Canceladas',
    title: 'Redução no número de viagens realizadas',
    description: '14 viagens planejadas da Linha 04 deixaram de ser executadas entre 06:30 e 08:30 no Terminal Urbano.',
    indicator: 'Viagens',
    line: 'Linha 04 - São José',
    date: '14/09/2026 08:30',
    severity: 'Crítico',
    status: 'Pendente',
    expectedValue: '142 viagens',
    actualValue: '128 viagens (-14 viagens)',
    impact: 'Superlotação nas paradas da Av. Tietê e aumento no tempo médio de espera dos munícipes.',
    actionRequired: 'Emitir auto de notificação operacional à operadora concessionária.'
  },
  {
    id: 'alt-103',
    code: 'ALT-2026-091',
    type: 'Gratuidades',
    title: 'Aumento expressivo de passageiros não pagantes',
    description: 'Crescimento atípico de 28% no registro de gratuidades na Linha 02 no trecho próximo à Estação SCS.',
    indicator: 'Passageiros Não Pagantes',
    line: 'Linha 02 - Fundação',
    date: '14/09/2026 11:15',
    severity: 'Atenção',
    status: 'Pendente',
    expectedValue: '850 gratuidades',
    actualValue: '1.140 gratuidades (+34%)',
    impact: 'Desequilíbrio na apuração da compensação financeira do município.',
    actionRequired: 'Auditar validações dos cartões do idoso e estudante via telemetria Smart Data.'
  },
  {
    id: 'alt-104',
    code: 'ALT-2026-088',
    type: 'Consolidação de Dados',
    title: 'Inconsistência momentânea de dados Smart Data',
    description: 'Intervalo sem envio de registros de GPS entre 07:15 e 07:35 nos prefixos 1042 e 1045.',
    indicator: 'Quilometragem / Viagens',
    line: 'Linha 05 - Santa Maria',
    date: '14/09/2026 07:40',
    severity: 'Crítico',
    status: 'Resolvido',
    expectedValue: 'Transmissão contínua a cada 30s',
    actualValue: 'Perda de sinal por 20 minutos',
    impact: 'Dados de telemetria incompletos para auditoria em tempo real.',
    actionRequired: 'Reenvio de lote de dados offline confirmado pela Smart Data.'
  },
  {
    id: 'alt-105',
    code: 'ALT-2026-085',
    type: 'Pontualidade',
    title: 'Atraso em comboio de partidas',
    description: 'Quatro viagens consecutivas saíram com atraso superior a 15 minutos do Terminal Nicolau Delic.',
    indicator: 'Viagens',
    line: 'Linha 07 - Santa Paula',
    date: '13/09/2026 17:50',
    severity: 'Atenção',
    status: 'Resolvido',
    expectedValue: 'Intervalo regular de 12 min',
    actualValue: 'Intervalo de 27 min',
    impact: 'Agrupamento de ônibus no corredor viário da Rua Goiás.',
    actionRequired: 'Operadora acionou veículo reserva para equalização de tabela.'
  }
];

// Dados das categorias de passageiros para gráficos
export const MOCK_PASSENGER_CATEGORIES = [
  { name: 'Pagante Comum / Cartão SCS', count: 17520, percent: 54.0, color: '#005691' },
  { name: 'Vale-Transporte Empregado', count: 14930, percent: 46.0, color: '#0284C7' },
  { name: 'Idoso 60+ (Gratuidade Municipal)', count: 4940, percent: 60.0, color: '#059669' },
  { name: 'Estudante Passe Livre', count: 2470, percent: 30.0, color: '#D97706' },
  { name: 'PCD e Acompanhantes', count: 820, percent: 10.0, color: '#7C3AED' }
];

// Central de Notificações
export const MOCK_NOTIFICATIONS = [
  {
    id: 'notif-1',
    category: 'Alertas',
    title: 'Alerta Crítico: Viagens Suprimidas',
    description: 'Linha 04 registrou 14 viagens não realizadas hoje no período matutino.',
    time: 'Há 25 minutos',
    read: false,
    severity: 'danger',
    link: '/anomalias'
  },
  {
    id: 'notif-2',
    category: 'Alertas',
    title: 'Quilometragem Acima do Padrão',
    description: 'Desvio operacional identificado na Linha 01 na Av. Goiás.',
    time: 'Há 1 hora',
    read: false,
    severity: 'warning',
    link: '/anomalias'
  },
  {
    id: 'notif-3',
    category: 'Informações',
    title: 'Consolidação Semanal Concluída',
    description: 'Os dados da semana 36/2026 foram consolidados no sistema.',
    time: 'Hoje às 06:00',
    read: false,
    severity: 'info',
    link: '/relatorios'
  },
  {
    id: 'notif-4',
    category: 'Atualizações',
    title: 'Sincronização Smart Data',
    description: 'Lote de telemetria das 07h reprocessado com sucesso.',
    time: 'Ontem às 19:30',
    read: true,
    severity: 'success',
    link: '/operacao'
  }
];

// Tabela Financeira Operacional Fictícia
export const MOCK_FINANCIAL_TABLE = [
  {
    id: 'fin-01',
    periodo: 'Hoje (14/09/2026)',
    descricao: 'Arrecadação Tarifária Diária Consolidada',
    valor: 162250.00,
    comparacao: '+1.2%',
    status: 'Em Consolidação',
    tipo: 'Receita Tarifária',
    observacao: 'Base provisória Smart Data (Tarifa R$ 5,00)'
  },
  {
    id: 'fin-02',
    periodo: 'Semana 37 (07 a 13/09)',
    descricao: 'Fechamento Operacional Semanal',
    valor: 1130750.00,
    comparacao: '+2.1%',
    status: 'Consolidado',
    tipo: 'Receita Tarifária',
    observacao: 'Homologado pela diretoria de transportes'
  },
  {
    id: 'fin-03',
    periodo: 'Agosto/2026',
    descricao: 'Subsídio / Compensação Municipal de Gratuidades',
    valor: 1224000.00,
    comparacao: '+3.4%',
    status: 'Consolidado',
    tipo: 'Compensação Gratuidade',
    observacao: 'Conforme Lei Municipal de Acessibilidade e Transporte'
  },
  {
    id: 'fin-04',
    periodo: 'Julho/2026',
    descricao: 'Compensação Municipal de Gratuidades',
    valor: 1184000.00,
    comparacao: '-0.5%',
    status: 'Auditado',
    tipo: 'Compensação Gratuidade',
    observacao: 'Prestação de contas aprovada pelo conselho'
  },
  {
    id: 'fin-05',
    periodo: 'Agosto/2026',
    descricao: 'Receita Tarifária Bruta - Mês Fechado',
    valor: 4745000.00,
    comparacao: '+1.5%',
    status: 'Auditado',
    tipo: 'Receita Tarifária',
    observacao: 'Fechamento final auditado pela SEMOB'
  }
];

// Perfil do Gestor Padrão
export const CURRENT_USER = {
  name: 'Dra. Luiza Gomes',
  email: 'luiza.gomes@semob.saocaetanodosul.sp.gov.br',
  role: 'Coordenadora de Monitoramento e Planejamento Operacional',
  department: 'SEMOB-SCS / Diretoria de Transportes Públicos',
  initials: 'LG',
  accessLevel: 'Gestor Geral (Acesso Total)'
};
