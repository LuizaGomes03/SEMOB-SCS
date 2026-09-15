import React from 'react';
import {
  ArrowLeft,
  Bus,
  Gauge,
  Users,
  DollarSign,
  AlertTriangle,
  Clock,
  MapPin,
  Calendar,
  CheckCircle2,
  ShieldCheck
} from 'lucide-react';
import Button from '../../components/common/Button';
import Badge from '../../components/common/Badge';
import KpiCard from '../../components/kpi/KpiCard';
import { Bar } from 'react-chartjs-2';
import { MOCK_OPERATIONS_TABLE, MOCK_ALERTS } from '../../data/mockData';

export default function DetalhesOperacaoPage({ detailItem, onBack }) {
  // Se nenhum item foi selecionado, usa o primeiro como padrão demonstrativo
  const row = detailItem || MOCK_OPERATIONS_TABLE[0];

  // Filtra alertas vinculados a essa linha
  const relatedAlerts = MOCK_ALERTS.filter(
    (a) => a.line.includes(row.lineCode) || a.line.includes(row.lineName.split('-')[1]?.trim() || '')
  );

  // Gráfico de viagens e passageiros por faixa horária
  const hourlyData = {
    labels: ['05h-07h (Pico)', '07h-09h (Pico)', '09h-12h', '12h-14h (Almoço)', '14h-17h', '17h-19h (Pico)', '19h-21h', '21h-23h'],
    datasets: [
      {
        label: 'Passageiros Transportados',
        data: [
          Math.round(row.totalPassageiros * 0.18),
          Math.round(row.totalPassageiros * 0.26),
          Math.round(row.totalPassageiros * 0.08),
          Math.round(row.totalPassageiros * 0.12),
          Math.round(row.totalPassageiros * 0.09),
          Math.round(row.totalPassageiros * 0.20),
          Math.round(row.totalPassageiros * 0.05),
          Math.round(row.totalPassageiros * 0.02)
        ],
        backgroundColor: '#005691',
        borderRadius: 4
      }
    ]
  };

  return (
    <div className="detalhes-operacao-page">
      {/* Botão de Retorno e Identificação */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem', flexWrap: 'wrap', gap: '1rem' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
          <Button
            variant="secondary"
            onClick={onBack}
            icon={<ArrowLeft size={16} />}
            title="Voltar para a listagem anterior"
          >
            Voltar ao contexto anterior
          </Button>

          <div>
            <h2 style={{ fontSize: '1.4rem', color: 'var(--color-primary-navy)' }}>
              Detalhamento da Operação: {row.lineName}
            </h2>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', fontSize: '0.825rem', color: 'var(--text-muted)' }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                <Calendar size={14} /> {row.date}
              </span>
              <span>•</span>
              <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                <Bus size={14} /> Frota alocada: {row.veiculosAtivos} ônibus
              </span>
            </div>
          </div>
        </div>

        <Badge variant={row.status === 'Regular' ? 'success' : row.status === 'Atenção' ? 'warning' : 'danger'}>
          Status: {row.status}
        </Badge>
      </div>

      {/* Grid de Métricas Consolidadas do Registro Selecionado */}
      <div className="kpis-grid">
        <div className="kpi-card">
          <span className="kpi-title">Quilometragem do Dia</span>
          <span className="kpi-value">{row.km.toLocaleString('pt-BR')} km</span>
          <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
            Programado: {row.kmProgramado.toLocaleString('pt-BR')} km ({row.km > row.kmProgramado ? `+${row.km - row.kmProgramado} km de desvio` : 'Dentro da meta'})
          </div>
        </div>

        <div className="kpi-card">
          <span className="kpi-title">Viagens Executadas</span>
          <span className="kpi-value">{row.viagens} / {row.viagensProgramadas}</span>
          <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
            Regularidade: {((row.viagens / row.viagensProgramadas) * 100).toFixed(1)}%
          </div>
        </div>

        <div className="kpi-card">
          <span className="kpi-title">Passageiros Pagantes</span>
          <span className="kpi-value">{row.pagantes.toLocaleString('pt-BR')}</span>
          <div style={{ fontSize: '0.75rem', color: 'var(--status-success-text)', marginTop: '0.25rem' }}>
            {row.percentualPagantes}% do total
          </div>
        </div>

        <div className="kpi-card">
          <span className="kpi-title">Gratuidades Registradas</span>
          <span className="kpi-value">{row.naoPagantes.toLocaleString('pt-BR')}</span>
          <div style={{ fontSize: '0.75rem', color: 'var(--status-warning-text)', marginTop: '0.25rem' }}>
            {(100 - row.percentualPagantes).toFixed(1)}% do total
          </div>
        </div>

        <div className="kpi-card">
          <span className="kpi-title">Receita Estimada (Mock)</span>
          <span className="kpi-value">R$ {row.financeiro.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</span>
          <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.25rem' }}>
            Base Smart Data demonstrativa
          </div>
        </div>
      </div>

      {/* Gráfico de Demanda por Faixa Horária */}
      <div className="card">
        <div className="card-header">
          <div className="card-title-group">
            <h2>Distribuição de Passageiros por Faixa Horária</h2>
            <p>Concentração de fluxo entre horários de pico matutino, entrepico e pico vespertino</p>
          </div>
        </div>
        <div className="card-body">
          <div style={{ height: '260px', width: '100%' }}>
            <Bar
              data={hourlyData}
              options={{
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                  y: { ticks: { callback: (v) => `${v.toLocaleString('pt-BR')} pass.` } }
                }
              }}
            />
          </div>
        </div>
      </div>

      {/* Alertas e Observações Operacionais Associadas */}
      <div className="card">
        <div className="card-header">
          <div className="card-title-group">
            <h2>Ocorrências e Alertas Vinculados a esta Linha</h2>
            <p>Intercorrências registradas pelo sistema de monitoramento na data selecionada</p>
          </div>
        </div>
        <div className="card-body">
          {relatedAlerts.length === 0 ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--status-success-text)' }}>
              <CheckCircle2 size={20} color="var(--status-success)" />
              <span style={{ fontSize: '0.9rem', fontWeight: 600 }}>
                Nenhuma irregularidade ou anomalia foi vinculada a este registro. Operação padrão.
              </span>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {relatedAlerts.map((alert) => (
                <div
                  key={alert.id}
                  style={{
                    padding: '1rem',
                    backgroundColor: alert.severity === 'Crítico' ? 'var(--status-danger-bg)' : 'var(--status-warning-bg)',
                    border: `1px solid ${alert.severity === 'Crítico' ? 'var(--status-danger-border)' : 'var(--status-warning-border)'}`,
                    borderRadius: 'var(--radius-md)'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.25rem' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <AlertTriangle size={18} color={alert.severity === 'Crítico' ? 'var(--status-danger)' : 'var(--status-warning)'} />
                      <strong style={{ fontSize: '0.9rem', color: 'var(--color-primary-navy)' }}>
                        {alert.title} ({alert.code})
                      </strong>
                    </div>
                    <Badge variant={alert.severity === 'Crítico' ? 'danger' : 'warning'}>
                      {alert.severity}
                    </Badge>
                  </div>
                  <p style={{ fontSize: '0.825rem', color: 'var(--text-secondary)', margin: '0.25rem 0' }}>
                    {alert.description}
                  </p>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                    Parâmetro esperado: {alert.expectedValue} | Registrado: {alert.actualValue}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
