import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/device_hardware_service.dart';
import 'order_action_splash_page.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late String _status;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order['status'] as String? ?? 'New';
  }

  String _getCropAsset(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('tomato')) {
      return AppAssets.realTomatoes;
    } else if (lower.contains('potato') || lower.contains('aloo')) {
      return AppAssets.realPotatoes;
    } else if (lower.contains('dal') || lower.contains('chana') || lower.contains('pulse')) {
      return AppAssets.realChanaDal;
    }
    return AppAssets.realWheat;
  }

  void _acceptOrder() async {
    setState(() => _isProcessingAction = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _status = 'In Process';
      widget.order['status'] = 'In Process';
      _isProcessingAction = false;
    });

    if (mounted) {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => OrderActionSplashPage(
            type: OrderSplashType.accepted,
            order: widget.order,
          ),
        ),
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _declineOrder() async {
    final shouldDecline = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Decline Order?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to decline this order from ${widget.order['buyer']}?',
          style: GoogleFonts.poppins(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep Order', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Yes, Decline', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldDecline == true && mounted) {
      Navigator.pop(context, {'cancelled': true, 'id': widget.order['id']});
    }
  }

  void _markAsCompleted() async {
    setState(() => _isProcessingAction = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _status = 'Completed';
      widget.order['status'] = 'Completed';
      _isProcessingAction = false;
    });

    if (mounted) {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => OrderActionSplashPage(
            type: OrderSplashType.delivered,
            order: widget.order,
          ),
        ),
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final orderId = widget.order['id'] as String? ?? '#ORD12345';
    final buyerName = langProvider.translateProduce(widget.order['buyer'] as String? ?? 'Ramesh Kirana Store');
    final buyerPhone = widget.order['phone'] as String? ?? '+91 78251 23456';
    final buyerAddress = widget.order['address'] as String? ?? 'Indore, Madhya Pradesh';
    final itemsRaw = widget.order['items'] as String? ?? 'Wheat - 20 Kg';
    final itemsText = langProvider.translateProduce(itemsRaw);
    final amountText = widget.order['amount'] as String? ?? '₹ 560';
    final dateText = widget.order['date'] as String? ?? '20 May 2026, 10:30 AM';
    final paymentStatus = widget.order['paymentStatus'] as String? ?? 'Paid via UPI (Escrow)';
    final cropImg = _getCropAsset(itemsRaw);

    Color statusBg;
    Color statusColor;
    if (_status == 'New') {
      statusBg = const Color(0xFFFFF0E0);
      statusColor = const Color(0xFFE65100);
    } else if (_status == 'In Processing' || _status == 'Processing') {
      statusBg = const Color(0xFFE1F5FE);
      statusColor = const Color(0xFF0288D1);
    } else {
      statusBg = const Color(0xFFE8F5E9);
      statusColor = const Color(0xFF136A36);
    }

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
          langProvider.translate('order_details'),
          style: GoogleFonts.poppins(
            color: const Color(0xFF142B1D),
            fontSize: 18.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= 1. ORDER SUMMARY CARD =================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.025),
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
                            Text(
                              '${langProvider.translate('order_id')}: $orderId',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF758C7E),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                langProvider.translateProduce(_status),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                cropImg,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 56,
                                  height: 56,
                                  color: const Color(0xFFE8F5E9),
                                  child: const Icon(Icons.eco_rounded, color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemsText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF162D1F),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    dateText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: const Color(0xFF7E9486),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              amountText,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF142C1E),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment Status',
                              style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF6B8374)),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  paymentStatus,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF136A36),
                                  ),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= 2. BUYER / WAREHOUSE DETAILS CARD =================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.025),
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
                            Expanded(
                              child: Text(
                                widget.order['isWarehouseOrder'] == true ? 'Warehouse Information' : langProvider.translate('buyer_info'),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF162E1F),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.order['isWarehouseOrder'] == true ? 'Accredited Godown' : 'Verified Buyer',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF136A36),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.order['isWarehouseOrder'] == true ? Icons.warehouse_rounded : Icons.storefront_rounded,
                                color: const Color(0xFF136A36),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    buyerName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF162E1F),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    buyerAddress,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: const Color(0xFF758C7E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Action row: Call Buyer
                        InkWell(
                          onTap: () {
                            final cleanPhone = buyerPhone.replaceAll(RegExp(r'[^0-9+]'), '');
                            DeviceHardwareService().launchPhoneDialer(cleanPhone);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F8F4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD6EADA)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.call_rounded, color: Color(0xFF136A36), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  buyerPhone,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF162D1F),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  langProvider.translate('tap_to_call'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF136A36),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= 3. PRODUCT DETAILS CARD =================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.025),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.translate('product_details'),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF162E1F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Commodity Item', itemsText),
                        _buildDetailRow('Total Amount', amountText),
                        _buildDetailRow('Payment Mode', paymentStatus),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= 3. ORDER TIMELINE PROGRESS =================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.025),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.translate('order_timeline'),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF162E1F),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTimelineStep(
                          stepNum: '1',
                          title: 'Order Placed by Buyer',
                          subtitle: dateText,
                          isCompleted: true,
                          isCurrent: _status == 'New',
                        ),
                        _buildTimelineConnector(isCompleted: _status != 'New'),
                        _buildTimelineStep(
                          stepNum: '2',
                          title: 'Accepted & Ready for Pickup',
                          subtitle: _status != 'New' ? 'Farmer confirmed stock' : 'Pending farmer acceptance',
                          isCompleted: _status == 'In Process' || _status == 'In Processing' || _status == 'Completed',
                          isCurrent: _status == 'In Process' || _status == 'In Processing',
                        ),
                        _buildTimelineConnector(isCompleted: _status == 'Completed'),
                        _buildTimelineStep(
                          stepNum: '3',
                          title: 'Delivered & Payment Released',
                          subtitle: _status == 'Completed' ? 'Funds added to Kisan Wallet' : 'Pending delivery',
                          isCompleted: _status == 'Completed',
                          isCurrent: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================= 4. ACTION BUTTONS =================
                  if (_status == 'New') ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isProcessingAction ? null : _declineOrder,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD32F2F),
                              side: const BorderSide(color: Color(0xFFEF9A9A), width: 1.4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              langProvider.translate('decline_order'),
                              style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isProcessingAction ? null : _acceptOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF136A36),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: const Color(0xFF136A36).withValues(alpha: 0.3),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isProcessingAction
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(
                                    langProvider.translate('accept_order'),
                                    style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_status == 'In Process' || _status == 'In Processing') ...[
                    ElevatedButton.icon(
                      onPressed: _isProcessingAction ? null : _markAsCompleted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF136A36),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0xFF136A36).withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text(
                        'Mark as Delivered & Complete',
                        style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF6B8374)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF162D1F)),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String stepNum,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color circleColor;
    Color textColor;
    if (isCompleted) {
      circleColor = const Color(0xFF136A36);
      textColor = const Color(0xFF162D1F);
    } else if (isCurrent) {
      circleColor = const Color(0xFFE65100);
      textColor = const Color(0xFF162D1F);
    } else {
      circleColor = const Color(0xFFD4DEC6);
      textColor = const Color(0xFF8B9E92);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Text(
                    stepNum,
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF758C7E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector({required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 24,
        color: isCompleted ? const Color(0xFF136A36) : const Color(0xFFE0E8E2),
      ),
    );
  }
}
