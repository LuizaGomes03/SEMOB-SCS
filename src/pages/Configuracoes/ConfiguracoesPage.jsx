import React, { useState } from 'react';
import {
  User,
  Mail,
  Briefcase,
  Shield,
  Eye,
  Type,
  LogOut,
  Check,
  BellRing,
  Sliders,
  Sparkles
} from 'lucide-react';
import Button from '../../components/common/Button';
import Badge from '../../components/common/Badge';
import { useAuth } from '../../context/AuthContext';
import { useAccessibility } from '../../context/AccessibilityContext';
import { useFilters } from '../../context/FilterContext';

export default function ConfiguracoesPage({ onNavigate }) {
  const { user, logout } = useAuth();
  const {
    fontScale,
    increaseFontSize,
    decreaseFontSize,
    resetFontSize,
    highContrast,
    toggleHighContrast,
    enhancedFocus,
    toggleEnhancedFocus,
    setIsKeyboardModalOpen
  } = useAccessibility();
  const { addToast } = useFilters();

  const [defaultPeriod, setDefaultPeriod] = useState('hoje');
  const [tableDensity, setTableDensity] = useState('normal');
  const [soundAlerts, setSoundAlerts] = useState(true);

  const handleSavePreferences = () => {
    addToast(
      'Preferências Salvas',
      'As configurações institucionais foram atualizadas no seu perfil.',
      'success'
    );
  };

  const handleLogout = () => {
    logout();
    onNavigate('/login');
  };

  return (
    <div className="configuracoes-page">
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(420px, 1fr))', gap: '1.5rem' }}>
        {/* Card 1: Perfil do Gestor */}
        <div className="card">
          <div className="card-header">
            <div className="card-title-group">
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <User size={20} color="var(--color-primary-blue)" />
                <h2>Perfil do Gestor Municipal</h2>
              </div>
              <p>Dados de identificação institucional na SEMOB-SCS</p>
            </div>
            <Badge variant="success">Sessão Ativa</Badge>
          </div>

          <div className="card-body">
            <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem', marginBottom: '1.5rem', paddingBottom: '1.5rem', borderBottom: '1px solid var(--border-subtle)' }}>
              <div
                style={{
                  width: '64px',
                  height: '64px',
                  borderRadius: 'var(--radius-full)',
                  backgroundColor: 'var(--color-primary-navy)',
                  color: '#FFFFFF',
                  fontSize: '1.5rem',
                  fontWeight: 800,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  border: '3px solid var(--color-primary-blue)'
                }}
              >
                {user?.initials || 'LG'}
              </div>

              <div>
                <h3 style={{ fontSize: '1.15rem', color: 'var(--color-primary-navy)' }}>
                  {user?.name}
                </h3>
                <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  {user?.role}
                </div>
                <div style={{ fontSize: '0.78rem', color: 'var(--color-primary-blue)', fontWeight: 600, marginTop: '2px' }}>
                  {user?.department}
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.85rem' }}>
              <div>
                <label style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase' }}>
                  E-mail Funcional
                </label>
                <div style={{ fontSize: '0.9rem', fontWeight: 600, color: 'var(--text-primary)' }}>
                  {user?.email}
                </div>
              </div>

              <div>
                <label style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase' }}>
                  Nível de Privilégio
                </label>
                <div style={{ fontSize: '0.9rem', fontWeight: 600, color: 'var(--text-primary)' }}>
                  {user?.accessLevel}
                </div>
              </div>
            </div>

            <div style={{ marginTop: '2rem', paddingTop: '1.25rem', borderTop: '1px solid var(--border-subtle)' }}>
              <Button
                variant="danger"
                onClick={handleLogout}
                icon={<LogOut size={16} />}
              >
                Encerrar Sessão (Sair da Conta)
              </Button>
            </div>
          </div>
        </div>

        {/* Card 2: Preferências de Visualização e Operação */}
        <div className="card">
          <div className="card-header">
            <div className="card-title-group">
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Sliders size={20} color="var(--color-primary-blue)" />
                <h2>Preferências do Sistema</h2>
              </div>
              <p>Personalização da visualização padrão de indicadores</p>
            </div>
          </div>

          <div className="card-body" style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div>
              <label htmlFor="pref-period" style={{ display: 'block', fontSize: '0.825rem', fontWeight: 600, marginBottom: '0.4rem' }}>
                Período Padrão ao Entrar no Dashboard:
              </label>
              <select
                id="pref-period"
                value={defaultPeriod}
                onChange={(e) => setDefaultPeriod(e.target.value)}
                style={{
                  width: '100%',
                  padding: '0.65rem 0.85rem',
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-default)',
                  fontSize: '0.875rem'
                }}
              >
                <option value="hoje">Hoje (Operação em tempo corrente)</option>
                <option value="semana">Últimos 7 dias consolidados</option>
                <option value="mes">Mês de referência fechado</option>
              </select>
            </div>

            <div>
              <label htmlFor="pref-density" style={{ display: 'block', fontSize: '0.825rem', fontWeight: 600, marginBottom: '0.4rem' }}>
                Densidade de Linhas nas Tabelas:
              </label>
              <select
                id="pref-density"
                value={tableDensity}
                onChange={(e) => setTableDensity(e.target.value)}
                style={{
                  width: '100%',
                  padding: '0.65rem 0.85rem',
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-default)',
                  fontSize: '0.875rem'
                }}
              >
                <option value="compact">Compacta (mais dados na tela)</option>
                <option value="normal">Normal / Confortável (recomendado)</option>
                <option value="spacious">Espaçosa (máxima legibilidade)</option>
              </select>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0.75rem 0', borderTop: '1px solid var(--border-subtle)' }}>
              <div>
                <div style={{ fontSize: '0.875rem', fontWeight: 600 }}>Notificações Sonoras para Alertas Críticos</div>
                <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Tocar bip discreto ao receber anomalia severa da Smart Data</div>
              </div>
              <input
                type="checkbox"
                checked={soundAlerts}
                onChange={(e) => setSoundAlerts(e.target.checked)}
                style={{ width: '18px', height: '18px', cursor: 'pointer' }}
                aria-label="Ativar avisos sonoros de anomalias"
              />
            </div>

            <Button
              variant="primary"
              onClick={handleSavePreferences}
              icon={<Check size={16} />}
              style={{ alignSelf: 'flex-start', marginTop: '0.5rem' }}
            >
              Salvar Preferências
            </Button>
          </div>
        </div>

        {/* Card 3: Configurações de Acessibilidade Digital */}
        <div className="card" style={{ gridColumn: '1 / -1' }}>
          <div className="card-header">
            <div className="card-title-group">
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Eye size={20} color="var(--color-primary-blue)" />
                <h2>Recursos de Acessibilidade e Inclusão Digital</h2>
              </div>
              <p>Conformidade e-MAG / WCAG 2.1 — Padrão Prefeitura de São Caetano do Sul</p>
            </div>
          </div>

          <div className="card-body">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.25rem' }}>
              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <div style={{ fontWeight: 700, fontSize: '0.9rem', marginBottom: '0.25rem' }}>Tamanho da Fonte</div>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '0.75rem' }}>
                  Escala atual: <strong>{fontScale}</strong>
                </p>
                <div style={{ display: 'flex', gap: '0.5rem' }}>
                  <Button variant="secondary" size="sm" onClick={decreaseFontSize}>
                    A-
                  </Button>
                  <Button variant="secondary" size="sm" onClick={resetFontSize}>
                    Restaurar
                  </Button>
                  <Button variant="secondary" size="sm" onClick={increaseFontSize}>
                    A+
                  </Button>
                </div>
              </div>

              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <div style={{ fontWeight: 700, fontSize: '0.9rem', marginBottom: '0.25rem' }}>Alto Contraste</div>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '0.75rem' }}>
                  Status: <strong>{highContrast ? 'Ativado' : 'Desativado'}</strong>
                </p>
                <Button
                  variant={highContrast ? 'primary' : 'secondary'}
                  size="sm"
                  onClick={toggleHighContrast}
                >
                  {highContrast ? 'Desativar Alto Contraste' : 'Ativar Alto Contraste'}
                </Button>
              </div>

              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <div style={{ fontWeight: 700, fontSize: '0.9rem', marginBottom: '0.25rem' }}>Foco de Navegação</div>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '0.75rem' }}>
                  Modo: <strong>{enhancedFocus ? 'Reforçado' : 'Padrão'}</strong>
                </p>
                <Button
                  variant={enhancedFocus ? 'primary' : 'secondary'}
                  size="sm"
                  onClick={toggleEnhancedFocus}
                >
                  {enhancedFocus ? 'Restaurar Foco Padrão' : 'Reforçar Foco de Teclado'}
                </Button>
              </div>

              <div style={{ padding: '1rem', backgroundColor: 'var(--bg-surface-subtle)', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-subtle)' }}>
                <div style={{ fontWeight: 700, fontSize: '0.9rem', marginBottom: '0.25rem' }}>Atalhos de Teclado</div>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '0.75rem' }}>
                  Guia completo de atalhos globais de navegação
                </p>
                <Button
                  variant="outline-primary"
                  size="sm"
                  onClick={() => setIsKeyboardModalOpen(true)}
                >
                  Abrir Guia de Atalhos
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
