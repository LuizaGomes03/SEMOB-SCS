import React, { useState, useMemo } from 'react';
import { Users, UserCheck, Percent, PieChart as PieIcon, ArrowUpDown } from 'lucide-react';
import KpiCard from '../../components/kpi/KpiCard';
import PassengersChart from '../../components/charts/PassengersChart';
import PassengersCategoryChart from '../../components/charts/PassengersCategoryChart';
import EmptyState from '../../components/common/EmptyState';
import { MOCK_PERIOD_KPIS, MOCK_OPERATIONS_TABLE } from '../../data/mockData';
import { useFilters } from '../../context/FilterContext';

export default function PassageirosPage() {
  const { period, isRefreshing } = useFilters();
  const currentKpis = MOCK_PERIOD_KPIS[period] || MOCK_PERIOD_KPIS.hoje;

  const totalPassageiros = currentKpis.pagantes.value + currentKpis.naoPagantes.value;
  const percentualPagantes = ((currentKpis.pagantes.value / totalPassageiros) * 100).toFixed(1);

  const [filterDate, setFilterDate] = useState('todas');

  const filteredRows = useMemo(() => {
    if (filterDate === 'todas') return MOCK_OPERATIONS_TABLE;
    return MOCK_OPERATIONS_TABLE.filter((r) => r.date === filterDate);
  }, [filterDate]);

  return (
    <div className="passageiros-page">
      {/* 4 KPIs Obrigatórios de Passageiros */}
      <div className="kpis-grid">
        <KpiCard
          title="Total de Passageiros"
          value={totalPassageiros}
          unit="passageiros"
          change={currentKpis.pagantes.change}
          trend={currentKpis.pagantes.trend}
          previousLabel={currentKpis.periodCompareLabel}
          tooltip="Somatória total de munícipes transportados no período (pagantes + gratuidades)."
          icon={<Users size={22} />}
          iconBg="#EBF3FA"
          iconColor="#005691"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Passageiros Pagantes"
          value={currentKpis.pagantes.value}
          unit="passageiros"
          change={currentKpis.pagantes.change}
          trend={currentKpis.pagantes.trend}
          previousLabel={currentKpis.periodCompareLabel}
          tooltip="Passageiros que efetuaram pagamento de tarifa municipal."
          icon={<Users size={22} />}
          iconBg="#ECFDF5"
          iconColor="#059669"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Não Pagantes (Gratuidades)"
          value={currentKpis.naoPagantes.value}
          unit="gratuidades"
          change={currentKpis.naoPagantes.change}
          trend={currentKpis.naoPagantes.trend}
          previousLabel={currentKpis.periodCompareLabel}
          tooltip="Beneficiários de gratuidades legais: Idosos 60+, Estudantes e PCD."
          icon={<UserCheck size={22} />}
          iconBg="#FFFBEB"
          iconColor="#D97706"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Percentual de Pagantes"
          value={`${percentualPagantes}%`}
          unit=""
          change={-0.3}
          trend="neutral"
          previousLabel="índice de arrecadação"
          tooltip="Proporção de passageiros que remuneram o sistema de transporte diretamente."
          icon={<Percent size={22} />}
          iconBg="#F3E8FF"
          iconColor="#7C3AED"
          isLoading={isRefreshing}
        />
      </div>

      {/* Gráficos de Passageiros */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(460px, 1fr))', gap: '1.5rem', marginBottom: '1.75rem' }}>
        <PassengersChart />
        <PassengersCategoryChart />
      </div>

      {/* Tabela de Passageiros por Linha e Dia */}
      <div className="card">
        <div className="card-header">
          <div className="card-title-group">
            <h2>Demonstrativo de Passageiros por Linha e Data</h2>
            <p>Relação diária de validações de bilhetagem e apuração de gratuidades</p>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <label htmlFor="select-date-filter" style={{ fontSize: '0.825rem', fontWeight: 600, color: 'var(--text-secondary)' }}>
              Data:
            </label>
            <select
              id="select-date-filter"
              value={filterDate}
              onChange={(e) => setFilterDate(e.target.value)}
              style={{
                padding: '0.5rem 0.85rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-default)',
                fontSize: '0.85rem'
              }}
            >
              <option value="todas">Todas as Datas</option>
              <option value="14/09/2026">Hoje (14/09/2026)</option>
              <option value="13/09/2026">13/09/2026</option>
              <option value="12/09/2026">12/09/2026</option>
              <option value="11/09/2026">11/09/2026</option>
            </select>
          </div>
        </div>

        <div className="data-table-container">
          <table className="data-table" aria-label="Tabela detalhada de passageiros por linha">
            <thead>
              <tr>
                <th>Data</th>
                <th>Linha Municipal</th>
                <th>Pass. Pagantes</th>
                <th>Não Pagantes (Gratuidades)</th>
                <th>Total Geral</th>
                <th style={{ minWidth: '180px' }}>Proporção Pagantes (%)</th>
              </tr>
            </thead>
            <tbody>
              {filteredRows.map((r) => (
                <tr key={r.id}>
                  <td style={{ fontWeight: 600 }}>{r.date}</td>
                  <td>
                    <span style={{ fontWeight: 700, color: 'var(--color-primary-navy)' }}>{r.lineName}</span>
                  </td>
                  <td style={{ color: 'var(--status-success-text)', fontWeight: 700 }}>
                    {r.pagantes.toLocaleString('pt-BR')}
                  </td>
                  <td style={{ color: 'var(--status-warning-text)', fontWeight: 700 }}>
                    {r.naoPagantes.toLocaleString('pt-BR')}
                  </td>
                  <td style={{ fontWeight: 800 }}>
                    {r.totalPassageiros.toLocaleString('pt-BR')}
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                      <div
                        style={{
                          flex: 1,
                          height: '8px',
                          backgroundColor: 'var(--status-warning-bg)',
                          borderRadius: 'var(--radius-full)',
                          overflow: 'hidden'
                        }}
                      >
                        <div
                          style={{
                            width: `${r.percentualPagantes}%`,
                            height: '100%',
                            backgroundColor: 'var(--color-primary-blue)',
                            borderRadius: 'var(--radius-full)'
                          }}
                        />
                      </div>
                      <span style={{ fontSize: '0.8rem', fontWeight: 700, width: '45px' }}>
                        {r.percentualPagantes}%
                      </span>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
