import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../marketplace/presentation/order_details_screen.dart';
import '../../reports/presentation/sales_report_screen.dart';

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

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif_1',
      'category': 'Orders',
      'title': 'New Order Received for Wheat',
      'hindiTitle': 'आपका उत्पाद गेहूँ का ऑर्डर मिला है',
      'subtitle': 'Buyer Ramesh Kirana requested 20 Kg (₹ 560)',
      'time': '2 mins ago',
      'icon': Icons.shopping_bag_outlined,
      'iconBg': Color(0xFFE8F5E9),
      'iconColor': Color(0xFF136A36),
      'isUnread': true,
      'type': 'order',
    },
    {
      'id': 'notif_2',
      'category': 'Orders',
      'title': 'Order #ORD12345 Accepted',
      'hindiTitle': 'ऑर्डर #ORD12345 स्वीकार किया गया',
      'subtitle': 'Produce is confirmed and ready for farmgate dispatch',
      'time': '15 mins ago',
      'icon': Icons.inventory_2_outlined,
      'iconBg': Color(0xFFFFF0E0),
      'iconColor': Color(0xFFE65100),
      'isUnread': true,
      'type': 'order',
    },
    {
      'id': 'notif_3',
      'category': 'Payments',
      'title': '₹ 560 Credited to Kisan Wallet',
      'hindiTitle': '₹ 560 आपके वॉलेट में जोड़े गए',
      'subtitle': 'Escrow released payment directly to your balance',
      'time': '1 hour ago',
      'icon': Icons.account_balance_wallet_outlined,
      'iconBg': Color(0xFFE8F5E9),
      'iconColor': Color(0xFF136A36),
      'isUnread': false,
      'type': 'payment',
    },
    {
      'id': 'notif_4',
      'category': 'Alerts',
      'title': 'Low Stock Warning: Tomatoes',
      'hindiTitle': 'टमाटर का स्टॉक कम है, नया स्टॉक जोड़ें',
      'subtitle': 'Only 10 Kg remaining in your active crop inventory',
      'time': '3 hours ago',
      'icon': Icons.notifications_active_outlined,
      'iconBg': Color(0xFFFFF3E0),
      'iconColor': Color(0xFFE67E22),
      'isUnread': false,
      'type': 'stock',
    },
    {
      'id': 'notif_5',
      'category': 'Alerts',
      'title': 'Weekly Sales & Mandi Report Ready',
      'hindiTitle': 'साप्ताहिक रिपोर्ट उपलब्ध है',
      'subtitle': 'Your weekly earnings reached ₹ 25,680 (+14.8% growth)',
      'time': '1 day ago',
      'icon': Icons.insights_rounded,
      'iconBg': Color(0xFFE3F2FD),
      'iconColor': Color(0xFF1565C0),
      'isUnread': false,
      'type': 'report',
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isUnread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notif) {
    setState(() {
      notif['isUnread'] = false;
    });

    final type = notif['type'];
    if (type == 'order') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OrderDetailsScreen(
            order: {
              'id': '#ORD12345',
              'buyer': 'Ramesh Kirana Store, Indore',
              'items': 'Wheat - 20 Kg',
              'amount': '₹ 560',
              'date': '20 May 2026, 10:30 AM',
              'status': 'New',
              'phone': '+91 78251 23456',
              'address': 'Shop #12, Cloth Market, Indore, MP',
              'paymentStatus': 'Paid via UPI (Escrow)',
            },
          ),
        ),
      );
    } else if (type == 'report') {
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
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all read',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ================= 1. CATEGORY FILTER ROW =================
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

                // ================= 2. NOTIFICATION LIST =================
                Expanded(
                  child: ListView.separated(
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
                                // Left Icon Circle/Square
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

                                // Title, Subtitle & Time
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
