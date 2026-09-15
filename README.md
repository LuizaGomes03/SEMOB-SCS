# Dashboard de Operação de Transporte — SEMOB-SCS
## Secretaria de Mobilidade Urbana de São Caetano do Sul (SP)
### Projeto Integrador Interdisciplinar TTI206

---

## 🇧🇷 Português

### 1. Visão Geral do Sistema
O **Dashboard de Operação de Transporte — SEMOB-SCS** é uma plataforma front-end multiplataforma desenvolvida em **Dart e Flutter**, contemplando os requisitos definidos no Projeto Integrador Interdisciplinar TTI206 para a **Secretaria de Mobilidade Urbana de São Caetano do Sul (SEMOB-SCS)**.

O objetivo do sistema é substituir o antigo fluxo de relatórios estáticos enviados por e-mail por um painel analítico interativo, consolidado e veloz, facilitando a identificação de anomalias operacionais e a tomada de decisão pelos gestores públicos.

> **Aviso de Escopo:** O sistema é uma ferramenta estrita de gestão municipal (não é aplicativo de passageiro para compra de passagens ou rastreamento de linhas para usuários). Os dados apresentados são fictícios (mockados) e estruturados para futura integração com os dados brutos da consolidadora **Smart Data**.

---

### 2. Telas do Sistema
1. **Login Institucional**: Autenticação com e-mail institucional, banner oficial da Prefeitura e atalhos rápidos de demonstração acadêmica.
2. **Dashboard Principal**: 5 KPIs principais (Quilometragem, Viagens, Passageiros Pagantes, Não Pagantes e Informações Financeiras), gráfico interativo de evolução com alternância de métricas, gráfico comparativo de passageiros, resumo executivo e anomalias em destaque.
3. **Operação**: Análise aprofundada de odômetro e viagens por linha, busca textual, filtros avançados, ordenação de colunas e tabela responsiva.
4. **Passageiros**: Análise de bilhetagem e gratuidades regulamentadas (Idoso 60+, Estudante passe livre, PCD), gráfico donut de categorias e tabela comparativa.
5. **Informações Financeiras**: Apuração tarifária demonstrativa preliminar, com aviso explícito de preservação de escopo.
6. **Anomalias e Alertas**: Central de fiscalização com diagnóstico de parâmetros esperados vs. aferidos em campo, severidade (Crítico/Atenção) e fluxo de auditoria/resolução.
7. **Relatórios**: Abas Diário, Semanal e Mensal com modal de pré-visualização executiva timbrada oficial e exportação simulada em PDF e CSV.
8. **Detalhamento da Operação**: Visão granular de linha e escala diária com gráfico de picos por faixa horária e histórico de alertas vinculados.
9. **Perfil e Configurações**: Dados funcionais da coordenadora, preferências de visualização, controles de acessibilidade digital e encerramento de sessão.
10. **Central de Notificações**: Painel com abas (Todas, Alertas, Informações, Atualizações), contador de não lidas e marcação de leitura.
11. **Menu de Acessibilidade**: Controles de acessibilidade digital incluindo redimensionamento de fonte proporcional (A-, A, A+), modo de Alto Contraste (preto e amarelo) e foco visível aprimorado, seguindo boas práticas de acessibilidade.

---

### 3. Identidade Visual e Assets Oficiais
- **Cor Primária Institucional:** `#3D5D9A` (Sidebar, Header, botões, destaques)
- **Fundo da Aplicação:** `#F5F7FA`
- **Fundo dos Cards:** `#FFFFFF`
- **Texto Principal:** `#183B70`
- **Texto Secundário:** `#667085`
- **Assets Oficiais Utilizados:**
  - `assets/images/banner_semob.jpg`: Cabeçalho institucional oficial Prefeitura de São Caetano do Sul | Secretaria de Mobilidade Urbana.
  - `assets/images/logo_prefeitura.jpg`: Logotipo oficial da Prefeitura aplicado na área superior da sidebar com preservação estrita de proporções.

---

### 4. Responsividade Multiplataforma
O mesmo código Flutter é utilizado nas diferentes plataformas, com layouts adaptados para:
- **Web / Desktop (>= 1200px):** Sidebar fixa ou recolhível, grid expansivo de até 5 colunas de KPIs, gráficos em duas colunas e tabelas completas.
- **Tablet (768px – 1199px):** Sidebar recolhível, cards em 2 a 3 colunas e filtros em linha.
- **Mobile (320px – 767px):** Menu lateral gaveta (Drawer ☰), cards empilhados verticalmente, filtros em BottomSheet e ocorrências em cards expansíveis para evitar qualquer overflow horizontal.

---

### 5. Como Executar o Projeto

```bash
# Obter dependências do Flutter
flutter pub get

# Executar na Web
flutter run -d chrome

# Executar no Windows Desktop
flutter run -d windows
```

