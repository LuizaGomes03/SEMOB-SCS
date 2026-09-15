import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/breakpoints.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String selectedPeriod;
  final Function(String) onPeriodSelected;
  final VoidCallback onRefresh;
  final bool isRefreshing;
  final VoidCallback onOpenNotifications;
  final int unreadNotifications;
  final VoidCallback onOpenAccessibility;
  final VoidCallback onOpenProfile;
  final VoidCallback? onOpenDrawer;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    required this.onRefresh,
    this.isRefreshing = false,
    required this.onOpenNotifications,
    this.unreadNotifications = 0,
    required this.onOpenAccessibility,
    required this.onOpenProfile,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final isTablet = Breakpoints.isTablet(context);
    final isDesktop = Breakpoints.isDesktop(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 10 : 14,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Botão Drawer no Mobile
          if (isMobile && onOpenDrawer != null) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: onOpenDrawer,
              tooltip: 'Abrir menu lateral',
            ),
            const SizedBox(width: 4),
          ],

          // Título e Subtítulo da Tela
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Seletor de Período (Desktop completo, Tablet compacto popup)
          if (isDesktop) ...[
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPeriodButton(context, 'hoje', 'Hoje'),
                  _buildPeriodButton(context, 'semana', 'Semana'),
                  _buildPeriodButton(context, 'mes', 'Mês'),
                  _buildPeriodButton(context, 'custom', 'Personalizado'),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ] else if (isTablet) ...[
            PopupMenuButton<String>(
              tooltip: 'Selecionar Período',
              initialValue: selectedPeriod,
              onSelected: onPeriodSelected,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      selectedPeriod == 'hoje'
                          ? 'Hoje'
                          : (selectedPeriod == 'semana'
                              ? 'Semana'
                              : (selectedPeriod == 'mes' ? 'Mês' : 'Período')),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'hoje', child: Text('Hoje')),
                PopupMenuItem(value: 'semana', child: Text('Semana')),
                PopupMenuItem(value: 'mes', child: Text('Mês')),
                PopupMenuItem(value: 'custom', child: Text('Personalizado...')),
              ],
            ),
            const SizedBox(width: 8),
          ],

          // Botão Atualizar Dados
          if (isDesktop) ...[
            OutlinedButton.icon(
              onPressed: isRefreshing ? null : onRefresh,
              icon: isRefreshing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: const Text(
                'Atualizar Dados',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (isTablet) ...[
            IconButton(
              onPressed: isRefreshing ? null : onRefresh,
              icon: isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.refresh, size: 20, color: AppColors.primary),
              tooltip: 'Atualizar Dados',
            ),
          ],

          // Ícone Notificações com Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                onPressed: onOpenNotifications,
                tooltip: 'Central de Notificações',
              ),
              if (unreadNotifications > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Ícone Acessibilidade
          IconButton(
            icon: const Icon(Icons.accessibility_new, color: AppColors.textPrimary),
            onPressed: onOpenAccessibility,
            tooltip: 'Acessibilidade Digital',
          ),

          // Perfil do Usuário
          InkWell(
            onTap: onOpenProfile,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: const Text(
                  'LG',
                  style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(BuildContext context, String key, String label) {
    final isSelected = selectedPeriod == key;
    return InkWell(
      onTap: () async {
        if (key == 'custom') {
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2026, 1, 1),
            lastDate: DateTime(2026, 12, 31),
            initialDateRange: DateTimeRange(
              start: DateTime(2026, 9, 1),
              end: DateTime(2026, 9, 14),
            ),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              );
            },
          );
          if (range != null) {
            onPeriodSelected('custom');
          }
        } else {
          onPeriodSelected(key);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
