import React from 'react';
import Modal from '../common/Modal';
import Button from '../common/Button';
import { useAccessibility } from '../../context/AccessibilityContext';
import { Keyboard, Eye, Type, CheckCircle } from 'lucide-react';

export default function AccessibilityModal() {
  const { isKeyboardModalOpen, setIsKeyboardModalOpen } = useAccessibility();

  const shortcuts = [
    { key: 'Alt + 1', action: 'Ir para o Dashboard Principal' },
    { key: 'Alt + 2', action: 'Ir para a tela de Operação' },
    { key: 'Alt + 3', action: 'Ir para a tela de Passageiros' },
    { key: 'Alt + 4', action: 'Ir para Informações Financeiras' },
    { key: 'Alt + 5', action: 'Ir para Anomalias e Alertas' },
    { key: 'Alt + 6', action: 'Ir para Relatórios da Operação' },
    { key: 'Alt + 7', action: 'Ir para Configurações do Sistema' },
    { key: 'Alt + R', action: 'Atualizar dados da base Smart Data' },
    { key: 'Esc', action: 'Fechar janelas, gavetas e modais abertos' }
  ];

  return (
    <Modal
      isOpen={isKeyboardModalOpen}
      onClose={() => setIsKeyboardModalOpen(false)}
      title="Acessibilidade e Navegação por Teclado"
      footer={
        <Button variant="primary" onClick={() => setIsKeyboardModalOpen(false)}>
          Entendido
        </Button>
      }
    >
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
        <p style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
          O sistema institucional <strong>Dashboard de Operação de Transporte (SEMOB-SCS)</strong> foi projetado segundo os padrões de acessibilidade digital e conformidade com as diretrizes do Modelo de Acessibilidade em Governo Eletrônico (e-MAG / WCAG 2.1).
        </p>

        <div>
          <h4 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.75rem', color: 'var(--color-primary-navy)' }}>
            <Keyboard size={18} color="var(--color-primary-blue)" />
            Atalhos Globais do Sistema
          </h4>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '0.5rem' }}>
            {shortcuts.map((sc, index) => (
              <div
                key={index}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '0.5rem 0.75rem',
                  borderRadius: 'var(--radius-sm)',
                  backgroundColor: 'var(--bg-surface-subtle)',
                  border: '1px solid var(--border-subtle)'
                }}
              >
                <span style={{ fontSize: '0.825rem', color: 'var(--text-secondary)' }}>{sc.action}</span>
                <kbd
                  style={{
                    backgroundColor: 'var(--color-primary-navy)',
                    color: '#FFFFFF',
                    padding: '0.2rem 0.5rem',
                    borderRadius: '4px',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    boxShadow: 'var(--shadow-xs)'
                  }}
                >
                  {sc.key}
                </kbd>
              </div>
            ))}
          </div>
        </div>

        <div style={{ borderTop: '1px solid var(--border-subtle)', paddingTop: '1rem' }}>
          <h4 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem', color: 'var(--color-primary-navy)' }}>
            <Eye size={18} color="var(--color-primary-blue)" />
            Recursos Disponíveis
          </h4>
          <ul style={{ listStyle: 'none', padding: 0, display: 'flex', flexDirection: 'column', gap: '0.4rem', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <CheckCircle size={15} color="var(--status-success)" />
              <strong>Alto Contraste:</strong> Otimizado para usuários com baixa visão ou fotossensibilidade.
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <CheckCircle size={15} color="var(--status-success)" />
              <strong>Redimensionamento de Fonte:</strong> Ampliação nativa proporcional em unidades relativas (rem).
            </li>
            <li style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <CheckCircle size={15} color="var(--status-success)" />
              <strong>VLibras:</strong> Integração nativa com o avatar do ecossistema federal para tradução em LIBRAS.
            </li>
          </ul>
        </div>
      </div>
    </Modal>
  );
}
