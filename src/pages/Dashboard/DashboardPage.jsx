import React from 'react';
import {
  Gauge,
  Bus,
  Users,
  UserCheck,
  DollarSign,
  AlertTriangle,
  CheckCircle2,
  TrendingUp,
  Clock,
  ArrowRight,
  ShieldAlert,
  Info
} from 'lucide-react';
import KpiCard from '../../components/kpi/KpiCard';
import OperationEvolutionChart from '../../components/charts/OperationEvolutionChart';
import PassengersChart from '../../components/charts/PassengersChart';
import Badge from '../../components/common/Badge';
import Button from '../../components/common/Button';
import { useFilters } from '../../context/FilterContext';
import { MOCK_PERIOD_KPIS, MOCK_ALERTS } from '../../data/mockData';

export default function DashboardPage({ onNavigate }) {
  const { period, isRefreshing } = useFilters();

  const currentKpis = MOCK_PERIOD_KPIS[period] || MOCK_PERIOD_KPIS.hoje;

  return (
    <div className="dashboard-page">
      {/* Banner Institucional Informativo */}
      <div
        style={{
          backgroundColor: 'var(--color-blue-light)',
          border: '1px solid var(--status-info-border)',
          borderRadius: 'var(--radius-lg)',
          padding: '0.85rem 1.25rem',
          marginBottom: '1.5rem',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: '0.75rem'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <div
            style={{
              backgroundColor: 'var(--color-primary-blue)',
              color: '#FFFFFF',
              borderRadius: 'var(--radius-md)',
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
          >
            <Info size={18} />
          </div>
          <div>
            <span style={{ fontSize: '0.85rem', fontWeight: 700, color: 'var(--color-primary-navy)' }}>
              Ambiente de Demonstração — Projeto Integrador TTI206 (SEMOB-SCS)
            </span>
            <p style={{ fontSize: '0.775rem', color: 'var(--text-secondary)', margin: 0 }}>
              Os dados consolidados abaixo são fictícios e demonstram a estrutura preparada para integração com a base bruta da Smart Data.
            </p>
          </div>
        </div>
        <Badge variant="info" icon={<Clock size={13} />}>
          Base atualizada hoje às 20:30
        </Badge>
      </div>

      {/* Os 5 KPIs Principais Obrigatórios */}
      <section aria-label="Indicadores Principais de Desempenho">
        <div className="kpis-grid">
          {/* 1. Quilometragem */}
          <KpiCard
            title="Quilometragem"
            value={currentKpis.km.value}
            unit={currentKpis.km.unit}
            change={currentKpis.km.change}
            trend={currentKpis.km.trend}
            previousLabel={currentKpis.periodCompareLabel}
            tooltip={currentKpis.km.tooltip}
            icon={<Gauge size={22} />}
            iconBg="#EBF3FA"
            iconColor="#005691"
            isLoading={isRefreshing}
            onClick={() => onNavigate('/operacao')}
          />

          {/* 2. Viagens */}
          <KpiCard
            title="Viagens Realizadas"
            value={currentKpis.viagens.value}
            unit={currentKpis.viagens.unit}
            change={currentKpis.viagens.change}
            trend={currentKpis.viagens.trend}
            previousLabel={currentKpis.periodCompareLabel}
            tooltip={currentKpis.viagens.tooltip}
            icon={<Bus size={22} />}
            iconBg="#E0F2FE"
            iconColor="#0284C7"
            isLoading={isRefreshing}
            onClick={() => onNavigate('/operacao')}
          />

          {/* 3. Passageiros Pagantes */}
          <KpiCard
            title="Passageiros Pagantes"
            value={currentKpis.pagantes.value}
            unit={currentKpis.pagantes.unit}
            change={currentKpis.pagantes.change}
            trend={currentKpis.pagantes.trend}
            previousLabel={currentKpis.periodCompareLabel}
            tooltip={currentKpis.pagantes.tooltip}
            icon={<Users size={22} />}
            iconBg="#ECFDF5"
            iconColor="#059669"
            isLoading={isRefreshing}
            onClick={() => onNavigate('/passageiros')}
          />

          {/* 4. Passageiros Não Pagantes */}
          <KpiCard
            title="Passageiros Não Pagantes"
            value={currentKpis.naoPagantes.value}
            unit={currentKpis.naoPagantes.unit}
            change={currentKpis.naoPagantes.change}
            trend={currentKpis.naoPagantes.trend}
            previousLabel={currentKpis.periodCompareLabel}
            tooltip={currentKpis.naoPagantes.tooltip}
            icon={<UserCheck size={22} />}
            iconBg="#FFFBEB"
            iconColor="#D97706"
            isLoading={isRefreshing}
            onClick={() => onNavigate('/passageiros')}
          />

          {/* 5. Informações Financeiras */}
          <KpiCard
            title="Financeiro (Demonstrativo)"
            value={currentKpis.financeiro.value}
            unit={currentKpis.financeiro.unit}
            change={currentKpis.financeiro.change}
            trend={currentKpis.financeiro.trend}
            previousLabel={currentKpis.periodCompareLabel}
            tooltip={currentKpis.financeiro.tooltip}
            icon={<DollarSign size={22} />}
            iconBg="#F3E8FF"
            iconColor="#7C3AED"
            isLoading={isRefreshing}
            onClick={() => onNavigate('/financeiro')}
          />
        </div>
      </section>

      {/* Gráfico de Evolução da Operação */}
      <section aria-label="Evolução da Operação">
        <OperationEvolutionChart />
      </section>

      {/* Seção com Gráfico de Passageiros e Resumo da Operação lado a lado */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(460px, 1fr))',
          gap: '1.5rem',
          marginBottom: '1.75rem'
        }}
      >
        {/* Gráfico de Passageiros: Pagantes, Não Pagantes e Total */}
        <PassengersChart />

        {/* Resumo da Operação */}
        <div className="card" style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
          <div className="card-header">
            <div className="card-title-group">
              <h2>Resumo da Operação</h2>
              <p>Síntese executiva dos parâmetros de regularidade e cobertura</p>
            </div>
          </div>
          <div className="card-body" style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between', gap: '1.25rem' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase' }}>
                  Cumprimento de Viagens
                </span>
                <div style={{ fontSize: '1.6rem', fontWeight: 800, color: 'var(--status-success-text)', marginTop: '0.25rem' }}>
                  {currentKpis.taxaCumprimento}
                </div>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                  Meta SEMOB: &gt; 98.0%
                </span>
              </div>

              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase' }}>
                  Índice de Gratuidades
                </span>
                <div style={{ fontSize: '1.6rem', fontWeight: 800, color: 'var(--color-primary-blue)', marginTop: '0.25rem' }}>
                  {currentKpis.indiceGratuidade}
                </div>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                  Idosos, estudantes e PCD
                </span>
              </div>

              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase' }}>
                  Pontualidade Média
                </span>
                <div style={{ fontSize: '1.6rem', fontWeight: 800, color: 'var(--color-primary-navy)', marginTop: '0.25rem' }}>
                  {currentKpis.pontualidadeGeral}
                </div>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                  Tolerância ± 5 minutos
                </span>
              </div>

              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase' }}>
                  Linhas em Fiscalização
                </span>
                <div style={{ fontSize: '1.6rem', fontWeight: 800, color: 'var(--color-primary-navy)', marginTop: '0.25rem' }}>
                  8 linhas
                </div>
                <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                  100% da rede municipal
                </span>
              </div>
            </div>

            <div
              style={{
                backgroundColor: 'var(--bg-surface-subtle)',
                padding: '0.85rem 1rem',
                borderRadius: 'var(--radius-md)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <CheckCircle2 size={18} color="var(--status-success)" />
                <span style={{ fontSize: '0.825rem', color: 'var(--text-primary)', fontWeight: 600 }}>
                  Operação global classificada em nível Regular
                </span>
              </div>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => onNavigate('/relatorios')}
                iconRight={<ArrowRight size={14} />}
              >
                Gerar Relatório
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Seção: Alertas e Anomalias em Destaque */}
      <section aria-label="Alertas e Anomalias">
        <div className="card">
          <div className="card-header">
            <div className="card-title-group">
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <AlertTriangle size={20} color="var(--status-danger)" />
                <h2>Alertas e Anomalias da Operação</h2>
                <Badge variant="danger">3 Ocorrências Ativas</Badge>
              </div>
              <p>Desvios e comportamentos atípicos identificados na base de telemetria</p>
            </div>

            <Button
              variant="outline-primary"
              size="sm"
              onClick={() => onNavigate('/anomalias')}
              iconRight={<ArrowRight size={14} />}
            >
              Ver Central Completa de Alertas
            </Button>
          </div>

          <div className="card-body">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1rem' }}>
              {MOCK_ALERTS.slice(0, 3).map((alert) => {
                const isCritical = alert.severity === 'Crítico';
                return (
                  <div
                    key={alert.id}
                    style={{
                      border: `1px solid ${isCritical ? 'var(--status-danger-border)' : 'var(--status-warning-border)'}`,
                      borderRadius: 'var(--radius-lg)',
                      padding: '1.25rem',
                      backgroundColor: isCritical ? 'var(--status-danger-bg)' : 'var(--status-warning-bg)',
                      display: 'flex',
                      flexDirection: 'column',
                      justifyContent: 'space-between',
                      gap: '0.75rem'
                    }}
                  >
                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                        <Badge variant={isCritical ? 'danger' : 'warning'}>
                          {alert.severity}
                        </Badge>
                        <span style={{ fontSize: '0.725rem', color: 'var(--text-muted)' }}>
                          {alert.date}
                        </span>
                      </div>

                      <h3 style={{ fontSize: '0.95rem', fontWeight: 700, color: 'var(--color-primary-navy)', marginBottom: '0.35rem' }}>
                        {alert.title}
                      </h3>
                      <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>
                        {alert.description}
                      </p>

                      <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                        <strong>Linha:</strong> {alert.line}
                      </div>
                    </div>

                    <div
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        paddingTop: '0.75rem',
                        borderTop: '1px solid rgba(0,0,0,0.06)'
                      }}
                    >
                      <span style={{ fontSize: '0.725rem', color: 'var(--text-secondary)', fontStyle: 'italic' }}>
                        Dados demonstrativos (Mock)
                      </span>
                      <button
                        type="button"
                        onClick={() => onNavigate('/anomalias')}
                        style={{
                          background: 'none',
                          border: 'none',
                          color: 'var(--color-primary-blue)',
                          fontSize: '0.8rem',
                          fontWeight: 700,
                          cursor: 'pointer',
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '0.25rem'
                        }}
                      >
                        Auditar <ArrowRight size={13} />
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
