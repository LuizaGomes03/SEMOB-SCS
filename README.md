# Dashboard de Operação de Transporte — SEMOB-SCS

## Secretaria de Mobilidade Urbana de São Caetano do Sul (SP)

### Projeto Integrador Interdisciplinar TTI206

---

## 🇧🇷 Português

### 1. Visão Geral do Sistema

O **Dashboard de Operação de Transporte — SEMOB-SCS** é uma plataforma front-end multiplataforma desenvolvida em **Dart e Flutter**, contemplando os requisitos definidos no Projeto Integrador Interdisciplinar TTI206 para a **Secretaria de Mobilidade Urbana de São Caetano do Sul (SEMOB-SCS)**.

O objetivo do sistema é substituir o fluxo de relatórios estáticos enviados por e-mail por um painel analítico interativo e consolidado, facilitando a visualização dos dados de operação, a identificação de anomalias e a tomada de decisão pelos gestores públicos.

> **Aviso de Escopo:** O sistema é uma ferramenta de gestão e fiscalização municipal, não sendo um aplicativo destinado a passageiros para compra de passagens ou rastreamento de linhas. Os dados apresentados são fictícios e utilizados exclusivamente para demonstração (dados mockados), estando estruturados para futura integração com os dados brutos da consolidadora **Smart Data**.

---

### 2. Telas do Sistema

1. **Login Institucional:** Autenticação com e-mail institucional, banner oficial da Prefeitura e atalhos rápidos para demonstração acadêmica.

2. **Dashboard Principal:** Cinco indicadores principais — Quilometragem, Viagens, Passageiros Pagantes, Passageiros Não Pagantes e Informações Financeiras —, além de gráfico interativo de evolução com alternância de métricas, gráfico comparativo de passageiros, resumo executivo e anomalias em destaque.

3. **Operação:** Análise de quilometragem e viagens por linha, busca textual, filtros avançados, ordenação de colunas e tabela responsiva.

4. **Passageiros:** Análise de bilhetagem e categorias de passageiros não pagantes utilizadas na demonstração, com gráfico de distribuição e tabela comparativa.

5. **Informações Financeiras:** Apuração tarifária demonstrativa preliminar, acompanhada de aviso explícito sobre o caráter mockado dos dados e a preservação do escopo acadêmico.

6. **Anomalias e Alertas:** Central de fiscalização com identificação de ocorrências operacionais, classificação por severidade (Crítico/Atenção) e fluxo de auditoria e resolução.

7. **Relatórios:** Abas Diário, Semanal e Mensal com modal de pré-visualização executiva e exportação simulada em PDF e CSV.

8. **Detalhamento da Operação:** Visão granular de uma linha e de sua operação diária, com gráfico de distribuição por faixa horária e histórico de alertas vinculados.

9. **Perfil e Configurações:** Dados funcionais da coordenadora, preferências de visualização, controles de acessibilidade digital e encerramento de sessão.

10. **Central de Notificações:** Painel com abas Todas, Alertas, Informações e Atualizações, contador de notificações não lidas e marcação de leitura.

11. **Menu de Acessibilidade:** Controles de acessibilidade digital, incluindo redimensionamento proporcional de fonte (A-, A, A+), modo de alto contraste e foco visível aprimorado, seguindo boas práticas de acessibilidade digital.

---

### 3. Identidade Visual e Assets Oficiais

- **Cor Primária Institucional:** `#3D5D9A` (sidebar, header, botões e destaques)
- **Fundo da Aplicação:** `#F5F7FA`
- **Fundo dos Cards:** `#FFFFFF`
- **Texto Principal:** `#183B70`
- **Texto Secundário:** `#667085`

**Assets Oficiais Utilizados:**

- `assets/images/banner_semob.jpg`: Banner institucional da Prefeitura de São Caetano do Sul e da Secretaria de Mobilidade Urbana.
- `assets/images/logo_prefeitura.jpg`: Logotipo oficial da Prefeitura utilizado na interface, preservando suas proporções originais.

---

### 4. Responsividade Multiplataforma

O mesmo código Flutter é utilizado nas diferentes plataformas, com layouts adaptados de acordo com o tamanho da tela:

- **Web / Desktop (>= 1200px):** Sidebar fixa ou recolhível, grid expansivo de indicadores, gráficos organizados em colunas e tabelas completas.

- **Tablet (768px – 1199px):** Sidebar recolhível, cards distribuídos em 2 a 3 colunas e filtros adaptados ao espaço disponível.

- **Mobile (320px – 767px):** Menu lateral em formato Drawer (☰), cards empilhados verticalmente, filtros organizados em BottomSheet e ocorrências apresentadas em cards expansíveis, evitando overflow horizontal.

---

### 5. Como Executar o Projeto

```bash
# Obter as dependências do Flutter
flutter pub get

# Executar na Web
flutter run -d chrome

# Executar no Windows Desktop
flutter run -d windows
