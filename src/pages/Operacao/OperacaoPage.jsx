import React, { useState, useMemo } from 'react';
import {
  Gauge,
  Bus,
  Search,
  Filter,
  ArrowUpDown,
  ChevronLeft,
  ChevronRight,
  Eye,
  SlidersHorizontal,
  X,
  FileSpreadsheet
} from 'lucide-react';
import KpiCard from '../../components/kpi/KpiCard';
import Badge from '../../components/common/Badge';
import Button from '../../components/common/Button';
import EmptyState from '../../components/common/EmptyState';
import Skeleton from '../../components/common/Skeleton';
import { MOCK_OPERATIONS_TABLE, MOCK_LINES } from '../../data/mockData';
import { useFilters } from '../../context/FilterContext';
import { Line } from 'react-chartjs-2';

export default function OperacaoPage({ onNavigate, onSelectDetail }) {
  const { isRefreshing } = useFilters();

  // Estados dos Filtros
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedLine, setSelectedLine] = useState('todas');
  const [selectedStatus, setSelectedStatus] = useState('todos');
  const [sortField, setSortField] = useState('date');
  const [sortAsc, setSortAsc] = useState(false);

  // Paginação
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 6;

  // Filtragem
  const filteredData = useMemo(() => {
    return MOCK_OPERATIONS_TABLE.filter((row) => {
      const matchesSearch =
        row.lineName.toLowerCase().includes(searchTerm.toLowerCase()) ||
        row.date.includes(searchTerm) ||
        row.lineCode.includes(searchTerm);

      const matchesLine =
        selectedLine === 'todas' || row.lineId === selectedLine;

      const matchesStatus =
        selectedStatus === 'todos' || row.status === selectedStatus;

      return matchesSearch && matchesLine && matchesStatus;
    }).sort((a, b) => {
      let aVal = a[sortField];
      let bVal = b[sortField];
      if (typeof aVal === 'string') {
        return sortAsc ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
      }
      return sortAsc ? aVal - bVal : bVal - aVal;
    });
  }, [searchTerm, selectedLine, selectedStatus, sortField, sortAsc]);

  // Paginação
  const totalPages = Math.ceil(filteredData.length / itemsPerPage) || 1;
  const paginatedData = filteredData.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const handleSort = (field) => {
    if (sortField === field) {
      setSortAsc(!sortAsc);
    } else {
      setSortField(field);
      setSortAsc(true);
    }
  };

  const handleViewDetail = (row) => {
    if (onSelectDetail) {
      onSelectDetail(row);
    }
    onNavigate('/detalhes');
  };

  const clearFilters = () => {
    setSearchTerm('');
    setSelectedLine('todas');
    setSelectedStatus('todos');
    setCurrentPage(1);
  };

  // Cálculos Consolidados para os Cards
  const totalKm = filteredData.reduce((acc, r) => acc + r.km, 0);
  const avgKm = filteredData.length > 0 ? Math.round(totalKm / filteredData.length) : 0;
  const totalViagens = filteredData.reduce((acc, r) => acc + r.viagens, 0);
  const avgViagens = filteredData.length > 0 ? Math.round(totalViagens / filteredData.length) : 0;

  // Gráfico de Evolução de Km e Viagens por Registro
  const chartLabels = filteredData.slice(0, 8).map((r) => `${r.lineCode} (${r.date.split('/')[0]}/${r.date.split('/')[1]})`);
  const kmChartData = {
    labels: chartLabels,
    datasets: [
      {
        label: 'Km Aferido',
        data: filteredData.slice(0, 8).map((r) => r.km),
        borderColor: '#005691',
        backgroundColor: 'rgba(0, 86, 145, 0.15)',
        fill: true,
        tension: 0.3
      },
      {
        label: 'Km Programado',
        data: filteredData.slice(0, 8).map((r) => r.kmProgramado),
        borderColor: '#94A3B8',
        borderDash: [5, 5],
        fill: false,
        tension: 0.3
      }
    ]
  };

  return (
    <div className="operacao-page">
      {/* Cards Analíticos de Operação */}
      <div className="kpis-grid">
        <KpiCard
          title="Quilometragem Total"
          value={totalKm}
          unit="km"
          change={2.1}
          trend="up"
          previousLabel="no filtro selecionado"
          tooltip="Somatória da quilometragem aferida em todas as viagens filtradas."
          icon={<Gauge size={22} />}
          iconBg="#EBF3FA"
          iconColor="#005691"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Média de Quilometragem"
          value={avgKm}
          unit="km/linha"
          change={0.8}
          trend="up"
          previousLabel="vs. parâmetro padrão"
          tooltip="Média de quilometragem por linha no conjunto de dados filtrado."
          icon={<Gauge size={22} />}
          iconBg="#E0F2FE"
          iconColor="#0284C7"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Viagens Realizadas"
          value={totalViagens}
          unit="viagens"
          change={-0.4}
          trend="down"
          previousLabel="vs. programado"
          tooltip="Volume total de viagens concluídas na amostra filtrada."
          icon={<Bus size={22} />}
          iconBg="#ECFDF5"
          iconColor="#059669"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Média de Viagens"
          value={avgViagens}
          unit="viagens/linha"
          change={1.2}
          trend="up"
          previousLabel="desempenho médio"
          tooltip="Média de viagens por linha operacional."
          icon={<Bus size={22} />}
          iconBg="#FFFBEB"
          iconColor="#D97706"
          isLoading={isRefreshing}
        />
      </div>

      {/* Gráfico de Comparativo de Km Real vs Programado */}
      <div className="card">
        <div className="card-header">
          <div className="card-title-group">
            <h2>Evolução da Quilometragem (Aferida vs. Programada)</h2>
            <p>Confronto de odômetro entre planejamento operacional e execução em campo</p>
          </div>
        </div>
        <div className="card-body">
          <div style={{ height: '260px', width: '100%' }}>
            <Line
              data={kmChartData}
              options={{
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                  legend: { position: 'top', labels: { font: { family: 'Inter' } } }
                },
                scales: {
                  y: { ticks: { callback: (v) => `${v.toLocaleString('pt-BR')} km` } }
                }
              }}
            />
          </div>
        </div>
      </div>

      {/* Barra de Busca e Filtros */}
      <div className="card" style={{ marginBottom: '1.25rem' }}>
        <div
          style={{
            padding: '1.25rem',
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '1rem'
          }}
        >
          {/* Campo de Busca Textual */}
          <div style={{ position: 'relative', minWidth: '280px', flex: 1 }}>
            <div
              style={{
                position: 'absolute',
                left: '0.85rem',
                top: '50%',
                transform: 'translateY(-50%)',
                color: 'var(--text-muted)'
              }}
            >
              <Search size={18} />
            </div>
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => {
                setSearchTerm(e.target.value);
                setCurrentPage(1);
              }}
              placeholder="Buscar por linha, código ou data..."
              style={{
                width: '100%',
                padding: '0.65rem 0.85rem 0.65rem 2.4rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-default)',
                fontSize: '0.875rem',
                backgroundColor: 'var(--bg-surface)'
              }}
              aria-label="Buscar na tabela de operação"
            />
          </div>

          {/* Filtro por Linha */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <label htmlFor="filter-line" style={{ fontSize: '0.825rem', fontWeight: 600, color: 'var(--text-secondary)' }}>
              Linha:
            </label>
            <select
              id="filter-line"
              value={selectedLine}
              onChange={(e) => {
                setSelectedLine(e.target.value);
                setCurrentPage(1);
              }}
              style={{
                padding: '0.65rem 0.85rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-default)',
                fontSize: '0.85rem',
                backgroundColor: 'var(--bg-surface)'
              }}
            >
              {MOCK_LINES.map((line) => (
                <option key={line.id} value={line.id}>
                  {line.name}
                </option>
              ))}
            </select>
          </div>

          {/* Filtro por Status */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <label htmlFor="filter-status" style={{ fontSize: '0.825rem', fontWeight: 600, color: 'var(--text-secondary)' }}>
              Status:
            </label>
            <select
              id="filter-status"
              value={selectedStatus}
              onChange={(e) => {
                setSelectedStatus(e.target.value);
                setCurrentPage(1);
              }}
              style={{
                padding: '0.65rem 0.85rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-default)',
                fontSize: '0.85rem',
                backgroundColor: 'var(--bg-surface)'
              }}
            >
              <option value="todos">Todos os Status</option>
              <option value="Regular">Regular</option>
              <option value="Atenção">Atenção</option>
              <option value="Crítico">Crítico</option>
            </select>
          </div>

          {(searchTerm || selectedLine !== 'todas' || selectedStatus !== 'todos') && (
            <Button variant="ghost" size="sm" onClick={clearFilters} icon={<X size={14} />}>
              Limpar Filtros
            </Button>
          )}
        </div>
      </div>

      {/* Tabela de Dados da Operação */}
      <div className="card">
        <div className="card-header">
          <div className="card-title-group">
            <h2>Registros Operacionais Detalhados</h2>
            <p>Lista analítica de viagens, quilometragem e validações registradas</p>
          </div>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
            Exibindo {filteredData.length} registro{filteredData.length !== 1 ? 's' : ''}
          </span>
        </div>

        <div className="data-table-container">
          <table className="data-table" aria-label="Tabela de registros da operação de transporte">
            <thead>
              <tr>
                <th className="sortable" onClick={() => handleSort('date')}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                    Data <ArrowUpDown size={13} />
                  </div>
                </th>
                <th className="sortable" onClick={() => handleSort('lineName')}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                    Linha / Sentido <ArrowUpDown size={13} />
                  </div>
                </th>
                <th className="sortable" onClick={() => handleSort('km')}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                    Quilometragem <ArrowUpDown size={13} />
                  </div>
                </th>
                <th className="sortable" onClick={() => handleSort('viagens')}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                    Viagens (Realiz./Prog.) <ArrowUpDown size={13} />
                  </div>
                </th>
                <th className="sortable" onClick={() => handleSort('pagantes')}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                    Pass. Pagantes <ArrowUpDown size={13} />
                  </div>
                </th>
                <th className="sortable" onClick={() => handleSort('naoPagantes')}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.35rem' }}>
                    Não Pagantes <ArrowUpDown size={13} />
                  </div>
                </th>
                <th>Status</th>
                <th style={{ textAlign: 'center' }}>Ação</th>
              </tr>
            </thead>
            <tbody>
              {isRefreshing ? (
                Array.from({ length: itemsPerPage }).map((_, i) => (
                  <tr key={i}>
                    <td><Skeleton width="70px" /></td>
                    <td><Skeleton width="180px" /></td>
                    <td><Skeleton width="90px" /></td>
                    <td><Skeleton width="90px" /></td>
                    <td><Skeleton width="90px" /></td>
                    <td><Skeleton width="90px" /></td>
                    <td><Skeleton width="80px" /></td>
                    <td><Skeleton width="60px" /></td>
                  </tr>
                ))
              ) : paginatedData.length === 0 ? (
                <tr>
                  <td colSpan={8}>
                    <EmptyState
                      title="Nenhum registro correspondente"
                      description="Nenhum dado operacional atende aos critérios de busca aplicados."
                      actionLabel="Limpar Filtros"
                      onAction={clearFilters}
                    />
                  </td>
                </tr>
              ) : (
                paginatedData.map((row) => {
                  const statusVariant =
                    row.status === 'Regular'
                      ? 'success'
                      : row.status === 'Atenção'
                      ? 'warning'
                      : 'danger';

                  return (
                    <tr key={row.id} className="clickable" onClick={() => handleViewDetail(row)}>
                      <td style={{ fontWeight: 600 }}>{row.date}</td>
                      <td>
                        <div style={{ fontWeight: 600, color: 'var(--color-primary-navy)' }}>
                          {row.lineName}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                          Frota ativa: {row.veiculosAtivos} veículos
                        </div>
                      </td>
                      <td>
                        <span style={{ fontWeight: 700 }}>{row.km.toLocaleString('pt-BR')} km</span>
                        <div style={{ fontSize: '0.725rem', color: 'var(--text-muted)' }}>
                          Prog: {row.kmProgramado.toLocaleString('pt-BR')} km
                        </div>
                      </td>
                      <td>
                        <span style={{ fontWeight: 700 }}>{row.viagens}</span>
                        <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>
                          {' '}/ {row.viagensProgramadas}
                        </span>
                      </td>
                      <td style={{ color: 'var(--status-success-text)', fontWeight: 600 }}>
                        {row.pagantes.toLocaleString('pt-BR')}
                      </td>
                      <td style={{ color: 'var(--status-warning-text)', fontWeight: 600 }}>
                        {row.naoPagantes.toLocaleString('pt-BR')}
                      </td>
                      <td>
                        <Badge variant={statusVariant}>{row.status}</Badge>
                      </td>
                      <td style={{ textAlign: 'center' }}>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            handleViewDetail(row);
                          }}
                          title="Ver detalhamento completo deste dia e linha"
                          icon={<Eye size={15} />}
                        >
                          Detalhes
                        </Button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Barra de Paginação */}
        <div
          style={{
            padding: '1rem 1.25rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            borderTop: '1px solid var(--border-subtle)',
            backgroundColor: 'var(--bg-surface-subtle)',
            flexWrap: 'wrap',
            gap: '0.75rem'
          }}
        >
          <span style={{ fontSize: '0.825rem', color: 'var(--text-muted)' }}>
            Página <strong>{currentPage}</strong> de <strong>{totalPages}</strong> ({filteredData.length} registros no total)
          </span>

          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <Button
              variant="secondary"
              size="sm"
              disabled={currentPage === 1}
              onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
              icon={<ChevronLeft size={16} />}
            >
              Anterior
            </Button>
            <Button
              variant="secondary"
              size="sm"
              disabled={currentPage === totalPages}
              onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
              iconRight={<ChevronRight size={16} />}
            >
              Próxima
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
