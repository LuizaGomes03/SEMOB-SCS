import React, { useState } from 'react';
import { Bus, Mail, Lock, Eye, EyeOff, ShieldCheck, AlertCircle, ArrowRight } from 'lucide-react';
import Button from '../../components/common/Button';
import Modal from '../../components/common/Modal';
import { useAuth } from '../../context/AuthContext';

export default function LoginPage({ onLoginSuccess }) {
  const { login } = useAuth();
  const [email, setEmail] = useState('luiza.gomes@semob.saocaetanodosul.sp.gov.br');
  const [password, setPassword] = useState('••••••••••');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [isForgotModalOpen, setIsForgotModalOpen] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotSuccess, setForgotSuccess] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMessage('');

    if (!email.trim()) {
      setErrorMessage('Por favor, informe seu e-mail institucional.');
      return;
    }

    if (!email.includes('@')) {
      setErrorMessage('Formato de e-mail institucional inválido.');
      return;
    }

    if (!password) {
      setErrorMessage('Por favor, digite sua senha de acesso.');
      return;
    }

    setIsLoading(true);
    try {
      await login(email, password);
      setIsLoading(false);
      if (onLoginSuccess) {
        onLoginSuccess();
      }
    } catch (err) {
      setIsLoading(false);
      setErrorMessage('Não foi possível autenticar. Verifique suas credenciais.');
    }
  };

  const handleQuickLogin = (roleEmail) => {
    setEmail(roleEmail);
    setPassword('semob2026');
    setErrorMessage('');
  };

  const handleForgotSubmit = (e) => {
    e.preventDefault();
    if (!forgotEmail) return;
    setForgotSuccess(true);
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #0B192C 0%, #07111F 50%, #002B49 100%)',
        padding: '1.5rem',
        position: 'relative',
        overflow: 'hidden'
      }}
    >
      {/* Detalhes de Fundo Gráfico Institucional */}
      <div
        style={{
          position: 'absolute',
          top: '-15%',
          right: '-10%',
          width: '500px',
          height: '500px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(0, 86, 145, 0.25) 0%, transparent 70%)',
          pointerEvents: 'none'
        }}
      />
      <div
        style={{
          position: 'absolute',
          bottom: '-15%',
          left: '-10%',
          width: '450px',
          height: '450px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(2, 132, 199, 0.15) 0%, transparent 70%)',
          pointerEvents: 'none'
        }}
      />

      <div
        style={{
          width: '100%',
          maxWidth: '460px',
          backgroundColor: '#FFFFFF',
          borderRadius: 'var(--radius-xl)',
          boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.45)',
          overflow: 'hidden',
          zIndex: 10
        }}
      >
        {/* Cabeçalho da Caixa de Login */}
        <div
          style={{
            backgroundColor: 'var(--color-primary-navy)',
            padding: '2.25rem 2rem',
            textAlign: 'center',
            color: '#FFFFFF',
            borderBottom: '4px solid var(--color-primary-blue)',
            position: 'relative'
          }}
        >
          <div
            style={{
              width: '56px',
              height: '56px',
              borderRadius: 'var(--radius-lg)',
              background: 'linear-gradient(135deg, #005691, #0284C7)',
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              marginBottom: '1rem',
              boxShadow: '0 4px 14px rgba(0, 86, 145, 0.5)'
            }}
          >
            <Bus size={30} color="#FFFFFF" />
          </div>

          <div style={{ fontSize: '0.75rem', textTransform: 'uppercase', letterSpacing: '0.1em', color: 'var(--color-sky-soft)', fontWeight: 700 }}>
            Secretaria de Mobilidade Urbana — SEMOB-SCS
          </div>
          <h1 style={{ fontSize: '1.45rem', fontWeight: 800, color: '#FFFFFF', marginTop: '0.25rem' }}>
            Dashboard de Operação
          </h1>
          <p style={{ fontSize: '0.825rem', color: '#94A3B8', marginTop: '0.35rem' }}>
            Acesso restrito para gestores e técnicos municipais
          </p>
        </div>

        {/* Formulário de Login */}
        <div style={{ padding: '2rem' }}>
          {errorMessage && (
            <div
              style={{
                backgroundColor: 'var(--status-danger-bg)',
                border: '1px solid var(--status-danger-border)',
                color: 'var(--status-danger-text)',
                padding: '0.75rem 1rem',
                borderRadius: 'var(--radius-md)',
                fontSize: '0.825rem',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                marginBottom: '1.25rem'
              }}
              role="alert"
            >
              <AlertCircle size={18} flexShrink={0} />
              <span>{errorMessage}</span>
            </div>
          )}

          <form onSubmit={handleSubmit}>
            {/* Campo E-mail */}
            <div style={{ marginBottom: '1.25rem' }}>
              <label
                htmlFor="login-email"
                style={{
                  display: 'block',
                  fontSize: '0.825rem',
                  fontWeight: 600,
                  color: 'var(--text-primary)',
                  marginBottom: '0.4rem'
                }}
              >
                E-mail Institucional
              </label>
              <div style={{ position: 'relative' }}>
                <div
                  style={{
                    position: 'absolute',
                    left: '0.85rem',
                    top: '50%',
                    transform: 'translateY(-50%)',
                    color: 'var(--text-muted)'
                  }}
                >
                  <Mail size={18} />
                </div>
                <input
                  id="login-email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="gestor@semob.saocaetanodosul.sp.gov.br"
                  required
                  style={{
                    width: '100%',
                    padding: '0.7rem 0.85rem 0.7rem 2.4rem',
                    borderRadius: 'var(--radius-md)',
                    border: '1px solid var(--border-default)',
                    fontSize: '0.9rem',
                    backgroundColor: 'var(--bg-surface)'
                  }}
                />
              </div>
            </div>

            {/* Campo Senha */}
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.4rem' }}>
                <label
                  htmlFor="login-password"
                  style={{
                    fontSize: '0.825rem',
                    fontWeight: 600,
                    color: 'var(--text-primary)'
                  }}
                >
                  Senha de Acesso
                </label>
                <button
                  type="button"
                  onClick={() => setIsForgotModalOpen(true)}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: 'var(--color-primary-blue)',
                    fontSize: '0.78rem',
                    cursor: 'pointer',
                    textDecoration: 'none'
                  }}
                >
                  Esqueci minha senha
                </button>
              </div>

              <div style={{ position: 'relative' }}>
                <div
                  style={{
                    position: 'absolute',
                    left: '0.85rem',
                    top: '50%',
                    transform: 'translateY(-50%)',
                    color: 'var(--text-muted)'
                  }}
                >
                  <Lock size={18} />
                </div>
                <input
                  id="login-password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Digite sua senha"
                  required
                  style={{
                    width: '100%',
                    padding: '0.7rem 2.4rem 0.7rem 2.4rem',
                    borderRadius: 'var(--radius-md)',
                    border: '1px solid var(--border-default)',
                    fontSize: '0.9rem',
                    backgroundColor: 'var(--bg-surface)'
                  }}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  style={{
                    position: 'absolute',
                    right: '0.85rem',
                    top: '50%',
                    transform: 'translateY(-50%)',
                    background: 'none',
                    border: 'none',
                    color: 'var(--text-muted)',
                    cursor: 'pointer'
                  }}
                  aria-label={showPassword ? 'Ocultar senha' : 'Exibir senha'}
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>

            {/* Botão de Entrar */}
            <Button
              type="submit"
              variant="primary"
              isLoading={isLoading}
              style={{ width: '100%', padding: '0.75rem', fontSize: '0.95rem', fontWeight: 700 }}
              iconRight={<ArrowRight size={18} />}
            >
              Entrar no Sistema
            </Button>
          </form>

          {/* Atalhos Rápidos para Demonstração Acadêmica (TTI206) */}
          <div
            style={{
              marginTop: '1.75rem',
              paddingTop: '1.25rem',
              borderTop: '1px solid var(--border-subtle)',
              textAlign: 'center'
            }}
          >
            <div style={{ fontSize: '0.72rem', textTransform: 'uppercase', letterSpacing: '0.06em', color: 'var(--text-muted)', fontWeight: 700, marginBottom: '0.6rem' }}>
              Atalhos de Acesso para Demonstração (TTI206)
            </div>
            <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center' }}>
              <button
                type="button"
                className="btn btn-secondary btn-sm"
                onClick={() => handleQuickLogin('luiza.gomes@semob.saocaetanodosul.sp.gov.br')}
                style={{ fontSize: '0.75rem' }}
              >
                Coordenador Geral
              </button>
              <button
                type="button"
                className="btn btn-secondary btn-sm"
                onClick={() => handleQuickLogin('fiscal.transporte@semob.saocaetanodosul.sp.gov.br')}
                style={{ fontSize: '0.75rem' }}
              >
                Fiscal Operacional
              </button>
            </div>
          </div>
        </div>

        {/* Rodapé da Caixa */}
        <div
          style={{
            backgroundColor: 'var(--bg-surface-subtle)',
            padding: '0.85rem 1.5rem',
            textAlign: 'center',
            fontSize: '0.75rem',
            color: 'var(--text-muted)',
            borderTop: '1px solid var(--border-subtle)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '0.5rem'
          }}
        >
          <ShieldCheck size={16} color="var(--status-success)" />
          <span>Ambiente Institucional Seguro — Prefeitura de São Caetano do Sul</span>
        </div>
      </div>

      {/* Modal Esqueci Minha Senha */}
      <Modal
        isOpen={isForgotModalOpen}
        onClose={() => {
          setIsForgotModalOpen(false);
          setForgotSuccess(false);
        }}
        title="Recuperação de Acesso Institucional"
        footer={
          <Button
            variant="secondary"
            onClick={() => {
              setIsForgotModalOpen(false);
              setForgotSuccess(false);
            }}
          >
            Fechar
          </Button>
        }
      >
        {forgotSuccess ? (
          <div style={{ textAlign: 'center', padding: '1rem 0' }}>
            <div
              style={{
                width: '48px',
                height: '48px',
                borderRadius: '50%',
                backgroundColor: 'var(--status-success-bg)',
                color: 'var(--status-success)',
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: '0.75rem'
              }}
            >
              <ShieldCheck size={28} />
            </div>
            <h4 style={{ color: 'var(--color-primary-navy)', marginBottom: '0.5rem' }}>
              Instruções Enviadas!
            </h4>
            <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
              Verifique a caixa de entrada do seu e-mail institucional (<strong>{forgotEmail}</strong>) para redefinir sua credencial.
            </p>
          </div>
        ) : (
          <form onSubmit={handleForgotSubmit}>
            <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '1rem' }}>
              Informe seu e-mail cadastrado junto ao Departamento de TI da SEMOB-SCS para receber o link seguro de recuperação de senha.
            </p>
            <div style={{ marginBottom: '1.25rem' }}>
              <label
                htmlFor="forgot-email"
                style={{ display: 'block', fontSize: '0.8rem', fontWeight: 600, marginBottom: '0.35rem' }}
              >
                E-mail Institucional
              </label>
              <input
                id="forgot-email"
                type="email"
                required
                value={forgotEmail}
                onChange={(e) => setForgotEmail(e.target.value)}
                placeholder="seu.nome@semob.saocaetanodosul.sp.gov.br"
                style={{
                  width: '100%',
                  padding: '0.65rem 0.85rem',
                  borderRadius: 'var(--radius-md)',
                  border: '1px solid var(--border-default)',
                  fontSize: '0.875rem'
                }}
              />
            </div>
            <Button type="submit" variant="primary" style={{ width: '100%' }}>
              Solicitar Redefinição
            </Button>
          </form>
        )}
      </Modal>
    </div>
  );
}
