import React from 'react';
import './chartSetup';
import { Doughnut } from 'react-chartjs-2';
import { MOCK_PASSENGER_CATEGORIES } from '../../data/mockData';

export default function PassengersCategoryChart() {
  const chartData = {
    labels: MOCK_PASSENGER_CATEGORIES.map((c) => c.name),
    datasets: [
      {
        data: MOCK_PASSENGER_CATEGORIES.map((c) => c.count),
        backgroundColor: MOCK_PASSENGER_CATEGORIES.map((c) => c.color),
        borderWidth: 2,
        borderColor: '#FFFFFF'
      }
    ]
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    cutout: '65%',
    plugins: {
      legend: {
        position: 'right',
        labels: {
          font: { family: 'Inter', size: 11 },
          color: '#475569',
          usePointStyle: true,
          boxWidth: 8,
          padding: 12
        }
      },
      tooltip: {
        backgroundColor: '#0B192C',
        padding: 10,
        callbacks: {
          label: (context) => {
            const val = context.raw.toLocaleString('pt-BR');
            return ` ${context.label}: ${val} passageiros`;
          }
        }
      }
    }
  };

  return (
    <div className="card">
      <div className="card-header">
        <div className="card-title-group">
          <h2>Distribuição por Modalidade de Benefício</h2>
          <p>Composição de passageiros pagantes e gratuidades regulamentadas</p>
        </div>
      </div>
      <div className="card-body">
        <div style={{ height: '280px', width: '100%' }}>
          <Doughnut data={chartData} options={options} />
        </div>
      </div>
    </div>
  );
}
