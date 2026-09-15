import React, { useState } from 'react';
import './chartSetup';
import { Line } from 'react-chartjs-2';
import { MOCK_DAILY_HISTORY } from '../../data/mockData';

export default function OperationEvolutionChart() {
  const [activeMetric, setActiveMetric] = useState('km');

  const metricsConfig = {
    km: {
      label: 'Quilometragem (km)',
      unit: 'km',
      color: '#005691',
      bgColor: 'rgba(0, 86, 145, 0.12)',
      getValue: (d) => d.km
    },
    viagens: {
      label: 'Viagens Realizadas',
      unit: 'viagens',
      color: '#0284C7',
      bgColor: 'rgba(2, 132, 199, 0.12)',
      getValue: (d) => d.viagens
    },
    pagantes: {
      label: 'Passageiros Pagantes',
      unit: 'pass.',
      color: '#059669',
      bgColor: 'rgba(5, 150, 105, 0.12)',
      getValue: (d) => d.pagantes
    },
    naoPagantes: {
      label: 'Passageiros Não Pagantes',
      unit: 'grat.',
      color: '#D97706',
      bgColor: 'rgba(217, 119, 6, 0.12)',
      getValue: (d) => d.naoPagantes
    }
  };

  const currentConfig = metricsConfig[activeMetric];

  const chartData = {
    labels: MOCK_DAILY_HISTORY.map((item) => item.label),
    datasets: [
      {
        label: currentConfig.label,
        data: MOCK_DAILY_HISTORY.map(currentConfig.getValue),
        borderColor: currentConfig.color,
        backgroundColor: currentConfig.bgColor,
        fill: true,
        tension: 0.35,
        pointBackgroundColor: currentConfig.color,
        pointBorderColor: '#FFFFFF',
        pointBorderWidth: 2,
        pointRadius: 5,
        pointHoverRadius: 7
      }
    ]
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false
      },
      tooltip: {
        backgroundColor: '#0B192C',
        titleFont: { size: 13, family: 'Inter', weight: 'bold' },
        bodyFont: { size: 12, family: 'Inter' },
        padding: 10,
        boxPadding: 6,
        usePointStyle: true,
        callbacks: {
          label: (context) => {
            const val = context.raw.toLocaleString('pt-BR');
            return ` ${currentConfig.label}: ${val} ${currentConfig.unit}`;
          }
        }
      }
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: { font: { size: 11, family: 'Inter' }, color: '#64748B' }
      },
      y: {
        grid: { color: '#E2E8F0', strokeDasharray: [3, 3] },
        ticks: {
          font: { size: 11, family: 'Inter' },
          color: '#64748B',
          callback: (value) => value.toLocaleString('pt-BR')
        }
      }
    }
  };

  return (
    <div className="card">
      <div className="card-header">
        <div className="card-title-group">
          <h2>Evolução da Operação Municipal</h2>
          <p>Acompanhamento diário dos principais indicadores de tráfego</p>
        </div>

        {/* Alternador de Métricas */}
        <div
          style={{
            display: 'flex',
            gap: '4px',
            backgroundColor: 'var(--bg-surface-subtle)',
            padding: '3px',
            borderRadius: 'var(--radius-md)',
            border: '1px solid var(--border-subtle)',
            flexWrap: 'wrap'
          }}
        >
          {Object.entries(metricsConfig).map(([key, config]) => (
            <button
              key={key}
              type="button"
              onClick={() => setActiveMetric(key)}
              style={{
                background: activeMetric === key ? 'var(--color-primary-blue)' : 'transparent',
                color: activeMetric === key ? '#FFFFFF' : 'var(--text-secondary)',
                border: 'none',
                padding: '0.35rem 0.75rem',
                borderRadius: 'var(--radius-sm)',
                fontSize: '0.78rem',
                fontWeight: activeMetric === key ? 700 : 500,
                cursor: 'pointer',
                transition: 'all var(--transition-fast)'
              }}
            >
              {config.label}
            </button>
          ))}
        </div>
      </div>

      <div className="card-body">
        <div style={{ height: '320px', width: '100%' }}>
          <Line data={chartData} options={options} />
        </div>
      </div>
    </div>
  );
}
