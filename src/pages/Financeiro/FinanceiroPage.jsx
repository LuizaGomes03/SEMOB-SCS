import React from 'react';
import { DollarSign, TrendingUp, AlertCircle, Clock, FileText, CheckCircle2 } from 'lucide-react';
import KpiCard from '../../components/kpi/KpiCard';
import FinancialEvolutionChart from '../../components/charts/FinancialEvolutionChart';
import Badge from '../../components/common/Badge';
import { MOCK_FINANCIAL_TABLE, MOCK_PERIOD_KPIS } from '../../data/mockData';
import { useFilters } from '../../context/FilterContext';

export default function FinanceiroPage() {
  const { period, isRefreshing } = useFilters();
  const currentKpis = MOCK_PERIOD_KPIS[period] || MOCK_PERIOD_KPIS.hoje;

  return (
    <div className="financeiro-page">
      {/* Banner Institucional de Advertência de Escopo */}
      <div
        style={{
          backgroundColor: 'var(--status-warning-bg)',
          border: '1px solid var(--status-warning-border)',
          borderRadius: 'var(--radius-lg)',
          padding: '1rem 1.25rem',
          marginBottom: '1.5rem',
          display: 'flex',
          alignItems: 'flex-start',
          gap: '0.85rem'
        }}
      >
        <AlertCircle size={22} color="var(--status-warning)" style={{ flexShrink: 0, marginTop: '2px' }} />
        <div>
          <h3 style={{ fontSize: '0.925rem', fontWeight: 700, color: 'var(--status-warning-text)', marginBottom: '0.25rem' }}>
            Indicadores Financeiros em Definição (Dados Demonstrativos)
          </h3>
          <p style={{ fontSize: '0.825rem', color: 'var(--status-warning-text)', margin: 0, lineHeight: 1.45 }}>
            Conforme especificado no documento do Projeto Integrador TTI206, as fórmulas e os indicadores financeiros oficiais ainda serão homologados pela SEMOB-SCS em conjunto com a consolidadora Smart Data. A estrutura desta tela é flexível e modular, pronta para receber os campos definitivos.
          </p>
        </div>
      </div>

      {/* Cards Financeiros Indicativos */}
      <div className="kpis-grid">
        <KpiCard
          title="Valor Consolidado (Demonstrativo)"
          value={currentKpis.financeiro.value}
          unit="R$"
          change={currentKpis.financeiro.change}
          trend={currentKpis.financeiro.trend}
          previousLabel={currentKpis.periodCompareLabel}
          tooltip="Métrica genérica preliminar para visualização da receita tarifária operacional."
          icon={<DollarSign size={22} />}
          iconBg="#EBF3FA"
          iconColor="#005691"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Arrecadação Tarifária Estimada"
          value={Math.round(currentKpis.financeiro.value * 0.88)}
          unit="R$"
          change={1.4}
          trend="up"
          previousLabel="vs. período anterior"
          tooltip="Receita proveniente de tarifas pagas diretamente pelos usuários."
          icon={<DollarSign size={22} />}
          iconBg="#ECFDF5"
          iconColor="#059669"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Compensação Estimada de Gratuidades"
          value={Math.round(currentKpis.financeiro.value * 0.12)}
          unit="R$"
          change={3.2}
          trend="up"
          previousLabel="vs. período anterior"
          tooltip="Estimativa de compensação municipal devida pela cobertura de gratuidades legais."
          icon={<DollarSign size={22} />}
          iconBg="#FFFBEB"
          iconColor="#D97706"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Tarifa Média Base"
          value="5,00"
          unit="R$/pass."
          change={0.0}
          trend="neutral"
          previousLabel="conforme decreto municipal"
          tooltip="Valor de referência da tarifa pública do transporte coletivo em São Caetano do Sul."
          icon={<DollarSign size={22} />}
          iconBg="#F3E8FF"
          iconColor="#7C3AED"
          isLoading={isRefreshing}
        />
      </div>

      {/* Gráfico Financeiro */}
      <section aria-label="Evolução Financeira">
        <FinancialEvolutionChart />
      </section>

      {/* Tabela Financeira Demonstrativa */}
      <div className="card">
        <div className="card-header">
          <div className="card-title-group">
            <h2>Demonstrativo Consolidado de Lançamentos</h2>
            <p>Registro histórico das apurações financeiras operacionais</p>
          </div>
          <Badge variant="neutral" icon={<Clock size={12} />}>
            Auditoria Contínua
          </Badge>
        </div>

        <div className="data-table-container">
          <table className="data-table" aria-label="Tabela de informações financeiras">
            <thead>
              <tr>
                <th>Período de Referência</th>
                <th>Descrição do Lançamento Operacional</th>
                <th>Categoria</th>
                <th>Valor Consolidado (R$)</th>
                <th>Variação</th>
                <th>Status da Apuração</th>
                <th>Observação Técnica</th>
              </tr>
            </thead>
            <tbody>
              {MOCK_FINANCIAL_TABLE.map((item) => {
                const statusVariant =
                  item.status === 'Auditado'
                    ? 'success'
                    : item.status === 'Consolidado'
                    ? 'info'
                    : 'warning';

                return (
                  <tr key={item.id}>
                    <td style={{ fontWeight: 700 }}>{item.periodo}</td>
                    <td style={{ fontWeight: 600, color: 'var(--color-primary-navy)' }}>
                      {item.descricao}
                    </td>
                    <td>
                      <Badge variant="neutral">{item.tipo}</Badge>
                    </td>
                    <td style={{ fontWeight: 800, fontSize: '0.95rem', color: 'var(--color-primary-navy)' }}>
                      R$ {item.valor.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                    </td>
                    <td>
                      <span
                        style={{
                          fontWeight: 700,
                          color: item.comparacao.startsWith('+') ? 'var(--status-success-text)' : 'var(--status-danger-text)'
                        }}
                      >
                        {item.comparacao}
                      </span>
                    </td>
                    <td>
                      <Badge variant={statusVariant}>{item.status}</Badge>
                    </td>
                    <td style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                      {item.observacao}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
