import React, { createContext, useContext, useState, useEffect } from 'react';

const AccessibilityContext = createContext();

const FONT_SCALES = ['small', 'normal', 'large', 'xlarge'];

export function AccessibilityProvider({ children }) {
  const [fontScaleIndex, setFontScaleIndex] = useState(1); // 1 = 'normal'
  const [highContrast, setHighContrast] = useState(false);
  const [enhancedFocus, setEnhancedFocus] = useState(false);
  const [isKeyboardModalOpen, setIsKeyboardModalOpen] = useState(false);
  const [vlibrasActive, setVlibrasActive] = useState(false);

  // Sincroniza atributos no elemento HTML
  useEffect(() => {
    const scale = FONT_SCALES[fontScaleIndex];
    document.documentElement.setAttribute('data-font-scale', scale);
  }, [fontScaleIndex]);

  useEffect(() => {
    if (highContrast) {
      document.documentElement.classList.add('high-contrast');
    } else {
      document.documentElement.classList.remove('high-contrast');
    }
  }, [highContrast]);

  useEffect(() => {
    if (enhancedFocus) {
      document.documentElement.classList.add('enhanced-focus');
    } else {
      document.documentElement.classList.remove('enhanced-focus');
    }
  }, [enhancedFocus]);

  const increaseFontSize = () => {
    setFontScaleIndex((prev) => Math.min(prev + 1, FONT_SCALES.length - 1));
  };

  const decreaseFontSize = () => {
    setFontScaleIndex((prev) => Math.max(prev - 1, 0));
  };

  const resetFontSize = () => {
    setFontScaleIndex(1);
  };

  const toggleHighContrast = () => {
    setHighContrast((prev) => !prev);
  };

  const toggleEnhancedFocus = () => {
    setEnhancedFocus((prev) => !prev);
  };

  const toggleVlibras = () => {
    setVlibrasActive((prev) => !prev);
    // Simula ou aciona o clique no botão do VLibras se existir no DOM
    const vlibrasBtn = document.querySelector('[vw-access-button]');
    if (vlibrasBtn) {
      vlibrasBtn.click();
    }
  };

  return (
    <AccessibilityContext.Provider
      value={{
        fontScale: FONT_SCALES[fontScaleIndex],
        fontScaleIndex,
        increaseFontSize,
        decreaseFontSize,
        resetFontSize,
        highContrast,
        toggleHighContrast,
        enhancedFocus,
        toggleEnhancedFocus,
        isKeyboardModalOpen,
        setIsKeyboardModalOpen,
        vlibrasActive,
        toggleVlibras
      }}
    >
      {children}
    </AccessibilityContext.Provider>
  );
}

export function useAccessibility() {
  const context = useContext(AccessibilityContext);
  if (!context) {
    throw new Error('useAccessibility deve ser utilizado dentro de AccessibilityProvider');
  }
  return context;
}
