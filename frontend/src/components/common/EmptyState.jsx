import React from 'react';
import { Inbox } from 'lucide-react';
import Button from './Button';

export default function EmptyState({
  title = 'Nenhum registro encontrado',
  description = 'Não foram encontrados dados operacionais correspondentes aos filtros selecionados.',
  icon = <Inbox size={32} />,
  actionLabel,
  onAction
}) {
  return (
    <div className="state-container">
      <div className="state-icon">{icon}</div>
      <h3 className="state-title">{title}</h3>
      <p className="state-description">{description}</p>
      {actionLabel && onAction && (
        <Button variant="outline-primary" size="sm" onClick={onAction}>
          {actionLabel}
        </Button>
      )}
    </div>
  );
}
