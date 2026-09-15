import React, { useState } from 'react';
import {
  FileText,
  Download,
  Printer,
  Calendar,
  Eye,
  CheckCircle2,
  Bus,
  Gauge,
  Users,
  DollarSign,
  Building2,
  FileSpreadsheet
} from 'lucide-react';
import Button from '../../components/common/Button';
import Badge from '../../components/common/Badge';
import Modal from '../../components/common/Modal';
import { useFilters } from '../../context/FilterContext';
import { MOCK_PERIOD_KPIS } from '../../data/mockData';

export default function RelatoriosPage() {
  const [activeTab, setActiveTab] = useState('diario');
  const [isPreviewModalOpen, setIsPreviewModalOpen] = useState(false);
  const { addToast } = useFilters();

  const reportDataByTab = {
    diario: {
      typeLabel: 'Relatório Executivo Diário',
      period: '14 de Setembro de 2026',
      kpis: MOCK_PERIOD_KPIS.hoje,
      summary:
        'A operação municipal de São Caetano do Sul transcorreu com 99.6% de cumprimento das viagens programadas nas 8 linhas monitoradas. Foi registrada anomalia pontual na Linha 04 no período da manhã (14 viagens canceladas), com compensação parcial na Linha 01.',
      responsible: 'Coordenadoria de Fiscalização e Monitoramento — SEMOB-SCS'
    },
    semana: {
      typeLabel: 'Relatório Executivo Semanal',
      period: 'Semana 37 (07 a 13 de Setembro de 2026)',
      kpis: MOCK_PERIOD_KPIS.semana,
      summary:
        'Consolidação dos últimos 7 dias operacionais: foram totalizados 86.940 km rodados e 8.640 viagens realizadas. O índice de gratuidades manteve-se estável em 20.2%, dentro da média histórica trimestral do município.',
      responsible: 'Diretoria de Transportes Públicos — SEMOB-SCS'
    },
    mensal: {
      typeLabel: 'Relatório Executivo Mensal de Desempenho',
      period: 'Mês de Setembro/2026 (Consolidado Preliminar)',
      kpis: MOCK_PERIOD_KPIS.mes,
      summary:
        'Acumulado mensal de 368.200 km aferidos e 36.800 viagens. Foram atendidos 1.210.000 passageiros no sistema integrado municipal. Todas as operadoras cumpriram índice mínimo de pontualidade contratual.',
      responsible: 'Secretaria Municipal de Mobilidade Urbana — Gabinete do Secretário'
    }
  };

  const currentReport = reportDataByTab[activeTab];

  const handleSimulateExport = (format) => {
    addToast(
      `Relatório Exportado (${format})`,
      `O arquivo "${currentReport.typeLabel} - ${currentReport.period}.${format.toLowerCase()}" foi gerado para download.`,
      'success'
    );
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="relatorios-page">
      {/* Abas de Navegação de Relatórios */}
      <div
        style={{
          display: 'flex',
          gap: '0.5rem',
          borderBottom: '2px solid var(--border-subtle)',
          marginBottom: '1.75rem'
        }}
      >
        {[
          { id: 'diario', label: 'Relatório Diário' },
          { id: 'semana', label: 'Relatório Semanal' },
          { id: 'mensal', label: 'Relatório Mensal' }
        ].map((tab) => (
          <button
            key={tab.id}
            type="button"
            onClick={() => setActiveTab(tab.id)}
            style={{
              background: 'none',
              border: 'none',
              padding: '0.75rem 1.5rem',
              fontSize: '0.95rem',
              fontWeight: activeTab === tab.id ? 700 : 500,
              color: activeTab === tab.id ? 'var(--color-primary-blue)' : 'var(--text-secondary)',
              borderBottom: activeTab === tab.id ? '3px solid var(--color-primary-blue)' : '3px solid transparent',
              cursor: 'pointer',
              transition: 'all var(--transition-fast)'
            }}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Card Principal do Relatório Selecionado */}
      <div className="card">
        <div className="card-header">
          <div className="card-title-group">
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <FileText size={22} color="var(--color-primary-blue)" />
              <h2>{currentReport.typeLabel}</h2>
            </div>
            <p>Período de referência: <strong>{currentReport.period}</strong></p>
          </div>

          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <Button
              variant="outline-primary"
              onClick={() => setIsPreviewModalOpen(true)}
              icon={<Eye size={16} />}
            >
              Visualizar Relatório
            </Button>
            <Button
              variant="primary"
              onClick={() => handleSimulateExport('PDF')}
              icon={<Download size={16} />}
            >
              Exportar PDF
            </Button>
            <Button
              variant="secondary"
              onClick={() => handleSimulateExport('CSV')}
              icon={<FileSpreadsheet size={16} />}
            >
              Exportar CSV
            </Button>
          </div>
        </div>

        <div className="card-body">
          {/* Resumo Executivo */}
          <div
            style={{
              backgroundColor: 'var(--bg-surface-subtle)',
              border: '1px solid var(--border-subtle)',
              borderRadius: 'var(--radius-md)',
              padding: '1.25rem',
              marginBottom: '1.5rem'
            }}
          >
            <h3 style={{ fontSize: '0.95rem', color: 'var(--color-primary-navy)', marginBottom: '0.5rem' }}>
              Síntese Executiva para Gestores
            </h3>
            <p style={{ fontSize: '0.875rem', lineHeight: 1.6, color: 'var(--text-primary)' }}>
              {currentReport.summary}
            </p>
            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '0.5rem' }}>
              Emitido por: {currentReport.responsible}
            </div>
          </div>

          {/* Grid de Indicadores Consolidados do Relatório */}
          <h3 style={{ fontSize: '1rem', color: 'var(--color-primary-navy)', marginBottom: '1rem' }}>
            Principais Indicadores do Período
          </h3>
          <div className="kpis-grid" style={{ marginBottom: '1.5rem' }}>
            <div className="kpi-card">
              <span className="kpi-title">Quilometragem Consolidada</span>
              <span className="kpi-value">{currentReport.kpis.km.value.toLocaleString('pt-BR')} km</span>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Variação: +{currentReport.kpis.km.change}%</span>
            </div>

            <div className="kpi-card">
              <span className="kpi-title">Viagens Realizadas</span>
              <span className="kpi-value">{currentReport.kpis.viagens.value.toLocaleString('pt-BR')}</span>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Cumprimento: {currentReport.kpis.taxaCumprimento}</span>
            </div>

            <div className="kpi-card">
              <span className="kpi-title">Passageiros Pagantes</span>
              <span className="kpi-value">{currentReport.kpis.pagantes.value.toLocaleString('pt-BR')}</span>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Demanda arrecadada</span>
            </div>

            <div className="kpi-card">
              <span className="kpi-title">Não Pagantes (Gratuidades)</span>
              <span className="kpi-value">{currentReport.kpis.naoPagantes.value.toLocaleString('pt-BR')}</span>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Índice: {currentReport.kpis.indiceGratuidade}</span>
            </div>

            <div className="kpi-card">
              <span className="kpi-title">Apuração Financeira (Mock)</span>
              <span className="kpi-value">R$ {currentReport.kpis.financeiro.value.toLocaleString('pt-BR')}</span>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Demonstrativo preliminar</span>
            </div>
          </div>
        </div>
      </div>

      {/* Modal de Pré-visualização Formatada do Relatório com Timbrado Municipal */}
      <Modal
        isOpen={isPreviewModalOpen}
        onClose={() => setIsPreviewModalOpen(false)}
        title="Pré-Visualização do Documento Oficial"
        size="lg"
        footer={
          <div style={{ display: 'flex', gap: '0.75rem' }}>
            <Button variant="primary" onClick={handlePrint} icon={<Printer size={16} />}>
              Imprimir / Salvar PDF
            </Button>
            <Button variant="secondary" onClick={() => setIsPreviewModalOpen(false)}>
              Fechar
            </Button>
          </div>
        }
      >
        <div
          id="official-report-document"
          style={{
            backgroundColor: '#FFFFFF',
            border: '2px solid var(--border-subtle)',
            borderRadius: 'var(--radius-md)',
            padding: '2.5rem',
            color: '#0F172A',
            fontFamily: 'Inter, sans-serif'
          }}
        >
          {/* Timbrado Oficial */}
          <div
            style={{
              textAlign: 'center',
              borderBottom: '2px solid #005691',
              paddingBottom: '1.25rem',
              marginBottom: '1.5rem'
            }}
          >
            <div style={{ fontSize: '0.85rem', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.08em', color: '#0F2042' }}>
              PREFEITURA MUNICIPAL DE SÃO CAETANO DO SUL
            </div>
            <div style={{ fontSize: '0.8rem', fontWeight: 600, color: '#005691', textTransform: 'uppercase', marginTop: '2px' }}>
              SECRETARIA MUNICIPAL DE MOBILIDADE URBANA (SEMOB-SCS)
            </div>
            <div style={{ fontSize: '0.75rem', color: '#64748B' }}>
              Diretoria de Planejamento e Monitoramento de Transportes Coletivos
            </div>
          </div>

          {/* Título do Documento */}
          <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
            <h2 style={{ fontSize: '1.25rem', fontWeight: 800, color: '#0F2042' }}>
              {currentReport.typeLabel}
            </h2>
            <div style={{ fontSize: '0.85rem', color: '#475569', marginTop: '0.25rem' }}>
              Período de Apuração: <strong>{currentReport.period}</strong>
            </div>
          </div>

          {/* Resumo */}
          <div style={{ marginBottom: '1.5rem' }}>
            <h4 style={{ fontSize: '0.9rem', fontWeight: 700, color: '#005691', marginBottom: '0.4rem', borderBottom: '1px solid #E2E8F0', paddingBottom: '0.25rem' }}>
              1. RESUMO EXECUTIVO DA OPERAÇÃO
            </h4>
            <p style={{ fontSize: '0.85rem', lineHeight: 1.6, color: '#334155' }}>
              {currentReport.summary}
            </p>
          </div>

          {/* Tabela de Indicadores Oficiais */}
          <div style={{ marginBottom: '1.5rem' }}>
            <h4 style={{ fontSize: '0.9rem', fontWeight: 700, color: '#005691', marginBottom: '0.5rem', borderBottom: '1px solid #E2E8F0', paddingBottom: '0.25rem' }}>
              2. QUADRO CONSOLIDADO DE INDICADORES
            </h4>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.825rem' }}>
              <tbody>
                <tr style={{ borderBottom: '1px solid #E2E8F0' }}>
                  <td style={{ padding: '0.5rem', fontWeight: 600 }}>Quilometragem Total Homologada</td>
                  <td style={{ padding: '0.5rem', textAlign: 'right', fontWeight: 700 }}>{currentReport.kpis.km.value.toLocaleString('pt-BR')} km</td>
                </tr>
                <tr style={{ borderBottom: '1px solid #E2E8F0' }}>
                  <td style={{ padding: '0.5rem', fontWeight: 600 }}>Viagens Municipais Concluídas</td>
                  <td style={{ padding: '0.5rem', textAlign: 'right', fontWeight: 700 }}>{currentReport.kpis.viagens.value.toLocaleString('pt-BR')} viagens</td>
                </tr>
                <tr style={{ borderBottom: '1px solid #E2E8F0' }}>
                  <td style={{ padding: '0.5rem', fontWeight: 600 }}>Passageiros com Validação Tarifária</td>
                  <td style={{ padding: '0.5rem', textAlign: 'right', fontWeight: 700 }}>{currentReport.kpis.pagantes.value.toLocaleString('pt-BR')}</td>
                </tr>
                <tr style={{ borderBottom: '1px solid #E2E8F0' }}>
                  <td style={{ padding: '0.5rem', fontWeight: 600 }}>Passageiros com Gratuidade Legal</td>
                  <td style={{ padding: '0.5rem', textAlign: 'right', fontWeight: 700 }}>{currentReport.kpis.naoPagantes.value.toLocaleString('pt-BR')}</td>
                </tr>
                <tr style={{ borderBottom: '1px solid #E2E8F0', backgroundColor: '#F8FAFC' }}>
                  <td style={{ padding: '0.5rem', fontWeight: 700 }}>Total de Munícipes Transportados</td>
                  <td style={{ padding: '0.5rem', textAlign: 'right', fontWeight: 800, color: '#005691' }}>
                    {(currentReport.kpis.pagantes.value + currentReport.kpis.naoPagantes.value).toLocaleString('pt-BR')}
                  </td>
                </tr>
                <tr style={{ borderBottom: '1px solid #E2E8F0' }}>
                  <td style={{ padding: '0.5rem', fontWeight: 600 }}>Apuração Tarifária Demonstrativa (Mock)</td>
                  <td style={{ padding: '0.5rem', textAlign: 'right', fontWeight: 700 }}>
                    R$ {currentReport.kpis.financeiro.value.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          {/* Assinaturas Institucionais */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem', marginTop: '3rem', paddingTop: '1.5rem', textAlign: 'center' }}>
            <div>
              <div style={{ borderTop: '1px solid #64748B', width: '80%', margin: '0 auto', paddingTop: '0.4rem' }}>
                <div style={{ fontSize: '0.8rem', fontWeight: 700 }}>Dra. Luiza Gomes</div>
                <div style={{ fontSize: '0.72rem', color: '#64748B' }}>Coordenadoria de Planejamento SEMOB-SCS</div>
              </div>
            </div>
            <div>
              <div style={{ borderTop: '1px solid #64748B', width: '80%', margin: '0 auto', paddingTop: '0.4rem' }}>
                <div style={{ fontSize: '0.8rem', fontWeight: 700 }}>Diretoria de Fiscalização</div>
                <div style={{ fontSize: '0.72rem', color: '#64748B' }}>Secretaria de Mobilidade Urbana — SCS</div>
              </div>
            </div>
          </div>
        </div>
      </Modal>
    </div>
  );
}
