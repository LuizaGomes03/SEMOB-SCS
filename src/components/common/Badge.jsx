import React from 'react';

export default function Badge({ children, variant = 'info', size = 'md', icon }) {
  const variantClass = {
    success: 'badge-success',
    warning: 'badge-warning',
    danger: 'badge-danger',
    info: 'badge-info',
    neutral: 'badge-neutral'
  }[variant] || 'badge-neutral';

  return (
    <span className={`badge ${variantClass} badge-${size}`}>
      {icon && <span style={{ display: 'inline-flex', alignItems: 'center' }}>{icon}</span>}
      <span>{children}</span>
    </span>
  );
}
