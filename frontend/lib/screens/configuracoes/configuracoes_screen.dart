import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final double textScale;
  final bool isHighContrast;
  final bool isEnhancedFocus;
  final ValueChanged<double> onTextScaleChange;
  final VoidCallback onToggleHighContrast;
  final VoidCallback onToggleEnhancedFocus;
  final VoidCallback onClose;
  final VoidCallback? onLogout;

  const ConfiguracoesScreen({
    super.key,
    required this.textScale,
    required this.isHighContrast,
    required this.isEnhancedFocus,
    required this.onTextScaleChange,
    required this.onToggleHighContrast,
    required this.onToggleEnhancedFocus,
    required this.onClose,
    this.onLogout,
  });

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _excludeWeekends = true;
  bool _onlyAnomalies = false;
  bool _autoRefresh = false;
  String _selectedLine = 'Todas as linhas';

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Encerrar Sessão'),
        content: const Text(
          'Deseja realmente sair da sua conta institucional da SEMOB-SCS?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (widget.onLogout != null) {
                widget.onLogout!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sessão encerrada com sucesso.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
                widget.onClose();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Confirmar Saída'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          final padding = isNarrow ? 16.0 : 30.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 28, padding, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho da Página
                    Row(
                      children: [
                        IconButton(
                          onPressed: widget.onClose,
                          tooltip: 'Voltar ao Dashboard',
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perfil e Configurações',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Identificação funcional, parâmetros da operação e acessibilidade digital.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 1. CARD: Perfil Institucional do Usuário / Gestor
                    _section(
                      title: 'Perfil Institucional do Gestor',
                      icon: Icons.badge_outlined,
                      headerTrailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 14,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Sessão Ativa',
                              style: TextStyle(
                                color: AppColors.successText,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: [
                        // Identificação do Usuário
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'LG',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Luiza Gomes',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Coordenadora de Operações e Fiscalização',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.account_balance_outlined,
                                          size: 14,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'SEMOB-SCS • Secretaria Municipal de Mobilidade Urbana',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dados Funcionais em Grid / Wrap
                        Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          children: [
                            _buildDataField(
                              icon: Icons.email_outlined,
                              label: 'E-mail Funcional',
                              value: 'luiza.gomes@semob.saocaetanodosul.sp.gov.br',
                              width: isNarrow ? constraints.maxWidth : 300,
                            ),
                            _buildDataField(
                              icon: Icons.badge_outlined,
                              label: 'Matrícula Funcional',
                              value: 'SEMOB-2024-0482',
                              width: isNarrow ? constraints.maxWidth : 200,
                            ),
                            _buildDataField(
                              icon: Icons.shield_outlined,
                              label: 'Nível de Privilégio',
                              value: 'Gestor Municipal (Acesso Total)',
                              width: isNarrow ? constraints.maxWidth : 260,
                            ),
                            _buildDataField(
                              icon: Icons.location_on_outlined,
                              label: 'Lotação / Município',
                              value: 'São Caetano do Sul - SP',
                              width: isNarrow ? constraints.maxWidth : 200,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 14),

                        // Ação de Encerrar Sessão
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _handleLogout,
                              icon: const Icon(Icons.logout_rounded, size: 16),
                              label: const Text('Encerrar Sessão'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: const BorderSide(color: AppColors.danger),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. CARD: Filtros da Operação
                    _section(
                      title: 'Filtros da Operação',
                      icon: Icons.tune_rounded,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLine,
                          decoration: const InputDecoration(
                            labelText: 'Linha Padrão de Análise',
                            prefixIcon: Icon(Icons.directions_bus_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Todas as linhas',
                              child: Text('Todas as linhas'),
                            ),
                            DropdownMenuItem(
                              value: 'Linha 01',
                              child: Text('Linha 01 - Circular Centro'),
                            ),
                            DropdownMenuItem(
                              value: 'Linha 02',
                              child: Text('Linha 02 - Bairro Fundação'),
                            ),
                            DropdownMenuItem(
                              value: 'Linha 03',
                              child: Text('Linha 03 - Bairro Mauá'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedLine = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Excluir finais de semana'),
                          subtitle: const Text(
                            'Considerar somente dias úteis nos indicadores principais.',
                          ),
                          value: _excludeWeekends,
                          onChanged: (value) {
                            setState(() => _excludeWeekends = value);
                          },
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Mostrar somente anomalias'),
                          subtitle: const Text(
                            'Destacar prioritariamente registros que exigem fiscalização.',
                          ),
                          value: _onlyAnomalies,
                          onChanged: (value) {
                            setState(() => _onlyAnomalies = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. CARD: Atualização e Sincronização
                    _section(
                      title: 'Atualização e Sincronização',
                      icon: Icons.sync_rounded,
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Atualização automática contínua'),
                          subtitle: const Text(
                            'Buscar novos dados da operação periodicamente em segundo plano.',
                          ),
                          value: _autoRefresh,
                          onChanged: (value) {
                            setState(() => _autoRefresh = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 4. CARD: Acessibilidade e Inclusão Digital
                    _section(
                      title: 'Acessibilidade e Inclusão Digital',
                      icon: Icons.accessibility_new_rounded,
                      children: [
                        const Text(
                          'Tamanho da Fonte',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'A',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: widget.textScale,
                                min: 0.9,
                                max: 1.3,
                                divisions: 4,
                                label: '${(widget.textScale * 100).round()}%',
                                onChanged: widget.onTextScaleChange,
                              ),
                            ),
                            const Text(
                              'A',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(widget.textScale * 100).round()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: AppColors.border),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Modo de Alto Contraste'),
                          subtitle: const Text(
                            'Aplica fundo escuro e tipografia com contraste reforçado.',
                          ),
                          value: widget.isHighContrast,
                          onChanged: (_) => widget.onToggleHighContrast(),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Foco Visual Aprimorado'),
                          subtitle: const Text(
                            'Contornos destacados para melhor acessibilidade por teclado.',
                          ),
                          value: widget.isEnhancedFocus,
                          onChanged: (_) => widget.onToggleEnhancedFocus(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),

                    // Rodapé de Ações
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Salvar e Voltar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataField({
    required IconData icon,
    required String label,
    required String value,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? headerTrailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E6EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ?headerTrailing,
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
