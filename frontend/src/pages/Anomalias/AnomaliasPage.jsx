import React, { useState, useMemo } from 'react';
import {
  AlertTriangle,
  ShieldAlert,
  CheckCircle2,
  Clock,
  Eye,
  Search,
  Filter,
  Check,
  FileEdit,
  X,
  ArrowRight
} from 'lucide-react';
import KpiCard from '../../components/kpi/KpiCard';
import Badge from '../../components/common/Badge';
import Button from '../../components/common/Button';
import Modal from '../../components/common/Modal';
import EmptyState from '../../components/common/EmptyState';
import { MOCK_ALERTS } from '../../data/mockData';
import { useFilters } from '../../context/FilterContext';

export default function AnomaliasPage() {
  const { isRefreshing, addToast } = useFilters();
  const [alerts, setAlerts] = useState(MOCK_ALERTS);

  // Filtros
  const [selectedSeverity, setSelectedSeverity] = useState('todas');
  const [selectedStatus, setSelectedStatus] = useState('todos');
  const [selectedType, setSelectedType] = useState('todos');
  const [searchTerm, setSearchTerm] = useState('');

  // Modal de Detalhe / Ação
  const [selectedAlert, setSelectedAlert] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [justificationText, setJustificationText] = useState('');
  const [isJustifying, setIsJustifying] = useState(false);

  // Contadores de KPIs
  const totalAlertas = alerts.length;
  const criticos = alerts.filter((a) => a.severity === 'Crítico' && a.status !== 'Resolvido').length;
  const atencao = alerts.filter((a) => a.severity === 'Atenção' && a.status !== 'Resolvido').length;
  const resolvidos = alerts.filter((a) => a.status === 'Resolvido').length;

  const filteredAlerts = useMemo(() => {
    return alerts.filter((a) => {
      const matchesSeverity = selectedSeverity === 'todas' || a.severity === selectedSeverity;
      const matchesStatus = selectedStatus === 'todos' || a.status === selectedStatus;
      const matchesType = selectedType === 'todos' || a.type === selectedType;
      const matchesSearch =
        a.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        a.line.toLowerCase().includes(searchTerm.toLowerCase()) ||
        a.code.toLowerCase().includes(searchTerm.toLowerCase());

      return matchesSeverity && matchesStatus && matchesType && matchesSearch;
    });
  }, [alerts, selectedSeverity, selectedStatus, selectedType, searchTerm]);

  const handleOpenDetail = (alert) => {
    setSelectedAlert(alert);
    setJustificationText('');
    setIsJustifying(false);
    setIsModalOpen(true);
  };

  const handleResolveAlert = (id) => {
    setAlerts((prev) =>
      prev.map((a) => (a.id === id ? { ...a, status: 'Resolvido' } : a))
    );
    setIsModalOpen(false);
    addToast(
      'Alerta Resolvido',
      'A ocorrência foi marcada como auditada e resolvida.',
      'success'
    );
  };

  const handleSaveJustification = (id) => {
    if (!justificationText.trim()) return;
    setAlerts((prev) =>
      prev.map((a) =>
        a.id === id
          ? {
              ...a,
              status: 'Em Análise',
              impact: `${a.impact} (Justificativa registrada: ${justificationText})`
            }
          : a
      )
    );
    setIsModalOpen(false);
    addToast(
      'Justificativa Registrada',
      'A manifestação da operadora foi arquivada no histórico de fiscalização.',
      'info'
    );
  };

  const clearFilters = () => {
    setSelectedSeverity('todas');
    setSelectedStatus('todos');
    setSelectedType('todos');
    setSearchTerm('');
  };

  return (
    <div className="anomalias-page">
      {/* 4 KPIs de Anomalias Obrigatórios */}
      <div className="kpis-grid">
        <KpiCard
          title="Total de Alertas"
          value={totalAlertas}
          unit="ocorrências"
          change={12.5}
          trend="up"
          previousLabel="no ciclo corrente"
          tooltip="Total de alertas identificados na telemetria operacional da SEMOB-SCS."
          icon={<ShieldAlert size={22} />}
          iconBg="#EBF3FA"
          iconColor="#005691"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Alertas Críticos"
          value={criticos}
          unit="casos urgentes"
          change={criticos > 0 ? 100 : 0}
          trend={criticos > 0 ? 'down' : 'neutral'}
          previousLabel="exigem ação imediata"
          tooltip="Viagens suprimidas, quebras de frota ou falhas graves de telemetria."
          icon={<AlertTriangle size={22} />}
          iconBg="#FEF2F2"
          iconColor="#DC2626"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Avisos de Atenção"
          value={atencao}
          unit="desvios médios"
          change={0.0}
          trend="neutral"
          previousLabel="desvios de km e gratuidades"
          tooltip="Variações na média histórica que demandam apuração preventiva."
          icon={<AlertTriangle size={22} />}
          iconBg="#FFFBEB"
          iconColor="#D97706"
          isLoading={isRefreshing}
        />

        <KpiCard
          title="Alertas Resolvidos"
          value={resolvidos}
          unit="auditados"
          change={25.0}
          trend="up"
          previousLabel="taxa de resolução"
          tooltip="Ocorrências que receberam parecer técnico ou justificativa acolhida."
          icon={<CheckCircle2 size={22} />}
          iconBg="#ECFDF5"
          iconColor="#059669"
          isLoading={isRefreshing}
        />
      </div>

      {/* Barra de Filtros */}
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
          {/* Busca Textual */}
          <div style={{ position: 'relative', minWidth: '260px', flex: 1 }}>
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
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Buscar por código, linha ou título do alerta..."
              style={{
                width: '100%',
                padding: '0.65rem 0.85rem 0.65rem 2.4rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-default)',
                fontSize: '0.875rem'
              }}
            />
          </div>

          {/* Filtro Severidade */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <label htmlFor="filter-severity" style={{ fontSize: '0.825rem', fontWeight: 600 }}>
              Severidade:
            </label>
            <select
              id="filter-severity"
              value={selectedSeverity}
              onChange={(e) => setSelectedSeverity(e.target.value)}
              style={{
                padding: '0.65rem 0.85rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-default)',
                fontSize: '0.85rem'
              }}
            >
              <option value="todas">Todas as Severidades</option>
              <option value="Crítico">Crítico</option>
              <option value="Atenção">Atenção</option>
            </select>
          </div>

          {/* Filtro Status */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <label htmlFor="filter-alert-status" style={{ fontSize: '0.825rem', fontWeight: 600 }}>
              Status:
            </label>
            <select
              id="filter-alert-status"
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              style={{
                padding: '0.65rem 0.85rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-default)',
                fontSize: '0.85rem'
              }}
            >
              <option value="todos">Todos os Status</option>
              <option value="Pendente">Pendente</option>
              <option value="Em Análise">Em Análise</option>
              <option value="Resolvido">Resolvido</option>
            </select>
          </div>

          {/* Filtro Tipo */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <label htmlFor="filter-type" style={{ fontSize: '0.825rem', fontWeight: 600 }}>
              Tipo:
            </label>
            <select
              id="filter-type"
              value={selectedType}
              onChange={(e) => setSelectedType(e.target.value)}
              style={{
                padding: '0.65rem 0.85rem',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--border-default)',
                fontSize: '0.85rem'
              }}
            >
              <option value="todos">Todos os Tipos</option>
              <option value="Quilometragem">Quilometragem</option>
              <option value="Viagens Canceladas">Viagens Canceladas</option>
              <option value="Gratuidades">Gratuidades</option>
              <option value="Consolidação de Dados">Consolidação de Dados</option>
              <option value="Pontualidade">Pontualidade</option>
            </select>
          </div>

          {(selectedSeverity !== 'todas' || selectedStatus !== 'todos' || selectedType !== 'todos' || searchTerm) && (
            <Button variant="ghost" size="sm" onClick={clearFilters} icon={<X size={14} />}>
              Limpar
            </Button>
          )}
        </div>
      </div>

      {/* Tabela de Anomalias */}
      <div className="card">
        <div className="card-header">
          <div className="card-title-group">
            <h2>Ocorrências Registradas para Auditoria</h2>
            <p>Lista de inconsistências para averiguação dos gestores da SEMOB</p>
          </div>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
            Total filtrado: {filteredAlerts.length}
          </span>
        </div>

        <div className="data-table-container">
          <table className="data-table" aria-label="Tabela de anomalias operacionais">
            <thead>
              <tr>
                <th>Código / Tipo</th>
                <th>Descrição da Anomalia</th>
                <th>Linha Afetada</th>
                <th>Data / Hora</th>
                <th>Severidade</th>
                <th>Status</th>
                <th style={{ textAlign: 'center' }}>Ações</th>
              </tr>
            </thead>
            <tbody>
              {filteredAlerts.length === 0 ? (
                <tr>
                  <td colSpan={7}>
                    <EmptyState
                      title="Nenhuma anomalia encontrada"
                      description="Não há ocorrências correspondentes aos filtros aplicados."
                      actionLabel="Limpar Filtros"
                      onAction={clearFilters}
                    />
                  </td>
                </tr>
              ) : (
                filteredAlerts.map((alert) => {
                  const isCritical = alert.severity === 'Crítico';
                  const statusVariant =
                    alert.status === 'Resolvido'
                      ? 'success'
                      : alert.status === 'Em Análise'
                      ? 'info'
                      : 'warning';

                  return (
                    <tr key={alert.id} className="clickable" onClick={() => handleOpenDetail(alert)}>
                      <td>
                        <div style={{ fontWeight: 700, color: 'var(--color-primary-navy)' }}>{alert.code}</div>
                        <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{alert.type}</span>
                      </td>
                      <td>
                        <div style={{ fontWeight: 600, color: 'var(--text-primary)' }}>{alert.title}</div>
                        <div style={{ fontSize: '0.78rem', color: 'var(--text-secondary)' }}>
                          {alert.description}
                        </div>
                      </td>
                      <td style={{ fontWeight: 600 }}>{alert.line}</td>
                      <td style={{ fontSize: '0.8rem', whiteSpace: 'nowrap' }}>{alert.date}</td>
                      <td>
                        <Badge variant={isCritical ? 'danger' : 'warning'}>
                          {alert.severity}
                        </Badge>
                      </td>
                      <td>
                        <Badge variant={statusVariant}>{alert.status}</Badge>
                      </td>
                      <td style={{ textAlign: 'center' }}>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            handleOpenDetail(alert);
                          }}
                          icon={<Eye size={15} />}
                        >
                          Auditar
                        </Button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal de Detalhes da Anomalia / Auditoria */}
      {selectedAlert && (
        <Modal
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          title={`Auditoria da Ocorrência: ${selectedAlert.code}`}
          size="lg"
          footer={
            <div style={{ display: 'flex', gap: '0.75rem' }}>
              {selectedAlert.status !== 'Resolvido' && (
                <Button
                  variant="primary"
                  onClick={() => handleResolveAlert(selectedAlert.id)}
                  icon={<Check size={16} />}
                >
                  Marcar como Resolvido
                </Button>
              )}
              <Button variant="secondary" onClick={() => setIsModalOpen(false)}>
                Fechar
              </Button>
            </div>
          }
        >
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingBottom: '0.75rem', borderBottom: '1px solid var(--border-subtle)' }}>
              <div>
                <h3 style={{ fontSize: '1.15rem', color: 'var(--color-primary-navy)' }}>
                  {selectedAlert.title}
                </h3>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                  {selectedAlert.line} | Registrado em {selectedAlert.date}
                </span>
              </div>
              <div style={{ display: 'flex', gap: '0.5rem' }}>
                <Badge variant={selectedAlert.severity === 'Crítico' ? 'danger' : 'warning'}>
                  {selectedAlert.severity}
                </Badge>
                <Badge variant="info">{selectedAlert.status}</Badge>
              </div>
            </div>

            {/* Diagnóstico Comparativo: Esperado vs Aferido */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase' }}>
                  Parâmetro Homologado (Esperado)
                </span>
                <div style={{ fontSize: '1.15rem', fontWeight: 700, color: 'var(--color-primary-navy)', marginTop: '0.25rem' }}>
                  {selectedAlert.expectedValue}
                </div>
              </div>

              <div style={{ padding: '1rem', backgroundColor: 'var(--status-warning-bg)', borderRadius: 'var(--radius-md)', border: '1px solid var(--status-warning-border)' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--status-warning-text)', textTransform: 'uppercase' }}>
                  Telemetria Aferida em Campo
                </span>
                <div style={{ fontSize: '1.15rem', fontWeight: 700, color: 'var(--status-danger)', marginTop: '0.25rem' }}>
                  {selectedAlert.actualValue}
                </div>
              </div>
            </div>

            <div>
              <h4 style={{ fontSize: '0.875rem', fontWeight: 700, color: 'var(--color-primary-navy)', marginBottom: '0.35rem' }}>
                Impacto Operacional Identificado
              </h4>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                {selectedAlert.impact}
              </p>
            </div>

            <div>
              <h4 style={{ fontSize: '0.875rem', fontWeight: 700, color: 'var(--color-primary-navy)', marginBottom: '0.35rem' }}>
                Recomendação da Fiscalização
              </h4>
              <p style={{ fontSize: '0.85rem', color: 'var(--color-primary-blue)', fontWeight: 600 }}>
                {selectedAlert.actionRequired}
              </p>
            </div>

            {/* Ação de Justificativa da Concessionária */}
            <div style={{ borderTop: '1px solid var(--border-subtle)', paddingTop: '1rem' }}>
              {!isJustifying ? (
                <Button
                  variant="outline-primary"
                  size="sm"
                  onClick={() => setIsJustifying(true)}
                  icon={<FileEdit size={14} />}
                >
                  Registrar Parecer ou Justificativa da Operadora
                </Button>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                  <label htmlFor="input-justification" style={{ fontSize: '0.825rem', fontWeight: 600 }}>
                    Parecer Técnico / Justificativa da Operadora:
                  </label>
                  <textarea
                    id="input-justification"
                    rows={3}
                    value={justificationText}
                    onChange={(e) => setJustificationText(e.target.value)}
                    placeholder="Ex: Operadora informou bloqueio temporário de faixa por obras da Sabesp..."
                    style={{
                      width: '100%',
                      padding: '0.65rem 0.85rem',
                      borderRadius: 'var(--radius-md)',
                      border: '1px solid var(--border-default)',
                      fontSize: '0.85rem'
                    }}
                  />
                  <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <Button
                      variant="primary"
                      size="sm"
                      onClick={() => handleSaveJustification(selectedAlert.id)}
                    >
                      Salvar Justificativa
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setIsJustifying(false)}
                    >
                      Cancelar
                    </Button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}
