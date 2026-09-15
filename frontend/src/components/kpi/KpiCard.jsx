import React from 'react';
import { ArrowUpRight, ArrowDownRight, Minus, HelpCircle } from 'lucide-react';
import Tooltip from '../common/Tooltip';
import Skeleton from '../common/Skeleton';

export default function KpiCard({
  title,
  value,
  unit,
  change,
  trend = 'neutral',
  previousLabel = 'vs. período anterior',
  icon,
  iconBg = 'var(--color-blue-light)',
  iconColor = 'var(--color-primary-blue)',
  tooltip,
  isLoading = false,
  onClick
}) {
  if (isLoading) {
    return (
      <div className="kpi-card">
        <div className="kpi-header">
          <Skeleton width="60%" height="16px" />
          <Skeleton width="38px" height="38px" borderRadius="var(--radius-md)" />
        </div>
        <div className="kpi-value-group">
          <Skeleton width="80%" height="36px" />
        </div>
        <div className="kpi-footer">
          <Skeleton width="50%" height="14px" />
        </div>
      </div>
    );
  }

  const isPositive = change > 0;
  const isNegative = change < 0;

  // Formata o valor numérico com separador de milhar brasileiro
  const formattedValue =
    typeof value === 'number'
      ? value.toLocaleString('pt-BR')
      : value;

  return (
    <div
      className="kpi-card"
      onClick={onClick}
      style={{ cursor: onClick ? 'pointer' : 'default' }}
    >
      <div className="kpi-header">
        <span className="kpi-title">
          {title}
          {tooltip && (
            <Tooltip text={tooltip}>
              <span
                style={{
                  cursor: 'help',
                  color: 'var(--text-muted)',
                  display: 'inline-flex',
                  alignItems: 'center'
                }}
              >
                <HelpCircle size={14} />
              </span>
            </Tooltip>
          )}
        </span>
        <div
          className="kpi-icon-badge"
          style={{ backgroundColor: iconBg, color: iconColor }}
        >
          {icon}
        </div>
      </div>

      <div className="kpi-value-group">
        <span className="kpi-value">
          {unit === 'R$' && <span style={{ fontSize: '1.25rem', fontWeight: 600, marginRight: '4px' }}>R$</span>}
          {formattedValue}
        </span>
        {unit && unit !== 'R$' && <span className="kpi-unit">{unit}</span>}
      </div>

      <div className="kpi-footer">
        <span
          className={`trend-badge ${
            trend === 'up'
              ? 'trend-up'
              : trend === 'down'
              ? 'trend-down'
              : 'trend-neutral'
          }`}
        >
          {trend === 'up' && <ArrowUpRight size={14} />}
          {trend === 'down' && <ArrowDownRight size={14} />}
          {trend === 'neutral' && <Minus size={14} />}
          {isPositive ? `+${change}%` : `${change}%`}
        </span>
        <span style={{ color: 'var(--text-muted)', fontSize: '0.75rem' }}>
          {previousLabel}
        </span>
      </div>
    </div>
  );
}
