import React from 'react';
import {
  LayoutDashboard,
  Bus,
  Users,
  DollarSign,
  AlertTriangle,
  FileText,
  Settings,
  ChevronLeft,
  ChevronRight,
  LogOut,
  ShieldCheck,
  X
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

export default function Sidebar({
  currentPath,
  onNavigate,
  isCollapsed,
  setIsCollapsed,
  isMobileOpen,
  setIsMobileOpen
}) {
  const { user, logout } = useAuth();

  const navItems = [
    { path: '/dashboard', label: 'Dashboard', icon: <LayoutDashboard size={19} /> },
    { path: '/operacao', label: 'Operação', icon: <Bus size={19} /> },
    { path: '/passageiros', label: 'Passageiros', icon: <Users size={19} /> },
    { path: '/financeiro', label: 'Financeiro', icon: <DollarSign size={19} /> },
    { path: '/anomalias', label: 'Anomalias e Alertas', icon: <AlertTriangle size={19} />, badge: 3 },
    { path: '/relatorios', label: 'Relatórios', icon: <FileText size={19} /> },
    { path: '/configuracoes', label: 'Configurações', icon: <Settings size={19} /> }
  ];

  const handleNavClick = (path) => {
    onNavigate(path);
    if (setIsMobileOpen) setIsMobileOpen(false);
  };

  const handleLogout = () => {
    logout();
    onNavigate('/login');
    if (setIsMobileOpen) setIsMobileOpen(false);
  };

  return (
    <>
      {isMobileOpen && (
        <div
          className="sidebar-backdrop"
          onClick={() => setIsMobileOpen(false)}
          aria-hidden="true"
        />
      )}

      <aside
        id="sidebar-nav"
        className={`app-sidebar ${isCollapsed ? 'collapsed' : ''} ${
          isMobileOpen ? 'mobile-open' : ''
        }`}
        aria-label="Navegação Principal do Sistema"
      >
        {/* Cabeçalho da Sidebar / Identificação Institucional */}
        <div className="sidebar-header">
          <div className="brand-badge">
            <div className="brand-icon" title="SEMOB São Caetano do Sul">
              <Bus size={22} color="#FFFFFF" />
            </div>
            {!isCollapsed && (
              <div className="brand-text">
                <span className="brand-title">SEMOB-SCS</span>
                <span className="brand-sub">Operação Municipal</span>
              </div>
            )}
          </div>

          {/* Botão de Fechar Mobile ou Recolher Desktop */}
          {isMobileOpen ? (
            <button
              type="button"
              className="btn btn-ghost btn-icon"
              onClick={() => setIsMobileOpen(false)}
              style={{ color: '#FFFFFF', width: '32px', height: '32px' }}
              aria-label="Fechar menu"
            >
              <X size={20} />
            </button>
          ) : (
            <button
              type="button"
              className="btn btn-ghost btn-icon"
              onClick={() => setIsCollapsed(!isCollapsed)}
              style={{ color: '#94A3B8', width: '30px', height: '30px' }}
              aria-label={isCollapsed ? 'Expandir menu lateral' : 'Recolher menu lateral'}
              title={isCollapsed ? 'Expandir menu' : 'Recolher menu'}
            >
              {isCollapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
            </button>
          )}
        </div>

        {/* Links de Navegação */}
        <nav className="sidebar-nav">
          {!isCollapsed && (
            <span className="nav-section-label">Módulos de Gestão</span>
          )}

          {navItems.map((item) => {
            const isActive = currentPath === item.path;
            return (
              <button
                key={item.path}
                type="button"
                className={`nav-item ${isActive ? 'active' : ''}`}
                onClick={() => handleNavClick(item.path)}
                title={isCollapsed ? item.label : undefined}
                aria-current={isActive ? 'page' : undefined}
              >
                {item.icon}
                {!isCollapsed && <span>{item.label}</span>}
                {!isCollapsed && item.badge && (
                  <span className="nav-item-badge">{item.badge}</span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Rodapé da Sidebar com Gestor Conectado */}
        <div className="sidebar-footer">
          <div className="user-avatar" title={user?.name}>
            {user?.initials || 'LG'}
          </div>
          {!isCollapsed && (
            <div className="user-info" style={{ flex: 1 }}>
              <span className="user-name">{user?.name}</span>
              <span className="user-role">{user?.role}</span>
            </div>
          )}
          <button
            type="button"
            onClick={handleLogout}
            className="btn btn-ghost btn-icon"
            title="Sair do sistema (Logout)"
            aria-label="Sair da conta"
            style={{ color: '#EF4444', width: '32px', height: '32px', marginLeft: 'auto' }}
          >
            <LogOut size={16} />
          </button>
        </div>
      </aside>
    </>
  );
}
