import React from 'react';
import { Eye, Type, Keyboard, HelpCircle } from 'lucide-react';
import { useAccessibility } from '../../context/AccessibilityContext';

export default function AccessibilityBar() {
  const {
    increaseFontSize,
    decreaseFontSize,
    resetFontSize,
    fontScale,
    highContrast,
    toggleHighContrast,
    enhancedFocus,
    toggleEnhancedFocus,
    setIsKeyboardModalOpen,
    vlibrasActive,
    toggleVlibras
  } = useAccessibility();

  return (
    <nav className="accessibility-topbar" aria-label="Barra de Acessibilidade Institucional">
      <div className="topbar-links">
        <a href="#main-content" className="topbar-btn" title="Pular direto para a área de conteúdo">
          Ir para o conteúdo [1]
        </a>
        <a href="#sidebar-nav" className="topbar-btn" title="Ir para o menu de navegação">
          Ir para o menu [2]
        </a>
        <button
          type="button"
          className="topbar-btn"
          onClick={() => setIsKeyboardModalOpen(true)}
          title="Ver atalhos de teclado e recursos de acessibilidade"
        >
          <Keyboard size={13} />
          <span>Atalhos de Teclado</span>
        </button>
      </div>

      <div className="topbar-actions">
        {/* Controle de Redimensionamento de Fonte */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '2px', background: 'rgba(255,255,255,0.06)', borderRadius: '4px', padding: '1px' }}>
          <button
            type="button"
            className="topbar-btn"
            onClick={decreaseFontSize}
            title="Diminuir tamanho da fonte (A-)"
            aria-label="Diminuir fonte"
          >
            A-
          </button>
          <button
            type="button"
            className="topbar-btn"
            onClick={resetFontSize}
            title="Restaurar tamanho padrão da fonte (A)"
            aria-label="Tamanho padrão de fonte"
            style={{ fontWeight: 700 }}
          >
            A ({fontScale})
          </button>
          <button
            type="button"
            className="topbar-btn"
            onClick={increaseFontSize}
            title="Aumentar tamanho da fonte (A+)"
            aria-label="Aumentar fonte"
          >
            A+
          </button>
        </div>

        {/* Alternador de Alto Contraste */}
        <button
          type="button"
          className="topbar-btn"
          onClick={toggleHighContrast}
          aria-pressed={highContrast}
          title="Ativar/Desativar modo de Alto Contraste"
        >
          <Eye size={13} />
          <span>{highContrast ? 'Contraste Normal' : 'Alto Contraste'}</span>
        </button>

        {/* Alternador de Foco Visível para Teclado */}
        <button
          type="button"
          className="topbar-btn"
          onClick={toggleEnhancedFocus}
          aria-pressed={enhancedFocus}
          title="Reforçar indicador visual de foco para navegação por teclado"
        >
          <span>Foco Visível: {enhancedFocus ? 'Ativo' : 'Padrão'}</span>
        </button>

        {/* Integração VLibras */}
        <button
          type="button"
          className="topbar-btn"
          onClick={toggleVlibras}
          title="Tradutor de Libras - Língua Brasileira de Sinais"
          style={{
            backgroundColor: vlibrasActive ? 'var(--color-primary-blue)' : 'transparent',
            color: '#FFFFFF'
          }}
        >
          <span>VLibras</span>
        </button>
      </div>
    </nav>
  );
}
