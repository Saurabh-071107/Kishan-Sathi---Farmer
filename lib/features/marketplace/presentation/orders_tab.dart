import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/api_service.dart';
import 'order_details_screen.dart';

class OrdersTab extends StatefulWidget {
  final String? initialFilter;

  const OrdersTab({super.key, this.initialFilter});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  // Main view: 'demands' (Warehouse Demands) or 'orders' (My Orders)
  String _activeSection = 'demands';
  late String _selectedFilter;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _broadcastDemands = [];
  bool _isLoading = true;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter == 'Processing' || widget.initialFilter == 'In Processing' || widget.initialFilter == 'In Process') {
      _selectedFilter = 'In Process';
      _activeSection = 'orders';
    } else if (widget.initialFilter == 'Completed') {
      _selectedFilter = 'Completed';
      _activeSection = 'orders';
    } else if (widget.initialFilter == 'My Orders') {
      _selectedFilter = 'All';
      _activeSection = 'orders';
    } else {
      _selectedFilter = 'All';
      _activeSection = 'demands';
    }
    _loadAllData();
  }

  @override
  void didUpdateWidget(covariant OrdersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != oldWidget.initialFilter) {
      if (widget.initialFilter == 'Processing' || widget.initialFilter == 'In Processing' || widget.initialFilter == 'In Process') {
        setState(() {
          _selectedFilter = 'In Process';
          _activeSection = 'orders';
        });
      } else if (widget.initialFilter == 'Completed') {
        setState(() {
          _selectedFilter = 'Completed';
          _activeSection = 'orders';
        });
      } else if (widget.initialFilter == 'My Orders') {
        setState(() {
          _selectedFilter = 'All';
          _activeSection = 'orders';
        });
      }
      _loadAllData();
    }
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadOrdersInternal(),
        _loadDemandsInternal(),
      ]);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrdersInternal() async {
    try {
      final data = await ApiService().getFarmerOrders();
      if (mounted) {
        setState(() {
          _orders = data.map((e) {
            final itemsList = (e['items'] is List) ? (e['items'] as List) : [];
            final firstItem = itemsList.isNotEmpty ? itemsList.first : {};
            final String itemName = firstItem['name'] ?? firstItem['produce'] ?? 'Produce';
            final num qtyNum = firstItem['qty'] ?? firstItem['quantity'] ?? 0;
            final num priceNum = firstItem['price'] ?? firstItem['unitPrice'] ?? 0;

            String qtyStr;
            if (qtyNum >= 1000) {
              final mt = qtyNum / 1000;
              qtyStr = '${mt.toStringAsFixed(mt % 1 == 0 ? 0 : 2)} MT';
            } else if (qtyNum >= 100) {
              final qtl = qtyNum / 100;
              qtyStr = '${qtl.toStringAsFixed(qtl % 1 == 0 ? 0 : 1)} Qtl';
            } else {
              qtyStr = '$qtyNum kg';
            }

            final rawStatus = (e['status'] ?? '').toString().toLowerCase();
            String displayStatus;
            if (rawStatus == 'completed' || rawStatus == 'delivered') {
              displayStatus = 'Completed';
            } else if (rawStatus == 'pending' || rawStatus == 'new') {
              displayStatus = 'New';
            } else {
              // 'in_progress', 'accepted', 'in_process', 'in processing', 'processing'
              displayStatus = 'In Process';
            }

            String dateStr = 'Today';
            final ca = e['created_at'];
            if (ca is num) {
              dateStr = DateTime.fromMillisecondsSinceEpoch(ca.toInt() * 1000).toLocal().toString().split(' ')[0];
            } else if (ca is String) {
              final parsedNum = int.tryParse(ca);
              if (parsedNum != null) {
                dateStr = DateTime.fromMillisecondsSinceEpoch(parsedNum * 1000).toLocal().toString().split(' ')[0];
              } else {
                final dt = DateTime.tryParse(ca);
                if (dt != null) dateStr = dt.toLocal().toString().split(' ')[0];
              }
            }

            return {
              'id': e['id'] ?? 'ORD-PO',
              'buyer': e['counterparty_name'] ?? e['to_name'] ?? 'Rajasthan State Warehouse',
              'isWarehouseOrder': true,
              'warehouseType': 'State Procurement Hub',
              'items': itemName,
              'quantity': qtyStr,
              'quantity_raw': qtyNum,
              'amount': '₹ ${NumberFormatHelper.formatRupees(e['total_amount'] ?? (qtyNum * priceNum))}',
              'unitRate': priceNum > 0 ? '₹ $priceNum / kg' : 'MSP Rate',
              'date': dateStr,
              'status': displayStatus,
              'rawStatus': rawStatus,
              'phone': '+91 141 2740291',
              'address': '${e['district'] ?? 'Jaipur'}, Rajasthan',
              'paymentStatus': '100% Escrow Funded DBT',
              'pickupLogistics': 'Warehouse Arranged Vehicle',
              'enwrId': e['notes']?.toString().contains('e-NWR') == true ? 'e-NWR Verified' : 'e-NWR Pending',
              'grade': 'Grade A',
            };
          }).toList();
        });
      }
    } catch (_) {
    }
  }

  Future<void> _loadDemandsInternal() async {
    try {
      final results = await Future.wait([
        ApiService().getBroadcastDemands(status: 'open'),
        ApiService().getMyProduce(),
      ]);
      final demands = results[0];
      final myProduce = results[1];

      final farmerCrops = myProduce
          .where((p) => ((p['quantity_kg'] as num?)?.toDouble() ?? 0.0) > 0 && p['status'] != 'sold' && p['status'] != 'rejected')
          .map((p) => (p['product_name'] ?? '').toString().toLowerCase().trim())
          .where((s) => s.isNotEmpty)
          .toSet();

      if (mounted) {
        setState(() {
          final mappedList = demands.map<Map<String, dynamic>>((d) {
            final bCrop = (d['crop_name'] ?? '').toString().toLowerCase().trim();
            final isMatch = farmerCrops.isNotEmpty && farmerCrops.any((pCrop) {
              return pCrop == bCrop ||
                  pCrop.contains(bCrop) ||
                  bCrop.contains(pCrop) ||
                  (bCrop.contains('rice') && (pCrop.contains('rice') || pCrop.contains('chawal') || pCrop.contains('basmati'))) ||
                  (bCrop.contains('wheat') && (pCrop.contains('wheat') || pCrop.contains('gehu') || pCrop.contains('sharbati'))) ||
                  (bCrop.contains('pulse') && (pCrop.contains('pulse') || pCrop.contains('dal') || pCrop.contains('chana') || pCrop.contains('gram'))) ||
                  (bCrop.contains('tomato') && (pCrop.contains('tomato') || pCrop.contains('tamatar'))) ||
                  (bCrop.contains('potato') && (pCrop.contains('potato') || pCrop.contains('aalu') || pCrop.contains('aloo'))) ||
                  (bCrop.contains('cotton') && (pCrop.contains('cotton') || pCrop.contains('kapas'))) ||
                  (bCrop.contains('onion') && (pCrop.contains('onion') || pCrop.contains('pyaj') || pCrop.contains('kanda'))) ||
                  (bCrop.contains('soya') && pCrop.contains('soya')) ||
                  (bCrop.contains('mustard') && (pCrop.contains('mustard') || pCrop.contains('sarson') || pCrop.contains('rai')));
            });

            return {
              'id': d['id'] ?? '',
              'warehouse_id': d['warehouse_id'] ?? '',
              'warehouse_name': d['warehouse_name'] ?? 'Government Procurement Warehouse',
              'crop_name': (d['crop_name'] ?? 'produce').toString(),
              'category': d['category'] ?? 'Grains',
              'quantity_kg': (d['required_quantity_kg'] as num?)?.toDouble() ?? 0.0,
              'price_per_kg': (d['price_per_kg'] as num?)?.toDouble() ?? 0.0,
              'district': d['district'] ?? '',
              'quality_grade': d['quality_grade'] ?? 'Standard Grade',
              'total_payout': (d['total_payout'] as num?)?.toDouble() ?? 0.0,
              'notes': d['notes'] ?? 'Direct Farm Gate Pickup. 100% Escrow Funded DBT.',
              'status': d['status'] ?? 'open',
              'is_matched': isMatch || (d['is_matched'] == true),
            };
          }).where((d) => d['is_matched'] == true).toList();

          _broadcastDemands = mappedList;
        });
      }
    } catch (_) {
    }
  }

  void _confirmAndAcceptDemand(Map<String, dynamic> demand) async {
    final crop = demand['crop_name'] as String;
    final qtyKg = demand['quantity_kg'] as double;
    final pricePerKg = demand['price_per_kg'] as double;
    final totalPayout = demand['total_payout'] as double;
    final whName = demand['warehouse_name'] as String;

    final String qtyDisplay = qtyKg >= 1000
        ? '${(qtyKg / 1000).toStringAsFixed(0)} MT (${qtyKg.toInt()} KG)'
        : '${qtyKg.toInt()} KG';

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.handshake_rounded, color: Color(0xFF136A36), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accept Warehouse Order',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF142C1E),
                        ),
                      ),
                      Text(
                        'Direct Regional Farm Procurement',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF5A7263)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6FAF6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6EADA), width: 1.2),
              ),
              child: Column(
                children: [
                  _buildModalDetailRow('Warehouse Hub', whName, isBold: true),
                  const Divider(height: 14, color: Color(0xFFE0EFE2)),
                  _buildModalDetailRow('Produce / Crop', '${crop.toUpperCase()} (${demand['quality_grade']})'),
                  const Divider(height: 14, color: Color(0xFFE0EFE2)),
                  _buildModalDetailRow('Required Volume', qtyDisplay),
                  const Divider(height: 14, color: Color(0xFFE0EFE2)),
                  _buildModalDetailRow('Certified Inspection Rate', '₹ ${pricePerKg.toStringAsFixed(2)} / kg (₹ ${(pricePerKg * 100).toStringAsFixed(0)} / Qtl)'),
                  const Divider(height: 14, color: Color(0xFFE0EFE2)),
                  _buildModalDetailRow(
                    'Guaranteed DBT Payout',
                    '₹ ${NumberFormatHelper.formatRupees(totalPayout)}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Escrow & Logistics Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF1D4ED8), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '100% Escrow Funded: Warehouse will dispatch farm-gate pickup vehicle. Full payment credited instantly via DBT upon gate-in.',
                      style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF1E40AF), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFCCD9CE)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF5A7263)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF136A36),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Confirm & Accept Order',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _isActionLoading = true);
      try {
        await ApiService().acceptBroadcastDemand(demand['id'] as String);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '🎉 Order Accepted! Warehouse notified for farm-gate pickup. Total: ₹ ${NumberFormatHelper.formatRupees(totalPayout)}',
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF136A36),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );

          // Switch to My Orders tab and show In Process
          setState(() {
            _activeSection = 'orders';
            _selectedFilter = 'In Process';
          });
          _loadAllData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error accepting order: $e'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isActionLoading = false);
      }
    }
  }

  Widget _buildModalDetailRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF556F5E),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: isHighlight ? 14.5 : 12.5,
              fontWeight: (isBold || isHighlight) ? FontWeight.w700 : FontWeight.w600,
              color: isHighlight ? const Color(0xFF136A36) : const Color(0xFF142C1E),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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
        _loadOrdersInternal();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final filteredOrdersList = _selectedFilter == 'All'
        ? _orders
        : _orders.where((o) {
            final s = (o['status'] ?? '').toString().toLowerCase();
            final rawS = (o['rawStatus'] ?? '').toString().toLowerCase();
            if (_selectedFilter == 'In Process' || _selectedFilter == 'In Processing' || _selectedFilter == 'Processing') {
              return s == 'in process' || s == 'in processing' || s == 'in_progress' || rawS == 'in_progress' || rawS == 'accepted' || rawS == 'processing';
            }
            if (_selectedFilter == 'Completed') {
              return s == 'completed' || s == 'delivered' || rawS == 'completed' || rawS == 'delivered';
            }
            if (_selectedFilter == 'New') {
              return s == 'new' || s == 'pending' || rawS == 'pending' || rawS == 'new';
            }
            return o['status'] == _selectedFilter;
          }).toList();

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
                              'Regional Warehouse Procurement & Direct DBT',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF527560),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF136A36)),
                        onPressed: _loadAllData,
                      ),
                    ],
                  ),
                ),

                // ================= SECTION SELECTOR =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2EB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD3E4D6), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeSection = 'demands'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: _activeSection == 'demands' ? const Color(0xFF136A36) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _activeSection == 'demands'
                                    ? [BoxShadow(color: const Color(0xFF136A36).withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.campaign_rounded,
                                    size: 16,
                                    color: _activeSection == 'demands' ? Colors.white : const Color(0xFF3B5645),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Warehouse Demands (${_broadcastDemands.length})',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: _activeSection == 'demands' ? FontWeight.w700 : FontWeight.w600,
                                      color: _activeSection == 'demands' ? Colors.white : const Color(0xFF3B5645),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeSection = 'orders'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: _activeSection == 'orders' ? const Color(0xFF136A36) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _activeSection == 'orders'
                                    ? [BoxShadow(color: const Color(0xFF136A36).withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_rounded,
                                    size: 15,
                                    color: _activeSection == 'orders' ? Colors.white : const Color(0xFF3B5645),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'My Orders (${_orders.length})',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: _activeSection == 'orders' ? FontWeight.w700 : FontWeight.w600,
                                      color: _activeSection == 'orders' ? Colors.white : const Color(0xFF3B5645),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= BODY CONTENT =================
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _activeSection == 'demands'
                          ? _buildBroadcastDemandsView(langProvider)
                          : _buildMyOrdersView(filteredOrdersList, langProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── VIEW 1: Broadcast Demands from Regional Warehouses ───
  Widget _buildBroadcastDemandsView(LanguageProvider langProvider) {
    if (_broadcastDemands.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAllData,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.store_mall_directory_rounded, size: 48, color: Color(0xFF90A4AE)),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'No open warehouse requirements currently.',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF5A7263)),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'When the regional warehouse broadcasts a new crop demand for your district, it will appear here instantly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF78909C)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        itemCount: _broadcastDemands.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final demand = _broadcastDemands[index];
          final crop = demand['crop_name'] as String;
          final localizedCrop = langProvider.translateProduce(crop);
          final qtyKg = demand['quantity_kg'] as double;
          final pricePerKg = demand['price_per_kg'] as double;
          final totalPayout = demand['total_payout'] as double;
          final district = demand['district'] as String;

          final qtyDisplay = qtyKg >= 1000
              ? '${(qtyKg / 1000).toStringAsFixed(0)} MT'
              : '${qtyKg.toInt()} KG';

          return Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCCE4D3), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF136A36).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Warehouse Hub Header & Escrow Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Icons.warehouse_rounded, size: 14, color: Color(0xFF136A36)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              demand['warehouse_name'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF142C1E),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFFC6E7CD)),
                      ),
                      child: Text(
                        '100% Escrow Funded',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF136A36),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Crop & Quantity Row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Center(
                        child: Icon(Icons.eco_rounded, color: Color(0xFF16A34A), size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                localizedCrop.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF142C1E),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  demand['quality_grade'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0369A1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Requirement: $qtyDisplay • Area: $district',
                            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF527560)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Compact Pricing Summary Grid
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8EFE9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offered Purchase Rate',
                            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF758D7E)),
                          ),
                          Text(
                            '₹ ${pricePerKg.toStringAsFixed(2)}/kg (₹ ${(pricePerKg * 100).toStringAsFixed(0)}/Qtl)',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF142C1E),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total DBT Payout',
                            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF136A36), fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '₹ ${NumberFormatHelper.formatRupees(totalPayout)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF136A36),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Accept Action Button
                ElevatedButton(
                  onPressed: _isActionLoading ? null : () => _confirmAndAcceptDemand(demand),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF136A36),
                    padding: const EdgeInsets.symmetric(vertical: 9.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Accept & Fulfill Demand (₹ ${NumberFormatHelper.formatRupees(totalPayout)})',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
    );
  }

  // ─── VIEW 2: My Accepted / Direct Orders ───
  Widget _buildMyOrdersView(List<Map<String, dynamic>> filteredList, LanguageProvider langProvider) {
    return Column(
      children: [
        // Filter pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterPill('All', langProvider.translate('filter_all')),
                const SizedBox(width: 8),
                _buildFilterPill('In Process', 'In Process'),
                const SizedBox(width: 8),
                _buildFilterPill('New', langProvider.translate('filter_new')),
                const SizedBox(width: 8),
                _buildFilterPill('Completed', langProvider.translate('filter_completed')),
              ],
            ),
          ),
        ),

        Expanded(
          child: filteredList.isEmpty
              ? Center(
                  child: Text(
                    'No $_selectedFilter orders found.',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrdersInternal,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
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
                      } else if (status == 'In Process' || status == 'In Processing') {
                        statusBg = const Color(0xFFE0F2FE);
                        statusColor = const Color(0xFF0369A1);
                      } else {
                        statusBg = const Color(0xFFE8F5E9);
                        statusColor = const Color(0xFF136A36);
                      }

                      return InkWell(
                        onTap: () => _showOrderDetails(order),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCFEFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFBCE0C6), width: 1.2),
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

                              Text(
                                order['buyer'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF162D1F),
                                ),
                              ),
                              const SizedBox(height: 6),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$localizedItems (${order['quantity']})',
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
                                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF5A7263)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    order['amount'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF142C1E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    order['date'] as String,
                                    style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF7E9486)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        langProvider.translate('view_details_btn'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF136A36),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF136A36)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF136A36) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF136A36) : const Color(0xFFE4EDE7),
            width: 1.2,
          ),
        ),
        child: Text(
          displayLabel,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF4A6253),
          ),
        ),
      ),
    );
  }
}

class NumberFormatHelper {
  static String formatRupees(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount.toString()) ?? 0);
    final str = val.toStringAsFixed(0);
    if (str.length <= 3) return str;
    String lastThree = str.substring(str.length - 3);
    String otherNumbers = str.substring(0, str.length - 3);
    otherNumbers = otherNumbers.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$otherNumbers,$lastThree';
  }
}
