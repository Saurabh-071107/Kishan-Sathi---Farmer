import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';
import '../../../../core/widgets/scroll_reveal_item.dart';
import 'order_details_screen.dart';

class OrdersTab extends StatefulWidget {
  final String? initialFilter;

  const OrdersTab({super.key, this.initialFilter});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  late String _selectedFilter;

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'PO-CWC-2026-9814',
      'buyer': 'Central Warehousing Corp (CWC) Sehore',
      'isWarehouseOrder': true,
      'warehouseType': 'Govt Central Godown • WDRA #CWC-MP-901',
      'items': 'Wheat (Grade A) - 50 Qtl',
      'amount': '₹ 1,42,500',
      'unitRate': '₹ 2,850 / Qtl (Locked QC Rate)',
      'date': 'Today, 11:30 AM',
      'status': 'New',
      'phone': '+91 75622 98140',
      'address': 'CWC Agro Complex, Mandi Road, Sehore, MP',
      'paymentStatus': '100% Escrow Funded by Govt CWC',
      'pickupLogistics': 'Warehouse Arranged Truck (Farm Gate)',
      'enwrId': 'e-NWR-2026-MP-491028',
      'grade': 'Grade A',
    },
    {
      'id': 'PO-NAWC-2026-7731',
      'buyer': 'National Agro Warehousing Corp (NAWC) Hub',
      'isWarehouseOrder': true,
      'warehouseType': 'National Agri Storage • WDRA #NAW-1104',
      'items': 'Sharbati Wheat (Grade A) - 80 Qtl',
      'amount': '₹ 2,28,000',
      'unitRate': '₹ 2,850 / Qtl (Locked QC Rate)',
      'date': 'Today, 09:15 AM',
      'status': 'New',
      'phone': '+91 75622 77310',
      'address': 'NAWC Logistics Park, NH-46, Bhopal Road, MP',
      'paymentStatus': '100% Escrow Funded (Central WDRA)',
      'pickupLogistics': 'Warehouse Arranged Truck (Farm Gate)',
      'enwrId': 'e-NWR-2026-MP-518290',
      'grade': 'Grade A',
    },
    {
      'id': 'PO-MPWLC-2026-4402',
      'buyer': 'MP State Warehousing & Logistics Godown #4',
      'isWarehouseOrder': true,
      'warehouseType': 'State Logistics Hub • WDRA #MPW-2026',
      'items': 'Yellow Soyabean (Grade A) - 60 Qtl',
      'amount': '₹ 2,85,000',
      'unitRate': '₹ 4,750 / Qtl (Locked QC Rate)',
      'date': 'Yesterday, 03:00 PM',
      'status': 'In Processing',
      'phone': '+91 75622 44020',
      'address': 'MPWLC Terminal #4, Ashta Bypass, Sehore, MP',
      'paymentStatus': '100% Escrow Funded (MP Govt)',
      'pickupLogistics': 'Warehouse Truck Dispatched',
      'enwrId': 'e-NWR-2026-MP-382910',
      'grade': 'Grade A',
    },
    {
      'id': 'PO-APEX-2026-3390',
      'buyer': 'Apex State Warehouse Yard #2, Ujjain',
      'isWarehouseOrder': true,
      'warehouseType': 'State Storage Godown • WDRA #APX-552',
      'items': 'Potatoes (Grade A) - 100 Qtl',
      'amount': '₹ 1,50,000',
      'unitRate': '₹ 1,500 / Qtl (Locked QC Rate)',
      'date': '18 May 2026, 09:00 AM',
      'status': 'Completed',
      'phone': '+91 97520 89012',
      'address': 'Gate #2, State Warehouse Complex, Ujjain, MP',
      'paymentStatus': 'Settled to Bank A/c via DBT',
      'pickupLogistics': 'Self-Drop at Warehouse Yard',
      'enwrId': 'e-NWR-2026-MP-209148',
      'grade': 'Grade A',
    },
    {
      'id': 'PO-CWC-2026-5510',
      'buyer': 'Central Warehousing Corp (CWC) Indore Godown',
      'isWarehouseOrder': true,
      'warehouseType': 'Govt Central Godown • WDRA #CWC-MP-905',
      'items': 'Chana Dal (Grade A) - 40 Qtl',
      'amount': '₹ 2,32,000',
      'unitRate': '₹ 5,800 / Qtl (Locked QC Rate)',
      'date': '16 May 2026, 02:30 PM',
      'status': 'Completed',
      'phone': '+91 91110 34567',
      'address': 'Industrial Agro Godown, Pithampur, Indore, MP',
      'paymentStatus': 'Settled to Bank A/c via DBT',
      'pickupLogistics': 'Warehouse Arranged Truck',
      'enwrId': 'e-NWR-2026-MP-491028',
      'grade': 'Grade A',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter == 'Processing') {
      _selectedFilter = 'In Processing';
    } else {
      _selectedFilter = widget.initialFilter ?? 'All';
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );

    if (result != null && mounted) {
      if (result['cancelled'] == true) {
        setState(() {
          _orders.removeWhere((o) => o['id'] == result['id']);
        });
      } else {
        setState(() {});
      }
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final filteredList = _selectedFilter == 'All'
        ? _orders
        : _orders.where((o) => o['status'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ================= TOP HEADER =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF142C1E), size: 24),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              langProvider.translate('my_orders_title'),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF142C1E),
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'Official Warehouse Purchase Orders (Locked QC Rate)',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF527560),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= FILTER PILLS =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterPill('All', langProvider.translate('filter_all')),
                        const SizedBox(width: 10),
                        _buildFilterPill('New', langProvider.translate('filter_new')),
                        const SizedBox(width: 10),
                        _buildFilterPill('In Processing', langProvider.translate('filter_processing')),
                        const SizedBox(width: 10),
                        _buildFilterPill('Completed', langProvider.translate('filter_completed')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ================= ORDERS LIST =================
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Text(
                            'No $_selectedFilter warehouse orders found.',
                            style: GoogleFonts.poppins(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final order = filteredList[index];
                            final status = order['status'] as String;
                            final itemsRaw = order['items'] as String;
                            final localizedItems = langProvider.translateProduce(itemsRaw);

                            Color statusBg;
                            Color statusColor;
                            if (status == 'New') {
                              statusBg = const Color(0xFFFFF0E0);
                              statusColor = const Color(0xFFE65100);
                            } else if (status == 'In Processing') {
                              statusBg = const Color(0xFFE1F5FE);
                              statusColor = const Color(0xFF0288D1);
                            } else {
                              statusBg = const Color(0xFFE8F5E9);
                              statusColor = const Color(0xFF136A36);
                            }

                            return ScrollRevealItem(
                              delay: Duration(milliseconds: index < 6 ? index * 55 : 0),
                              child: ScaleBounceOnTap(
                                onTap: () => _showOrderDetails(order),
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCFEFC),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFBCE0C6),
                                      width: 1.3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF136A36).withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top row: Warehouse PO Chip & Status Badge
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: const Color(0xFFC6E7CD)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.warehouse_rounded, size: 13, color: Color(0xFF136A36)),
                                                  const SizedBox(width: 5),
                                                  Flexible(
                                                    child: Text(
                                                      order['id'] as String,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: const Color(0xFF136A36),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              langProvider.translateProduce(status),
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Warehouse Title
                                      Text(
                                        order['buyer'] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF162D1F),
                                        ),
                                      ),
                                      if (order['warehouseType'] != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          order['warehouseType'] as String,
                                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF557762)),
                                        ),
                                      ],
                                      const SizedBox(height: 8),

                                      // Produce & Amount Row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  localizedItems,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF266E40),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (order['unitRate'] != null)
                                                  Text(
                                                    order['unitRate'] as String,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color(0xFF5A7263),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            order['amount'] as String,
                                            style: GoogleFonts.poppins(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF142C1E),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Date & View Details Button
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              order['date'] as String,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF7E9486),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => _showOrderDetails(order),
                                              borderRadius: BorderRadius.circular(10),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      langProvider.translate('view_details_btn'),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF136A36),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                      Icons.arrow_forward_ios_rounded,
                                                      size: 13,
                                                      color: Color(0xFF136A36),
                                                    ),
                                                  ],
                                                ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String filterKey, String displayLabel) {
    final isSelected = _selectedFilter == filterKey;

    return GestureDetector(
      key: ValueKey('orders_filter_$filterKey'),
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF136A36) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF136A36) : const Color(0xFFE4EDE7),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF136A36).withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          displayLabel,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF4A6253),
          ),
        ),
      ),
    );
  }
}
