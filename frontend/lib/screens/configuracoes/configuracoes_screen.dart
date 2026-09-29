
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

  const ConfiguracoesScreen({
    super.key,
    required this.textScale,
    required this.isHighContrast,
    required this.isEnhancedFocus,
    required this.onTextScaleChange,
    required this.onToggleHighContrast,
    required this.onToggleEnhancedFocus,
    required this.onClose,
  });

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _excludeWeekends = true;
  bool _onlyAnomalies = false;
  bool _autoRefresh = false;
  String _selectedLine = 'Todas as linhas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < 600 ? 16.0 : 30.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 28, padding, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onClose,
                      tooltip: 'Voltar',
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configurações',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Personalize filtros, atualização e acessibilidade do sistema.',
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
                const SizedBox(height: 26),
                _section(
                  title: 'Filtros da operação',
                  icon: Icons.tune_rounded,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLine,
                      decoration: const InputDecoration(
                        labelText: 'Linha',
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
                          child: Text('Linha 01'),
                        ),
                        DropdownMenuItem(
                          value: 'Linha 02',
                          child: Text('Linha 02'),
                        ),
                        DropdownMenuItem(
                          value: 'Linha 03',
                          child: Text('Linha 03'),
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
                        'Considerar somente dias úteis nos indicadores.',
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
                        'Destacar registros que exigem investigação.',
                      ),
                      value: _onlyAnomalies,
                      onChanged: (value) {
                        setState(() => _onlyAnomalies = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _section(
                  title: 'Atualização',
                  icon: Icons.sync_rounded,
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Atualização automática'),
                      subtitle: const Text(
                        'Atualizar os indicadores automaticamente.',
                      ),
                      value: _autoRefresh,
                      onChanged: (value) {
                        setState(() => _autoRefresh = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _section(
                  title: 'Acessibilidade',
                  icon: Icons.accessibility_new_rounded,
                  children: [
                    const Text(
                      'Tamanho do texto',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        const Text('A'),
                        Expanded(
                          child: Slider(
                            value: widget.textScale,
                            min: 0.9,
                            max: 1.3,
                            divisions: 4,
                            label:
                                '${(widget.textScale * 100).round()}%',
                            onChanged: widget.onTextScaleChange,
                          ),
                        ),
                        const Text(
                          'A',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Alto contraste'),
                      value: widget.isHighContrast,
                      onChanged: (_) =>
                          widget.onToggleHighContrast(),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Foco visual aprimorado'),
                      value: widget.isEnhancedFocus,
                      onChanged: (_) =>
                          widget.onToggleEnhancedFocus(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Salvar e voltar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
