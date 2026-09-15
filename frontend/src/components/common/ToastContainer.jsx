import React from 'react';
import { CheckCircle2, Info, AlertCircle, X } from 'lucide-react';
import { useFilters } from '../../context/FilterContext';

export default function ToastContainer() {
  const { toasts, removeToast } = useFilters();

  if (!toasts || toasts.length === 0) return null;

  return (
    <div className="toast-container" role="region" aria-label="Notificações do sistema">
      {toasts.map((toast) => (
        <div key={toast.id} className={`toast toast-${toast.type || 'info'}`}>
          <div style={{ flexShrink: 0 }}>
            {toast.type === 'success' && <CheckCircle2 size={20} color="var(--status-success)" />}
            {toast.type === 'info' && <Info size={20} color="var(--color-blue-accent)" />}
            {toast.type === 'warning' && <AlertCircle size={20} color="var(--status-warning)" />}
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 700, fontSize: '0.85rem' }}>{toast.title}</div>
            <div style={{ fontSize: '0.78rem', opacity: 0.9 }}>{toast.message}</div>
          </div>
          <button
            type="button"
            onClick={() => removeToast(toast.id)}
            style={{
              background: 'transparent',
              border: 'none',
              color: '#FFFFFF',
              cursor: 'pointer',
              opacity: 0.7,
              display: 'flex',
              alignItems: 'center',
              padding: '2px'
            }}
            aria-label="Fechar notificação"
          >
            <X size={16} />
          </button>
        </div>
      ))}
    </div>
  );
}