---

## 🇺🇸 English

### 1. System Overview
The **Transport Operation Dashboard — SEMOB-SCS** is an institutional, multiplatform front-end system built with **Flutter & Dart** for managers and transportation analysts at the Municipal Secretariat of Urban Mobility of São Caetano do Sul (São Paulo, Brazil).

The system replaces legacy static reports sent via email with an interactive and consolidated analytics dashboard that empowers municipal managers to monitor key performance indicators (KPIs), detect operational discrepancies, audit anomalies, and generate executive reports.

> **Scope Notice:** This system is an internal management and inspection console (not a citizen-facing passenger app). All presented data is realistic demonstration data (mocked) structured for future integration with the raw data from **Smart Data**.

---

### 2. Included Screens
1. **Institutional Login**: Corporate login with official city banner, credential validation, and quick demonstration profiles.
2. **Main Dashboard**: Top 5 operational KPIs (Mileage, Trips, Paying Passengers, Non-paying Beneficiaries, and Financial metrics), interactive multi-metric canvas chart, passenger comparison chart, operational executive summary, and highlight anomaly cards.
3. **Operations Screen**: Detailed mileage and trip compliance analysis per bus line, live text search, filtering, column sorting, and responsive tables.
4. **Passengers Screen**: Ticketing demand and statutory free fares breakdown (Seniors 60+, Students, People with Disabilities), category donut chart, and visual proportion bars.
5. **Financial Information**: Preliminary mock fare collection breakdown with clear scope compliance notices.
6. **Anomalies and Alerts**: Enforcement center with expected vs. actual telemetry discrepancy diagnostics, severity tags (Critical/Warning), and action modals.
7. **Reports**: Daily, Weekly, and Monthly tabs with official formatted executive preview dialog and simulated PDF/CSV export.
8. **Operation Drill-Down**: In-depth inspection of a specific day and line with hourly peak distribution charts and associated incident logs.
9. **Profile & Settings**: Manager identification, visual density preferences, digital accessibility controls, and sign out.
10. **Notification Center**: Drawer with category filters (All, Alerts, Info, Updates), unread badge counter, and batch actions.
11. **Accessibility Menu**: Digital accessibility controls including proportional font scaling (A-, A, A+), high-contrast mode (black and yellow), and enhanced visible focus, following digital accessibility best practices.

---

### 3. Visual Identity & Official Assets
- **Primary Institutional Color:** `#3D5D9A` (Sidebar, Header, primary buttons, active indicators)
- **Background Color:** `#F5F7FA`
- **Surface / Card Color:** `#FFFFFF`
- **Primary Typography Color:** `#183B70`
- **Secondary Typography Color:** `#667085`
- **Official Assets Used:**
  - `assets/images/banner_semob.jpg`: Official City Hall & Urban Mobility Secretariat header banner.
  - `assets/images/logo_prefeitura.jpg`: Official City Hall coat-of-arms logo rendered with original aspect ratio.

---

### 4. Multiplatform Responsiveness
The same Flutter codebase is used across different platforms, with layouts adapted for:
- **Web / Desktop (>= 1200px):** Fixed or collapsible sidebar, 5-column KPI grid, side-by-side charts, and full data tables.
- **Tablet (768px – 1199px):** Collapsible sidebar, 2-to-3 column cards, wrapped filter chips.
- **Mobile (320px – 767px):** Navigation Drawer ☰, single-column stacked cards, BottomSheet filters, and expandable cards for table rows to completely eliminate horizontal overflow.

---

### 5. Running the Project

```bash
# Fetch Flutter dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows
```

---

### 6. Conclusão da Validação

A aplicação do **Dashboard SEMOB-SCS** foi desenvolvida em **Dart e Flutter**, com suporte à construção multiplataforma e interface responsiva. A validação realizada contemplou diferentes dimensões de tela, incluindo:
- **Desktop (1440×900)**: Passou nos testes automatizados sem overflow.
- **Tablet (820×1180)**: Passou nos testes automatizados sem overflow.
- **Mobile (390×844)**: Passou nos testes automatizados sem overflow.

Além disso, a aplicação apresentou **zero erros na análise estática (`flutter analyze`)** e foi **compilada com sucesso para Web** por meio do comando `flutter build web`.

Dessa forma, a versão apresentada encontra-se funcional para fins de demonstração acadêmica, utilizando dados mockados e mantendo sua estrutura preparada para futura integração com os dados da Smart Data.

> **Síntese para Apresentação do PI:**  
> *“A aplicação foi desenvolvida em Dart e Flutter, com interface responsiva validada em desktop, tablet e mobile, análise estática sem erros e compilação Web concluída com sucesso, utilizando dados mockados preparados para futura integração com a Smart Data.”*

