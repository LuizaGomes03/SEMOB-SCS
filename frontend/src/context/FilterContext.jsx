import React, { createContext, useContext, useState } from 'react';

const FilterContext = createContext();

export function FilterProvider({ children }) {
  const [period, setPeriod] = useState('hoje');
  const [selectedLine, setSelectedLine] = useState('todas');
  const [customDates, setCustomDates] = useState({
    start: '2026-09-01',
    end: '2026-09-14'
  });
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [toasts, setToasts] = useState([
    {
      id: 1,
      type: 'info',
      title: 'Sistema Conectado',
      message: 'Base preliminar Smart Data sincronizada com sucesso.'
    }
  ]);

  const addToast = (title, message, type = 'info') => {
    const id = Date.now();
    setToasts((prev) => [...prev, { id, title, message, type }]);
    setTimeout(() => {
      removeToast(id);
    }, 4000);
  };

  const removeToast = (id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  const refreshData = async () => {
    setIsRefreshing(true);
    await new Promise((resolve) => setTimeout(resolve, 800));
    setIsRefreshing(false);
    addToast(
      'Dados Atualizados',
      'Registros operacionais sincronizados com a telemetria Smart Data.',
      'success'
    );
  };

  return (
    <FilterContext.Provider
      value={{
        period,
        setPeriod,
        selectedLine,
        setSelectedLine,
        customDates,
        setCustomDates,
        isRefreshing,
        refreshData,
        toasts,
        addToast,
        removeToast
      }}
    >
      {children}
    </FilterContext.Provider>
  );
}

export function useFilters() {
  const context = useContext(FilterContext);
  if (!context) {
    throw new Error('useFilters deve ser utilizado dentro de FilterProvider');
  }
  return context;
}
