import React from 'react';
import './chartSetup';
import { Bar } from 'react-chartjs-2';
import { MOCK_DAILY_HISTORY } from '../../data/mockData';

export default function PassengersChart() {
  const chartData = {
    labels: MOCK_DAILY_HISTORY.map((d) => d.date),
    datasets: [
      {
        label: 'Passageiros Pagantes',
        data: MOCK_DAILY_HISTORY.map((d) => d.pagantes),
        backgroundColor: '#005691',
        borderRadius: 4
      },
      {
        label: 'Passageiros Não Pagantes (Gratuidades)',
        data: MOCK_DAILY_HISTORY.map((d) => d.naoPagantes),
        backgroundColor: '#0284C7',
        borderRadius: 4
      },
      {
        label: 'Total de Passageiros',
        data: MOCK_DAILY_HISTORY.map((d) => d.pagantes + d.naoPagantes),
        backgroundColor: '#94A3B8',
        borderRadius: 4
      }
    ]
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top',
        labels: {
          font: { family: 'Inter', size: 12 },
          color: '#475569',
          usePointStyle: true,
          boxWidth: 8
        }
      },
      tooltip: {
        backgroundColor: '#0B192C',
        padding: 10,
        callbacks: {
          label: (context) => {
            const val = context.raw.toLocaleString('pt-BR');
            return ` ${context.dataset.label}: ${val} passageiros`;
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
        grid: { color: '#E2E8F0' },
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
          <h2>Comparativo de Passageiros</h2>
          <p>Relação entre demanda pagante, gratuidades e volume total diário</p>
        </div>
      </div>
      <div className="card-body">
        <div style={{ height: '300px', width: '100%' }}>
          <Bar data={chartData} options={options} />
        </div>
      </div>
    </div>
  );
}
