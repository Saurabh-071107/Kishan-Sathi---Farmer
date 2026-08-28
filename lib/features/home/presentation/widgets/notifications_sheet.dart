import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'New Order Received! 🎉',
        'desc': 'FPO Sahyadri placed an order for 50 Quintals Sharbati Wheat.',
        'time': '10 mins ago',
        'icon': Icons.shopping_bag_outlined,
        'color': AppColors.primary,
        'unread': true,
      },
      {
        'title': 'Mandi Rate Alert 📈',
        'desc': 'Soyabean prices increased by +₹120/Qtl in Sehore APMC.',
        'time': '1 hour ago',
        'icon': Icons.trending_up_rounded,
        'color': AppColors.accentOrange,
        'unread': true,
      },
      {
        'title': 'Payment Disbursed 💰',
        'desc': '₹14,500 credited to Bank of India A/c *8941 for Order #ORD-8821.',
        'time': 'Yesterday',
        'icon': Icons.account_balance_wallet_outlined,
        'color': Colors.teal,
        'unread': false,
      },
      {
        'title': 'Weather Advisory ☀️',
        'desc': 'Favorable sunny conditions expected for harvesting in next 4 days.',
        'time': '2 days ago',
        'icon': Icons.wb_sunny_outlined,
        'color': Colors.amber.shade800,
        'unread': false,
      },
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
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

          // Header
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '2 New',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 20),

          // Notification List
          Expanded(
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF0F3F1)),
              itemBuilder: (context, index) {
                final item = notifications[index];
                final isUnread = item['unread'] as bool;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnread ? const Color(0xFFF4FAF5) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: isUnread
                        ? Border.all(color: const Color(0xFFD4EBD8))
                        : null,
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
