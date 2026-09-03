import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/api_service.dart';
class WarehouseSaleScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const WarehouseSaleScreen({super.key, required this.product});

  @override
  State<WarehouseSaleScreen> createState() => _WarehouseSaleScreenState();
}

class _WarehouseSaleScreenState extends State<WarehouseSaleScreen> {
  int _selectedOrderIndex = 0;
  String _transportMode = 'pickup'; // 'pickup' or 'self'
  bool _isProcessing = false;
  double _selectedQuantity = 50.0;
  double _maxQuantity = 50.0;

  late int _lockedRateNumeric;
  late String _lockedRateString;
  late String _unit;
  late List<Map<String, dynamic>> _warehouseOrders;

  @override
  void initState() {
    super.initState();

    // 1. Parse quantity & unit
    final rawQty = widget.product['quantity'] as String? ?? '50 Qtl';
    final parsedQty = double.tryParse(rawQty.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 50.0;
    _maxQuantity = parsedQty > 0 ? parsedQty : 50.0;
    _selectedQuantity = _maxQuantity;

    if (rawQty.toLowerCase().contains('kg')) {
      _unit = 'Kg';
    } else if (rawQty.toLowerCase().contains('ton')) {
      _unit = 'Ton';
    } else {
      _unit = 'Qtl';
    }

    // 2. Extract Locked Assessed QC Rate
    final rawRate = widget.product['assessedPrice'] as String? ??
        widget.product['price'] as String? ??
        widget.product['inspectionReport']?['assessedRate'] as String? ??
        '₹ 2,850 / Qtl';

    final parsedRate = int.tryParse(rawRate.replaceAll(RegExp(r'[^0-9]'), '')) ?? 2850;
    _lockedRateNumeric = parsedRate > 0 ? parsedRate : 2850;
    _lockedRateString = '₹ ${_lockedRateNumeric.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / $_unit';

    // 3. Generate Official Warehouse Purchase Orders for this verified batch
    _warehouseOrders = [];
    _fetchWarehouses();
  }

  Future<void> _fetchWarehouses() async {
    try {
      final warehouses = await ApiService().getNearbyWarehouses(
        widget.product['district']?.toString() ?? 'Jaipur',
      );
      final availableWarehouses = warehouses.isEmpty
          ? await ApiService().getNearbyWarehouses('')
          : warehouses;
      if (mounted) {
        setState(() {
          _warehouseOrders = availableWarehouses.map((wh) {
            final isGovt = wh['name'].toString().toLowerCase().contains('state') || wh['name'].toString().toLowerCase().contains('central');
            final distStr = wh['district']?.toString() ?? 'Jaipur';
            return {
              'poNumber': 'PO-${wh['id']?.toString().toUpperCase().replaceAll('WH_', '') ?? '123'}-${DateTime.now().year}',
              'warehouseName': wh['name'] ?? 'State Warehouse',
              'warehouseId': wh['id'] ?? 'wh_jaipur_001',
              'type': isGovt ? 'State/Govt Central Godown' : 'WDRA Accredited Hub',
              'wdraReg': 'WDRA Reg #${wh['pincode'] ?? '302001'}',
              'distance': '$distStr Hub (${wh['district'] ?? 'Local'})',
              'rate': _lockedRateNumeric,
              'rateText': _lockedRateString,
              'capacity': '${wh['capacity_mt'] ?? '5,000'} MT Capacity',
              'isGovt': isGovt,
              'pickupTime': 'Scheduled Logistics Dispatch',
              'escrowStatus': '100% Escrow Funded (Govt Verified)',
            };
          }).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _warehouseOrders = [];
        });
      }
    }
  }

  void _confirmSale() async {
    setState(() => _isProcessing = true);

    final selectedOrder = _warehouseOrders[_selectedOrderIndex];
    final totalPayout = (_selectedQuantity * _lockedRateNumeric).toInt();
    try {
      double quantityKg = _selectedQuantity;
      double pricePerKg = _lockedRateNumeric.toDouble();
      if (_unit.toLowerCase() == 'ton' || _unit.toLowerCase() == 'mt') {
        quantityKg = _selectedQuantity * 1000;
        pricePerKg = _lockedRateNumeric / 1000;
      } else if (_unit.toLowerCase() == 'qtl') {
        quantityKg = _selectedQuantity * 100;
        pricePerKg = _lockedRateNumeric / 100;
      }

      final created = await ApiService().createWarehouseOrder(
        warehouseId: selectedOrder['warehouseId'] as String,
        produceId: widget.product['id']?.toString(),
        productName: widget.product['name']?.toString() ?? 'Produce',
        quantityKg: quantityKg,
        pricePerKg: pricePerKg,
        district: widget.product['district']?.toString() ?? 'Sehore',
        notes: 'Transport: $_transportMode',
      );
      final enwrId = created['id']?.toString() ?? 'e-NWR-${DateTime.now().millisecondsSinceEpoch}';

      final remainingQty = _maxQuantity - _selectedQuantity;
      final updatedProduct = Map<String, dynamic>.from(widget.product);
      if (remainingQty <= 0) {
        updatedProduct['status'] = 'Sold to Warehouse';
        updatedProduct['quantity'] = '0 $_unit';
      } else {
        updatedProduct['status'] = widget.product['status'] ?? 'Quality Verified';
        updatedProduct['quantity'] = '${remainingQty.toStringAsFixed(remainingQty % 1 == 0 ? 0 : 1)} $_unit';
      }
      updatedProduct['warehouseName'] = selectedOrder['warehouseName'];
      updatedProduct['poNumber'] = selectedOrder['poNumber'];
      updatedProduct['enwrId'] = enwrId;
      updatedProduct['soldQuantity'] = '$_selectedQuantity $_unit';
      updatedProduct['soldAmount'] = '₹ ${totalPayout.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

      setState(() => _isProcessing = false);

      if (!mounted) return;
      _showReceiptModal(updatedProduct, selectedOrder, totalPayout, enwrId);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to create warehouse order: $error')));
    }
  }

  void _showReceiptModal(
    Map<String, dynamic> updatedProduct,
    Map<String, dynamic> selectedOrder,
    int totalPayout,
    String enwrId,
  ) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE6DF),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Green Check Icon
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 40),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              langProvider.translate('warehouse_sale_success'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF142B1D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              langProvider.translate('payout_credited_note'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF557762)),
            ),
            const SizedBox(height: 18),

            // Official e-NWR Certificate Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6FAF7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4E8DB), width: 1.4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded, color: Color(0xFF136A36), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Electronic Warehouse Receipt',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF142B1D),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'WDRA Verified',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF136A36),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  _buildReceiptRow('e-NWR ID', enwrId),
                  _buildReceiptRow('Purchase Order ID', selectedOrder['poNumber'] as String),
                  _buildReceiptRow('Warehouse', selectedOrder['warehouseName'] as String),
                  _buildReceiptRow('Produce Sold', '${widget.product['name']} (${widget.product['grade'] ?? 'Grade A'})'),
                  _buildReceiptRow('Quantity Deposited', '$_selectedQuantity $_unit'),
                  _buildReceiptRow('Certified Rate', _lockedRateString),
                  const Divider(height: 16),
                  _buildReceiptRow(
                    'Total Direct DBT Payout',
                    '₹ ${totalPayout.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // close bottom sheet
                  Navigator.pop(context, updatedProduct); // return to caller with updated product
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136A36),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Done & View Inventory',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF6B8374)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isHighlight ? 14.5 : 12,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                color: isHighlight ? const Color(0xFF136A36) : const Color(0xFF193122),
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final rawName = widget.product['name'] as String? ?? 'Produce';
    final localizedName = langProvider.translateProduce(rawName);
    
    if (_warehouseOrders.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final selectedOrder = _warehouseOrders[_selectedOrderIndex];
    final totalPayout = (_selectedQuantity * _lockedRateNumeric).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF142C1E), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          langProvider.translate('warehouse_orders_title'),
          style: GoogleFonts.poppins(
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF142C1E),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= VERIFIED LOT SUMMARY CARD =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F5E9), Color(0xFFF4FAF5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCDE4D2), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                localizedName,
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF142B1D),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF136A36),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                langProvider.translateProduce(widget.product['grade'] as String? ?? 'Grade A'),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFCCE4D2)),
                        const SizedBox(height: 10),

                        // Locked Price Callout
                        Row(
                          children: [
                            const Icon(Icons.lock_rounded, size: 16, color: Color(0xFF136A36)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${langProvider.translate('locked_assessed_rate')}: $_lockedRateString',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF136A36),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          langProvider.translate('warehouse_orders_notice'),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4C6B56),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================= INCOMING WAREHOUSE PURCHASE ORDERS =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          langProvider.translate('incoming_warehouse_orders'),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF152D1F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_warehouseOrders.length} ${langProvider.translate('orders_available')}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF136A36),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _warehouseOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = _warehouseOrders[index];
                      final isSelected = _selectedOrderIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedOrderIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF1F8F3) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF136A36) : const Color(0xFFE4ECE6),
                              width: isSelected ? 1.6 : 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(0xFF136A36).withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top PO Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3EFE6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      order['poNumber'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1B4E2B),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: order['isGovt'] == true ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      order['isGovt'] == true ? 'Govt Godown' : 'FPO Hub',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: order['isGovt'] == true ? const Color(0xFF136A36) : const Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                      color: isSelected ? const Color(0xFF136A36) : const Color(0xFF9EABA2),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order['warehouseName'] as String,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF132B1C),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${order['type']} • ${order['distance']}',
                                          style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF6B8374)),
                                        ),
                                        const SizedBox(height: 8),

                                        // Buying Rate locked
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFD2E6D7)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF136A36)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Buying Rate:',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xFF4C6B56),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                order['rateText'] as String,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF136A36),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        Row(
                                          children: [
                                            const Icon(Icons.verified_user_rounded, size: 13, color: Color(0xFF2E7D32)),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                order['escrowStatus'] as String,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF2E7D32),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ================= QUANTITY SELECTION SLIDER =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4ECE6), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              langProvider.translate('quantity_to_sell'),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF132B1C),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF5ED),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_selectedQuantity.toInt()} / ${_maxQuantity.toInt()} $_unit',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF136A36),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_maxQuantity > 1) ...[
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF136A36),
                              inactiveTrackColor: const Color(0xFFE0EAE3),
                              thumbColor: const Color(0xFF136A36),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _selectedQuantity,
                              min: 1.0,
                              max: _maxQuantity,
                              divisions: _maxQuantity.toInt() > 1 ? (_maxQuantity - 1).toInt() : 1,
                              onChanged: (val) => setState(() => _selectedQuantity = val),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ================= TRANSPORT LOGISTICS MODE =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4ECE6), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.translate('transport_method'),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF132B1C),
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildRadioOption(
                          value: 'pickup',
                          groupValue: _transportMode,
                          title: langProvider.translate('warehouse_pickup'),
                          subtitle: 'Truck dispatched to farm gate within 24 hours (Free)',
                          icon: Icons.local_shipping_rounded,
                          onChanged: (val) => setState(() => _transportMode = val!),
                        ),
                        const SizedBox(height: 8),

                        _buildRadioOption(
                          value: 'self',
                          groupValue: _transportMode,
                          title: langProvider.translate('farmer_self_drop'),
                          subtitle: 'Direct drop at warehouse unloading bay (Instant Slot)',
                          icon: Icons.agriculture_rounded,
                          onChanged: (val) => setState(() => _transportMode = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================= PAYOUT SUMMARY CARD =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF134E2A), Color(0xFF0D381D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF134E2A).withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Estimated Payout',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFBCE3C7),
                              ),
                            ),
                            Text(
                              '₹ ${totalPayout.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${_selectedQuantity.toInt()} $_unit × ${selectedOrder['rateText']}',
                                style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF9ECEAB)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Direct Bank / Wallet DBT',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ================= SUBMIT / ACCEPT ORDER BUTTON =================
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _confirmSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF136A36),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0xFF136A36).withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    langProvider.translate('accept_warehouse_order'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String title,
    required String subtitle,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F8F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF136A36) : const Color(0xFFE8EDE9),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isSelected ? const Color(0xFF136A36) : const Color(0xFF7A9382)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF152E1F),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B8374)),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: const Color(0xFF136A36),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
