import React from 'react';
import {
  Menu,
  RotateCw,
  Bell,
  SlidersHorizontal,
  ChevronRight,
  User,
  Calendar,
  Sparkles
} from 'lucide-react';
import Button from '../common/Button';
import { useFilters } from '../../context/FilterContext';
import { useNotifications } from '../../context/NotificationContext';
import { useAuth } from '../../context/AuthContext';
import { MOCK_LINES } from '../../data/mockData';

export default function Header({
  title,
  subtitle,
  breadcrumb,
  onOpenMobileSidebar,
  onNavigate
}) {
  const {
    period,
    setPeriod,
    selectedLine,
    setSelectedLine,
    isRefreshing,
    refreshData,
    customDates,
    setCustomDates
  } = useFilters();

  const { toggleDrawer, unreadCount } = useNotifications();
  const { user } = useAuth();

  return (
    <header className="app-header">
      <div className="header-left">
        {/* Botão Mobile para Abrir Sidebar */}
        <button
          type="button"
          className="btn btn-ghost btn-icon"
          onClick={onOpenMobileSidebar}
          style={{ display: 'none' }}
          id="mobile-menu-trigger"
          aria-label="Abrir menu de navegação"
        >
          <Menu size={22} />
        </button>

        {/* Título da Página e Breadcrumbs */}
        <div className="header-title-group">
          {breadcrumb && (
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.35rem',
                fontSize: '0.75rem',
                color: 'var(--text-muted)',
                marginBottom: '2px'
              }}
            >
              <span>SEMOB-SCS</span>
              <ChevronRight size={12} />
              <span>{breadcrumb}</span>
            </div>
          )}
          <h1>{title}</h1>
          {subtitle && <p>{subtitle}</p>}
        </div>
      </div>

      {/* Controles de Período, Atualização, Notificações e Perfil */}
      <div className="header-right">
        {/* Seletor Rápido de Período */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            backgroundColor: 'var(--bg-surface-subtle)',
            borderRadius: 'var(--radius-md)',
            padding: '3px',
            border: '1px solid var(--border-subtle)'
          }}
          className="period-selector-container"
        >
          {['hoje', 'semana', 'mes', 'custom'].map((p) => {
            const labels = { hoje: 'Hoje', semana: 'Semana', mes: 'Mês', custom: 'Personalizado' };
            const isSelected = period === p;
            return (
              <button
                key={p}
                type="button"
                onClick={() => setPeriod(p)}
                style={{
                  border: 'none',
                  backgroundColor: isSelected ? 'var(--color-primary-blue)' : 'transparent',
                  color: isSelected ? '#FFFFFF' : 'var(--text-secondary)',
                  padding: '0.35rem 0.7rem',
                  borderRadius: 'var(--radius-sm)',
                  fontSize: '0.78rem',
                  fontWeight: isSelected ? 700 : 500,
                  cursor: 'pointer',
                  transition: 'all var(--transition-fast)'
                }}
              >
                {labels[p]}
              </button>
            );
          })}
        </div>

        {/* Se for Personalizado, mostra os campos de data */}
        {period === 'custom' && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '0.78rem' }}>
            <input
              type="date"
              value={customDates.start}
              onChange={(e) => setCustomDates({ ...customDates, start: e.target.value })}
              style={{
                border: '1px solid var(--border-default)',
                borderRadius: 'var(--radius-sm)',
                padding: '0.25rem 0.5rem',
                fontSize: '0.78rem',
                backgroundColor: 'var(--bg-surface)'
              }}
              aria-label="Data inicial"
            />
            <span style={{ color: 'var(--text-muted)' }}>até</span>
            <input
              type="date"
              value={customDates.end}
              onChange={(e) => setCustomDates({ ...customDates, end: e.target.value })}
              style={{
                border: '1px solid var(--border-default)',
                borderRadius: 'var(--radius-sm)',
                padding: '0.25rem 0.5rem',
                fontSize: '0.78rem',
                backgroundColor: 'var(--bg-surface)'
              }}
              aria-label="Data final"
            />
          </div>
        )}

        {/* Botão Atualizar Dados da Smart Data */}
        <Button
          variant="outline-primary"
          size="sm"
          onClick={refreshData}
          isLoading={isRefreshing}
          icon={<RotateCw size={14} className={isRefreshing ? 'spin-icon' : ''} />}
          title="Sincronizar telemetria e dados com a base Smart Data"
        >
          <span className="btn-text-desktop">Atualizar Dados</span>
        </Button>

        {/* Botão de Sino com Badge de Notificações */}
        <button
          type="button"
          className="btn btn-secondary btn-icon"
          onClick={toggleDrawer}
          aria-label={`Notificações: ${unreadCount} não lidas`}
          title="Abrir Central de Notificações"
          style={{ position: 'relative', width: '38px', height: '38px' }}
        >
          <Bell size={18} color="var(--color-primary-navy)" />
          {unreadCount > 0 && (
            <span
              style={{
                position: 'absolute',
                top: '-3px',
                right: '-3px',
                backgroundColor: 'var(--status-danger)',
                color: '#FFFFFF',
                fontSize: '0.65rem',
                fontWeight: 800,
                width: '18px',
                height: '18px',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                border: '2px solid var(--bg-surface)'
              }}
            >
              {unreadCount}
            </span>
          )}
        </button>

        {/* Perfil Rápido do Usuário */}
        <button
          type="button"
          className="btn btn-ghost"
          onClick={() => onNavigate('/configuracoes')}
          title="Ver perfil e configurações"
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
            padding: '0.35rem 0.65rem',
            borderRadius: 'var(--radius-md)',
            border: '1px solid var(--border-subtle)'
          }}
        >
          <div
            style={{
              width: '28px',
              height: '28px',
              borderRadius: '50%',
              backgroundColor: 'var(--color-primary-blue)',
              color: '#FFFFFF',
              fontSize: '0.75rem',
              fontWeight: 700,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}
          >
            {user?.initials || 'LG'}
          </div>
          <span style={{ fontSize: '0.8rem', fontWeight: 600, color: 'var(--text-primary)' }} className="btn-text-desktop">
            {user?.name?.split(' ')[0]}
          </span>
        </button>
      </div>

      <style>{`
        @media (max-width: 1024px) {
          #mobile-menu-trigger {
            display: inline-flex !important;
          }
          .period-selector-container {
            display: none !important;
          }
          .btn-text-desktop {
            display: none !important;
          }
        }
      `}</style>
    </header>
  );
}
