import React, { useState, useEffect } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { FilterProvider, useFilters } from './context/FilterContext';
import { AccessibilityProvider } from './context/AccessibilityContext';
import { NotificationProvider } from './context/NotificationContext';

// Layout
import AccessibilityBar from './components/layout/AccessibilityBar';
import Header from './components/layout/Header';
import Sidebar from './components/layout/Sidebar';
import NotificationDrawer from './components/layout/NotificationDrawer';
import AccessibilityModal from './components/layout/AccessibilityModal';
import ToastContainer from './components/common/ToastContainer';

// Páginas
import LoginPage from './pages/Login/LoginPage';
import DashboardPage from './pages/Dashboard/DashboardPage';
import OperacaoPage from './pages/Operacao/OperacaoPage';
import PassageirosPage from './pages/Passageiros/PassageirosPage';
import FinanceiroPage from './pages/Financeiro/FinanceiroPage';
import AnomaliasPage from './pages/Anomalias/AnomaliasPage';
import RelatoriosPage from './pages/Relatorios/RelatoriosPage';
import DetalhesOperacaoPage from './pages/DetalhesOperacao/DetalhesOperacaoPage';
import ConfiguracoesPage from './pages/Configuracoes/ConfiguracoesPage';

function MainAppContent() {
  const { isAuthenticated } = useAuth();
  const { refreshData } = useFilters();

  const [currentPath, setCurrentPath] = useState('/dashboard');
  const [previousPath, setPreviousPath] = useState('/dashboard');
  const [selectedDetailRow, setSelectedDetailRow] = useState(null);
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

  // Navegação centralizada
  const navigate = (path) => {
    if (path !== currentPath) {
      setPreviousPath(currentPath);
      setCurrentPath(path);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  // Atalhos Globais de Teclado (Alt + 1..7, Alt + R)
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.altKey) {
        if (e.key === '1') { e.preventDefault(); navigate('/dashboard'); }
        if (e.key === '2') { e.preventDefault(); navigate('/operacao'); }
        if (e.key === '3') { e.preventDefault(); navigate('/passageiros'); }
        if (e.key === '4') { e.preventDefault(); navigate('/financeiro'); }
        if (e.key === '5') { e.preventDefault(); navigate('/anomalias'); }
        if (e.key === '6') { e.preventDefault(); navigate('/relatorios'); }
        if (e.key === '7') { e.preventDefault(); navigate('/configuracoes'); }
        if (e.key.toLowerCase() === 'r') { e.preventDefault(); refreshData(); }
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentPath]);

  // Se não estiver logado ou estiver na rota de login, renderiza tela de login
  if (!isAuthenticated || currentPath === '/login') {
    return (
      <LoginPage
        onLoginSuccess={() => {
          navigate('/dashboard');
        }}
      />
    );
  }

  // Metadados da página atual para o Header
  const pageMeta = {
    '/dashboard': {
      title: 'Dashboard de Operação',
      subtitle: 'Visão consolidada da operação de transporte municipal de São Caetano do Sul',
      breadcrumb: 'Painel Geral'
    },
    '/operacao': {
      title: 'Operação de Transporte',
      subtitle: 'Análise detalhada de quilometragem e viagens por linha municipal',
      breadcrumb: 'Operação'
    },
    '/passageiros': {
      title: 'Passageiros e Bilhetagem',
      subtitle: 'Acompanhamento de demanda de passageiros pagantes e gratuidades',
      breadcrumb: 'Passageiros'
    },
    '/financeiro': {
      title: 'Informações Financeiras',
      subtitle: 'Acompanhamento consolidado de valores operacionais (Dados Demonstrativos)',
      breadcrumb: 'Financeiro'
    },
    '/anomalias': {
      title: 'Anomalias e Alertas',
      subtitle: 'Auditoria de desvios operacionais e inconsistências na telemetria',
      breadcrumb: 'Anomalias'
    },
    '/relatorios': {
      title: 'Relatórios da Operação',
      subtitle: 'Consolidação periódica e exportação para prestação de contas aos gestores',
      breadcrumb: 'Relatórios'
    },
    '/detalhes': {
      title: 'Detalhamento da Operação',
      subtitle: 'Análise aprofundada por viagem, linha e faixas horárias',
      breadcrumb: 'Detalhamento'
    },
    '/configuracoes': {
      title: 'Perfil e Configurações',
      subtitle: 'Dados institucionais do gestor e preferências operacionais do sistema',
      breadcrumb: 'Configurações'
    }
  }[currentPath] || {
    title: 'SEMOB-SCS',
    subtitle: 'Dashboard de Operação',
    breadcrumb: 'Início'
  };

  return (
    <div className="app-layout">
      {/* Sidebar Lateral Institucional */}
      <Sidebar
        currentPath={currentPath}
        onNavigate={navigate}
        isCollapsed={isSidebarCollapsed}
        setIsCollapsed={setIsSidebarCollapsed}
        isMobileOpen={isMobileSidebarOpen}
        setIsMobileOpen={setIsMobileSidebarOpen}
      />

      {/* Conteúdo Principal com Topbar e Header */}
      <div className="main-wrapper">
        <AccessibilityBar />

        <Header
          title={pageMeta.title}
          subtitle={pageMeta.subtitle}
          breadcrumb={pageMeta.breadcrumb}
          onOpenMobileSidebar={() => setIsMobileSidebarOpen(true)}
          onNavigate={navigate}
        />

        <main id="main-content" className="page-content" role="main">
          {currentPath === '/dashboard' && <DashboardPage onNavigate={navigate} />}
          {currentPath === '/operacao' && (
            <OperacaoPage
              onNavigate={navigate}
              onSelectDetail={(row) => setSelectedDetailRow(row)}
            />
          )}
          {currentPath === '/passageiros' && <PassageirosPage />}
          {currentPath === '/financeiro' && <FinanceiroPage />}
          {currentPath === '/anomalias' && <AnomaliasPage />}
          {currentPath === '/relatorios' && <RelatoriosPage />}
          {currentPath === '/detalhes' && (
            <DetalhesOperacaoPage
              detailItem={selectedDetailRow}
              onBack={() => navigate(previousPath || '/operacao')}
            />
          )}
          {currentPath === '/configuracoes' && <ConfiguracoesPage onNavigate={navigate} />}
        </main>
      </div>

      {/* Gaveta de Notificações */}
      <NotificationDrawer onNavigate={navigate} />

      {/* Modal de Acessibilidade */}
      <AccessibilityModal />

      {/* Notificações Toasts Flutuantes */}
      <ToastContainer />
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <FilterProvider>
        <AccessibilityProvider>
          <NotificationProvider>
            <MainAppContent />
          </NotificationProvider>
        </AccessibilityProvider>
      </FilterProvider>
    </AuthProvider>
  );
}
