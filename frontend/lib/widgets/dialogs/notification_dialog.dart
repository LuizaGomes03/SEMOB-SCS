import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notificacao_item.dart';

class NotificationDialog extends StatefulWidget {
  final List<NotificacaoItem> notifications;
  final Function(int) onNavigate;
  final VoidCallback onMarkAllAsRead;
  final VoidCallback onClearAll;

  const NotificationDialog({
    super.key,
    required this.notifications,
    required this.onNavigate,
    required this.onMarkAllAsRead,
    required this.onClearAll,
  });

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  String _activeCategory = 'Todas';

  @override
  Widget build(BuildContext context) {
    final filtered = _activeCategory == 'Todas'
        ? widget.notifications
        : widget.notifications.where((n) => n.category == _activeCategory).toList();

    final unreadCount = widget.notifications.where((n) => !n.read).length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 580),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header do Dialog
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Central de Notificações',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Abas de Categorias
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todas', 'Alertas', 'Informações', 'Atualizações'].map((cat) {
                    final isSelected = _activeCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _activeCategory = cat);
                        },
                        selectedColor: AppColors.primaryLight,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Barra de Ações: Marcar todas lidas / Limpar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: widget.onMarkAllAsRead,
                    icon: const Icon(Icons.done_all, size: 14),
                    label: const Text('Marcar todas como lidas', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                  TextButton.icon(
                    onPressed: widget.onClearAll,
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: const Text('Limpar', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Lista de Notificações
            Flexible(
              child: filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Nenhuma notificação nesta categoria.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notif = filtered[index];
                        return InkWell(
                          onTap: () {
                            setState(() => notif.read = true);
                            Navigator.of(context).pop();
                            widget.onNavigate(notif.destinationIndex);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: notif.read ? AppColors.card : AppColors.primaryLight.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  notif.severity == 'danger'
                                      ? Icons.error_outline
                                      : (notif.severity == 'warning'
                                          ? Icons.warning_amber_rounded
                                          : Icons.info_outline),
                                  size: 20,
                                  color: notif.severity == 'danger'
                                      ? AppColors.danger
                                      : (notif.severity == 'warning'
                                          ? AppColors.warning
                                          : AppColors.primary),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: notif.read ? FontWeight.w600 : FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        notif.description,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.time,
                                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!notif.read)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
