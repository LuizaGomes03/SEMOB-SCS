import React, { useState } from 'react';

export default function Tooltip({ text, children, position = 'top' }) {
  const [isVisible, setIsVisible] = useState(false);

  return (
    <div
      style={{ position: 'relative', display: 'inline-flex', alignItems: 'center' }}
      onMouseEnter={() => setIsVisible(true)}
      onMouseLeave={() => setIsVisible(false)}
      onFocus={() => setIsVisible(true)}
      onBlur={() => setIsVisible(false)}
      tabIndex={0}
      role="tooltip"
      aria-label={text}
    >
      {children}
      {isVisible && text && (
        <div
          style={{
            position: 'absolute',
            bottom: position === 'top' ? 'calc(100% + 8px)' : 'auto',
            top: position === 'bottom' ? 'calc(100% + 8px)' : 'auto',
            left: '50%',
            transform: 'translateX(-50%)',
            backgroundColor: 'var(--color-primary-navy)',
            color: '#FFFFFF',
            padding: '0.45rem 0.75rem',
            borderRadius: 'var(--radius-sm)',
            fontSize: '0.75rem',
            lineHeight: 1.35,
            whiteSpace: 'normal',
            width: 'max-content',
            maxWidth: '260px',
            boxShadow: 'var(--shadow-lg)',
            zIndex: 999,
            pointerEvents: 'none',
            border: '1px solid rgba(255,255,255,0.15)',
            textAlign: 'center'
          }}
        >
          {text}
        </div>
      )}
    </div>
  );
}
