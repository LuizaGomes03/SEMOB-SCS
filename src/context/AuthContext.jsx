import React, { createContext, useContext, useState } from 'react';
import { CURRENT_USER } from '../data/mockData';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  // Inicia autenticado por padrão para facilidade de demonstração do painel,
  // permitindo alternar para deslogado ao clicar em "Sair da Conta".
  const [isAuthenticated, setIsAuthenticated] = useState(true);
  const [user, setUser] = useState(CURRENT_USER);

  const login = (email, password) => {
    return new Promise((resolve) => {
      setTimeout(() => {
        setIsAuthenticated(true);
        setUser({
          ...CURRENT_USER,
          email: email || CURRENT_USER.email
        });
        resolve({ success: true });
      }, 600);
    });
  };

  const logout = () => {
    setIsAuthenticated(false);
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, user, login, logout, setIsAuthenticated }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth deve ser utilizado dentro de AuthProvider');
  }
  return context;
}
