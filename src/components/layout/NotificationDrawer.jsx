import React from 'react';
import { useNotifications } from '../../context/NotificationContext';
import { X, CheckCheck, Trash2, Bell, AlertTriangle, Info, CheckCircle2 } from 'lucide-react';
import EmptyState from '../common/EmptyState';

export default function NotificationDrawer({ onNavigate }) {
  const {
    isDrawerOpen,
    setIsDrawerOpen,
    notifications,
    allNotifications,
    unreadCount,
    markAsRead,
    markAllAsRead,
    clearAll,
    activeCategory,
    setActiveCategory
  } = useNotifications();

  if (!isDrawerOpen) return null;

  const categories = ['Todas', 'Alertas', 'Informações', 'Atualizações'];

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(11, 25, 44, 0.5)',
        backdropFilter: 'blur(2px)',
        zIndex: 1050,
        display: 'flex',
        justifyContent: 'flex-end',
        animation: 'fadeIn 150ms ease-out'
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget) setIsDrawerOpen(false);
      }}
    >
      <div
        style={{
          width: '100%',
          maxWidth: '420px',
          height: '100%',
          backgroundColor: 'var(--bg-surface)',
          boxShadow: 'var(--shadow-drawer)',
          display: 'flex',
          flexDirection: 'column',
          borderLeft: '1px solid var(--border-subtle)',
          animation: 'slideInRight 250ms ease-out'
        }}
      >
        {/* Header da Gaveta de Notificações */}
        <div
          style={{
            padding: '1.25rem 1.5rem',
            borderBottom: '1px solid var(--border-subtle)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            backgroundColor: 'var(--bg-surface-subtle)'
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <Bell size={20} color="var(--color-primary-blue)" />
            <h3 style={{ fontSize: '1.1rem', fontWeight: 700, color: 'var(--color-primary-navy)' }}>
              Central de Notificações
            </h3>
            {unreadCount > 0 && (
              <span
                style={{
                  backgroundColor: 'var(--status-danger)',
                  color: '#FFFFFF',
                  fontSize: '0.725rem',
                  fontWeight: 700,
                  padding: '0.15rem 0.45rem',
                  borderRadius: 'var(--radius-full)'
                }}
              >
                {unreadCount} nova{unreadCount > 1 ? 's' : ''}
              </span>
            )}
          </div>
          <button
            type="button"
            className="btn btn-ghost btn-icon"
            onClick={() => setIsDrawerOpen(false)}
            aria-label="Fechar notificações"
            style={{ width: '32px', height: '32px' }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Barra de Filtro de Categorias */}
        <div
          style={{
            display: 'flex',
            padding: '0.75rem 1.5rem',
            gap: '0.5rem',
            borderBottom: '1px solid var(--border-subtle)',
            overflowX: 'auto'
          }}
        >
          {categories.map((cat) => (
            <button
              key={cat}
              type="button"
              onClick={() => setActiveCategory(cat)}
              style={{
                background: activeCategory === cat ? 'var(--color-primary-blue)' : 'transparent',
                color: activeCategory === cat ? '#FFFFFF' : 'var(--text-secondary)',
                border: 'none',
                padding: '0.35rem 0.75rem',
                borderRadius: 'var(--radius-sm)',
                fontSize: '0.78rem',
                fontWeight: activeCategory === cat ? 700 : 500,
                cursor: 'pointer',
                whiteSpace: 'nowrap'
              }}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Ações Rápidas: Marcar todas lidas / Limpar */}
        <div
          style={{
            padding: '0.5rem 1.5rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            borderBottom: '1px solid var(--border-subtle)',
            backgroundColor: 'var(--bg-surface)'
          }}
        >
          <button
            type="button"
            onClick={markAllAsRead}
            disabled={unreadCount === 0}
            style={{
              background: 'transparent',
              border: 'none',
              color: unreadCount === 0 ? 'var(--text-light)' : 'var(--color-primary-blue)',
              fontSize: '0.75rem',
              fontWeight: 600,
              cursor: unreadCount === 0 ? 'not-allowed' : 'pointer',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '0.35rem'
            }}
          >
            <CheckCheck size={14} />
            Marcar todas como lidas
          </button>

          <button
            type="button"
            onClick={clearAll}
            disabled={allNotifications.length === 0}
            style={{
              background: 'transparent',
              border: 'none',
              color: allNotifications.length === 0 ? 'var(--text-light)' : 'var(--status-danger)',
              fontSize: '0.75rem',
              fontWeight: 600,
              cursor: allNotifications.length === 0 ? 'not-allowed' : 'pointer',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '0.35rem'
            }}
          >
            <Trash2 size={13} />
            Limpar
          </button>
        </div>

        {/* Lista de Notificações */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '1rem 1.5rem', display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
          {notifications.length === 0 ? (
            <EmptyState
              title={allNotifications.length === 0 ? 'Nenhuma notificação' : 'Todas lidas nesta categoria'}
              description={allNotifications.length === 0 ? 'A central de notificações está limpa.' : 'Não há avisos pendentes para o filtro atual.'}
              icon={<Bell size={32} color="var(--text-muted)" />}
            />
          ) : (
            notifications.map((notif) => {
              const iconMap = {
                danger: <AlertTriangle size={18} color="var(--status-danger)" />,
                warning: <AlertTriangle size={18} color="var(--status-warning)" />,
                info: <Info size={18} color="var(--color-blue-accent)" />,
                success: <CheckCircle2 size={18} color="var(--status-success)" />
              };

              return (
                <div
                  key={notif.id}
                  onClick={() => {
                    markAsRead(notif.id);
                    if (onNavigate && notif.link) {
                      setIsDrawerOpen(false);
                      onNavigate(notif.link);
                    }
                  }}
                  style={{
                    padding: '0.85rem',
                    borderRadius: 'var(--radius-md)',
                    border: '1px solid var(--border-subtle)',
                    backgroundColor: notif.read ? 'var(--bg-surface)' : 'var(--color-blue-light)',
                    cursor: 'pointer',
                    transition: 'all var(--transition-fast)',
                    position: 'relative'
                  }}
                >
                  <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'flex-start' }}>
                    <div style={{ marginTop: '2px', flexShrink: 0 }}>
                      {iconMap[notif.severity] || <Bell size={18} />}
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '0.5rem', marginBottom: '2px' }}>
                        <span style={{ fontWeight: notif.read ? 600 : 700, fontSize: '0.85rem', color: 'var(--color-primary-navy)' }}>
                          {notif.title}
                        </span>
                        {!notif.read && (
                          <span
                            style={{
                              width: '8px',
                              height: '8px',
                              borderRadius: '50%',
                              backgroundColor: 'var(--color-primary-blue)',
                              display: 'inline-block'
                            }}
                          />
                        )}
                      </div>
                      <p style={{ fontSize: '0.78rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>
                        {notif.description}
                      </p>
                      <span style={{ fontSize: '0.7rem', color: 'var(--text-muted)' }}>
                        {notif.time}
                      </span>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </div>
  );
}
