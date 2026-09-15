import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final VoidCallback onLogout;
  final bool isDrawer;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
    required this.onLogout,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard_outlined, 'selectedIcon': Icons.dashboard},
      {'title': 'Operação', 'icon': Icons.directions_bus_outlined, 'selectedIcon': Icons.directions_bus},
      {'title': 'Passageiros', 'icon': Icons.people_outline, 'selectedIcon': Icons.people},
      {'title': 'Financeiro', 'icon': Icons.attach_money_outlined, 'selectedIcon': Icons.attach_money},
      {'title': 'Anomalias', 'icon': Icons.warning_amber_outlined, 'selectedIcon': Icons.warning, 'badge': '3'},
      {'title': 'Relatórios', 'icon': Icons.description_outlined, 'selectedIcon': Icons.description},
      {'title': 'Configurações', 'icon': Icons.settings_outlined, 'selectedIcon': Icons.settings},
    ];

    final width = isDrawer ? 280.0 : (isCollapsed ? 74.0 : 260.0);

    return Container(
      width: width,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(right: BorderSide(color: AppColors.primaryDark)),
      ),
      child: Column(
        children: [
          // Topo: Logotipo Oficial da Prefeitura de São Caetano do Sul
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 8 : 16,
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.primaryDark)),
            ),
            child: Row(
              children: [
                // Logo Oficial da Prefeitura
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Image.asset(
                    AppAssets.logoPrefeitura,
                    fit: BoxFit.contain,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'SEMOB-SCS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'SECRETARIA DE MOBILIDADE URBANA',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isDrawer && onToggleCollapse != null)
                  IconButton(
                    icon: Icon(
                      isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: onToggleCollapse,
                    tooltip: isCollapsed ? 'Expandir Menu' : 'Recolher Menu',
                  ),
              ],
            ),
          ),

          // Lista de Navegação
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = selectedIndex == index;
                final badge = item['badge'] as String?;

                return Material(
                  color: isSelected ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      onItemSelected(index);
                      if (isDrawer) {
                        Navigator.of(context).pop();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? (item['selectedIcon'] as IconData)
                                : (item['icon'] as IconData),
                            color: isSelected ? Colors.white : Colors.white70,
                            size: 20,
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Rodapé: Identificação do Gestor e Logout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primaryDark)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryDark,
                  child: const Text(
                    'LG',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Dra. Luiza Gomes',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'SEMOB-SCS / Gestor',
                          style: TextStyle(color: Colors.white60, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70, size: 18),
                    onPressed: onLogout,
                    tooltip: 'Sair da conta',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
