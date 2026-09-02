import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../reports/presentation/sales_report_screen.dart';
import '../../../../core/services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  final bool showFloatingNav;

  const NotificationsScreen({
    super.key,
    this.showFloatingNav = false,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'All';

  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final notifs = await ApiService().getNotifications();
      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(notifs.map((n) {
            final String type = (n['type'] ?? 'alert').toString().toLowerCase();
            final isOrder = type.contains('order') || type.contains('demand');
            final isPayment = type.contains('payment') || type.contains('wallet') || type.contains('payout');
            final isReport = type.contains('report') || type.contains('qc') || type.contains('inspect');

            String timeStr = 'Recently';
            final rawCreated = n['created_at'];
            if (rawCreated is num) {
              final date = DateTime.fromMillisecondsSinceEpoch((rawCreated * 1000).toInt());
              final diff = DateTime.now().difference(date);
              if (diff.inMinutes < 60) {
                timeStr = '${diff.inMinutes}m ago';
              } else if (diff.inHours < 24) {
                timeStr = '${diff.inHours}h ago';
              } else {
                timeStr = '${diff.inDays}d ago';
              }
            } else if (rawCreated is String) {
              final parsed = DateTime.tryParse(rawCreated);
              if (parsed != null) {
                final diff = DateTime.now().difference(parsed);
                if (diff.inMinutes < 60) {
                  timeStr = '${diff.inMinutes}m ago';
                } else if (diff.inHours < 24) {
                  timeStr = '${diff.inHours}h ago';
                } else {
                  timeStr = '${diff.inDays}d ago';
                }
              }
            }

            return {
              'id': (n['id'] ?? '').toString(),
              'category': isOrder ? 'Orders' : isPayment ? 'Payments' : isReport ? 'Reports' : 'Alerts',
              'title': n['title'] ?? 'Notification',
              'hindiTitle': n['title'] ?? '',
              'subtitle': n['message'] ?? n['body'] ?? n['desc'] ?? '',
              'time': timeStr,
              'icon': isOrder
                  ? Icons.shopping_bag_outlined
                  : isPayment
                      ? Icons.account_balance_wallet_outlined
                      : isReport
                          ? Icons.insights_rounded
                          : Icons.notifications_active_outlined,
              'iconBg': isOrder
                  ? const Color(0xFFE8F5E9)
                  : isPayment
                      ? const Color(0xFFE8F5E9)
                      : isReport
                          ? const Color(0xFFE3F2FD)
                          : const Color(0xFFFFF3E0),
              'iconColor': isOrder
                  ? const Color(0xFF136A36)
                  : isPayment
                      ? const Color(0xFF136A36)
                      : isReport
                          ? const Color(0xFF1565C0)
                          : const Color(0xFFE67E22),
              'isUnread': n['is_read'] == 0 || n['is_read'] == false || n['unread'] == true,
              'type': type,
            };
          }));
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load notifications';
          _isLoading = false;
        });
      }
    }
  }

  void _markAllAsRead() async {
    setState(() {
      for (var n in _notifications) {
        n['isUnread'] = false;
      }
    });
    try {
      await ApiService().markAllNotificationsRead();
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All notifications marked as read', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notif) {
    setState(() {
      notif['isUnread'] = false;
    });

    final notifId = notif['id'];
    if (notifId != null && notifId.toString().isNotEmpty) {
      ApiService().markNotificationRead(notifId.toString()).catchError((_) {});
    }

    final type = notif['type'] as String? ?? '';
    if (type.contains('report') || type.contains('qc')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SalesReportScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedCategory == 'All'
        ? _notifications
        : _notifications.where((n) => n['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF142B1D), size: 24),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: const Color(0xFF142B1D),
            fontSize: 18.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _notifications.isNotEmpty ? _markAllAsRead : null,
            child: Text(
              'Mark all read',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _notifications.isNotEmpty ? AppColors.primary : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchNotifications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                            child: Row(
                              children: [
                                _buildCategoryChip('All'),
                                const SizedBox(width: 8),
                                _buildCategoryChip('Orders'),
                                const SizedBox(width: 8),
                                _buildCategoryChip('Payments'),
                                const SizedBox(width: 8),
                                _buildCategoryChip('Alerts'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: filteredList.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.notifications_none_rounded, size: 56, color: Colors.grey.shade400),
                                        const SizedBox(height: 10),
                                        Text(
                                          'No notifications in this category',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(18, 6, 18, widget.showFloatingNav ? 110 : 24),
                                    itemCount: filteredList.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final item = filteredList[index];
                                      final isUnread = item['isUnread'] as bool? ?? false;

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _handleNotificationTap(item),
                                          borderRadius: BorderRadius.circular(18),
                                          child: Ink(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(
                                                color: isUnread ? const Color(0xFF136A36).withValues(alpha: 0.3) : const Color(0xFFE8E5DA),
                                                width: isUnread ? 1.4 : 1.1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.02),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    color: item['iconBg'] as Color,
                                                    borderRadius: BorderRadius.circular(14),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      item['icon'] as IconData,
                                                      color: item['iconColor'] as Color,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
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
                                                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                                                color: const Color(0xFF162D1F),
                                                              ),
                                                            ),
                                                          ),
                                                          if (isUnread)
                                                            Container(
                                                              width: 8,
                                                              height: 8,
                                                              margin: const EdgeInsets.only(left: 6),
                                                              decoration: const BoxDecoration(
                                                                color: Color(0xFF136A36),
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        item['subtitle'] as String,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.normal,
                                                          color: const Color(0xFF6B8374),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        item['time'] as String,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF94A79C),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF136A36) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF136A36) : const Color(0xFFE4EDE7),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF4C6354),
            ),
          ),
        ),
      ),
    );
  }
}
