import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final res = await ApiService().getNotifications();
      if (mounted) {
        setState(() {
          _notifications = res.map((n) {
            final String type = (n['type'] ?? 'info').toString().toLowerCase();
            IconData icon = Icons.notifications_none_rounded;
            Color color = AppColors.primary;

            if (type.contains('order') || type.contains('demand')) {
              icon = Icons.shopping_bag_outlined;
              color = AppColors.primary;
            } else if (type.contains('wallet') || type.contains('pay')) {
              icon = Icons.account_balance_wallet_outlined;
              color = Colors.teal;
            } else if (type.contains('qc') || type.contains('inspect')) {
              icon = Icons.verified_outlined;
              color = const Color(0xFF15803D);
            } else if (type.contains('alert')) {
              icon = Icons.trending_up_rounded;
              color = AppColors.accentOrange;
            }

            final createdAt = n['created_at'];
            String timeStr = 'Recently';
            if (createdAt != null) {
              final date = DateTime.fromMillisecondsSinceEpoch((createdAt as num).toInt() * 1000);
              final diff = DateTime.now().difference(date);
              if (diff.inMinutes < 60) {
                timeStr = '${diff.inMinutes}m ago';
              } else if (diff.inHours < 24) {
                timeStr = '${diff.inHours}h ago';
              } else {
                timeStr = '${diff.inDays}d ago';
              }
            }

            return {
              'id': n['id'],
              'title': n['title'] ?? 'Notification',
              'desc': n['message'] ?? n['desc'] ?? '',
              'time': timeStr,
              'icon': icon,
              'color': color,
              'unread': n['is_read'] == 0 || n['unread'] == true,
            };
          }).toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['unread'] == true).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadCount New',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 20),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              'No new notifications',
                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF0F3F1)),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          final isUnread = item['unread'] as bool;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUnread ? const Color(0xFFF4FAF5) : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: isUnread ? Border.all(color: const Color(0xFFD4EBD8)) : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: (item['color'] as Color).withValues(alpha: 0.12),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    size: 20,
                                    color: item['color'] as Color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] as String,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            item['time'] as String,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['desc'] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          color: AppColors.textSecondary,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
