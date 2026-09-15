import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final double textScale;
  final bool isHighContrast;
  final bool isEnhancedFocus;
  final Function(double) onTextScaleChange;
  final VoidCallback onToggleHighContrast;
  final VoidCallback onToggleEnhancedFocus;
  final VoidCallback onLogout;

  const ConfiguracoesScreen({
    super.key,
    required this.textScale,
    required this.isHighContrast,
    required this.isEnhancedFocus,
    required this.onTextScaleChange,
    required this.onToggleHighContrast,
    required this.onToggleEnhancedFocus,
    required this.onLogout,
  });

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  String _defaultPeriod = 'hoje';
  bool _soundAlerts = true;
  String _tableDensity = 'normal';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card de Perfil do Gestor
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perfil do Gestor Municipal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Identificação funcional e permissões de acesso ao sistema',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        child: const Text(
                          'LG',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Dra. Luiza Gomes',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Coordenadora de Monitoramento e Planejamento Operacional',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'SEMOB-SCS / Diretoria de Transportes Públicos',
                              style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildProfileField('E-mail Funcional', 'luiza.gomes@semob.saocaetanodosul.sp.gov.br'),
                  const SizedBox(height: 10),
                  _buildProfileField('Nível de Privilégio', 'Gestor Geral (Acesso Total)'),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Encerrar Sessão (Sair da Conta)'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preferências do Sistema
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferências da Operação',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Configuração de visualização e alertas do painel',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),

                  DropdownButtonFormField<String>(
                    value: _defaultPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Período Padrão ao Iniciar o Dashboard',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'hoje', child: Text('Hoje (Em tempo real)')),
                      DropdownMenuItem(value: 'semana', child: Text('Esta Semana (Últimos 7 dias)')),
                      DropdownMenuItem(value: 'mes', child: Text('Mês Atual')),
                    ],
                    onChanged: (val) => setState(() => _defaultPeriod = val!),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _tableDensity,
                    decoration: const InputDecoration(
                      labelText: 'Densidade Visual das Tabelas',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'compact', child: Text('Compacta (mais linhas na tela)')),
                      DropdownMenuItem(value: 'normal', child: Text('Normal / Confortável (recomendado)')),
                      DropdownMenuItem(value: 'spacious', child: Text('Espaçosa (máxima legibilidade)')),
                    ],
                    onChanged: (val) => setState(() => _tableDensity = val!),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Avisos Sonoros para Alertas Críticos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Emitir alerta sonoro ao receber anomalia severa de tráfego', style: TextStyle(fontSize: 11)),
                    value: _soundAlerts,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _soundAlerts = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Configurações de Acessibilidade
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acessibilidade e Inclusão Digital',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Parâmetros em conformidade com as diretrizes e-MAG / WCAG 2.1',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Escala da Fonte', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('Fator atual: ${(widget.textScale * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton.outlined(
                            icon: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => widget.onTextScaleChange((widget.textScale - 0.1).clamp(0.8, 1.4)),
                          ),
                          const SizedBox(width: 4),
                          IconButton.outlined(
                            icon: const Text('A', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => widget.onTextScaleChange(1.0),
                          ),
                          const SizedBox(width: 4),
                          IconButton.outlined(
                            icon: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => widget.onTextScaleChange((widget.textScale + 0.1).clamp(0.8, 1.4)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    title: const Text('Modo Alto Contraste', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Inversão com contraste máximo (preto e amarelo)', style: TextStyle(fontSize: 11)),
                    value: widget.isHighContrast,
                    activeColor: AppColors.primary,
                    onChanged: (_) => widget.onToggleHighContrast(),
                    contentPadding: EdgeInsets.zero,
                  ),

                  SwitchListTile(
                    title: const Text('Foco Visível Reforçado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Bordas destacadas para navegação assistida por teclado', style: TextStyle(fontSize: 11)),
                    value: widget.isEnhancedFocus,
                    activeColor: AppColors.primary,
                    onChanged: (_) => widget.onToggleEnhancedFocus(),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
