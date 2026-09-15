import React from 'react';
import './chartSetup';
import { Line } from 'react-chartjs-2';
import { MOCK_DAILY_HISTORY } from '../../data/mockData';

export default function FinancialEvolutionChart() {
  const chartData = {
    labels: MOCK_DAILY_HISTORY.map((d) => d.date),
    datasets: [
      {
        label: 'Apuração Tarifária Diária (R$)',
        data: MOCK_DAILY_HISTORY.map((d) => d.financeiro),
        borderColor: '#005691',
        backgroundColor: 'rgba(0, 86, 145, 0.1)',
        fill: true,
        tension: 0.3,
        pointBackgroundColor: '#005691',
        pointBorderColor: '#FFFFFF',
        pointRadius: 5
      }
    ]
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: '#0B192C',
        padding: 10,
        callbacks: {
          label: (context) => {
            return ` Valor Consolidado: R$ ${context.raw.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`;
          }
        }
      }
    },
    scales: {
      x: { grid: { display: false }, ticks: { font: { size: 11, family: 'Inter' }, color: '#64748B' } },
      y: {
        grid: { color: '#E2E8F0' },
        ticks: {
          font: { size: 11, family: 'Inter' },
          color: '#64748B',
          callback: (val) => `R$ ${(val / 1000).toFixed(0)}k`
        }
      }
    }
  };

  return (
    <div className="card">
      <div className="card-header">
        <div className="card-title-group">
          <h2>Evolução Financeira da Operação (Demonstrativo)</h2>
          <p>Valores consolidados por período com base na tarifa municipal vigente</p>
        </div>
      </div>
      <div className="card-body">
        <div style={{ height: '300px', width: '100%' }}>
          <Line data={chartData} options={options} />
        </div>
      </div>
    </div>
  );
}
