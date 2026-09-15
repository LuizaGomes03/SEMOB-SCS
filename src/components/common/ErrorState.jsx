import React from 'react';
import { AlertTriangle } from 'lucide-react';
import Button from './Button';

export default function ErrorState({
  title = 'Erro ao carregar dados operacionais',
  description = 'Não foi possível estabelecer comunicação com o consolidador Smart Data. Tente novamente em instantes.',
  onRetry
}) {
  return (
    <div className="state-container" style={{ border: '1px dashed var(--status-danger-border)', borderRadius: 'var(--radius-lg)' }}>
      <div className="state-icon" style={{ backgroundColor: 'var(--status-danger-bg)', color: 'var(--status-danger)' }}>
        <AlertTriangle size={32} />
      </div>
      <h3 className="state-title" style={{ color: 'var(--status-danger)' }}>{title}</h3>
      <p className="state-description">{description}</p>
      {onRetry && (
        <Button variant="danger" size="sm" onClick={onRetry}>
          Tentar Novamente
        </Button>
      )}
    </div>
  );
}
