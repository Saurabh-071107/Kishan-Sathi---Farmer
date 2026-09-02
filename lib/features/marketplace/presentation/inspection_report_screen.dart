import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';
import 'widgets/crop_thumbnail_art.dart';

class InspectionReportScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final ValueChanged<Map<String, dynamic>>? onProductUpdated;

  const InspectionReportScreen({
    super.key,
    required this.product,
    this.onProductUpdated,
  });

  @override
  State<InspectionReportScreen> createState() => _InspectionReportScreenState();
}

class _InspectionReportScreenState extends State<InspectionReportScreen> {
  late Map<String, dynamic> _productData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _productData = Map<String, dynamic>.from(widget.product);
    _refreshProduceData();
  }

  Future<void> _refreshProduceData() async {
    final prodId = _productData['id'];
    if (prodId == null) return;
    
    setState(() => _isRefreshing = true);
    try {
      final res = await ApiService().get('/produce/$prodId');

      if (res != null && res is Map<String, dynamic> && mounted) {
        final rawStatus = (res['status'] ?? '').toString().toLowerCase();
        String displayStatus;
        if (['approved', 'verified', 'inspected', 'passed'].contains(rawStatus)) {
          displayStatus = 'Quality Verified';
        } else if (['sold', 'completed', 'procured'].contains(rawStatus)) {
          displayStatus = 'Sold to Warehouse';
        } else if (['rejected', 'failed'].contains(rawStatus)) {
          displayStatus = 'Rejected';
        } else {
          displayStatus = 'Under Inspection';
        }

        final num kgNum = (res['quantity_kg'] as num?) ?? (((res['available_mt'] as num?) ?? 0) * 1000);
        final double kg = kgNum.toDouble();
        String qtyDisplay;
        if (kg >= 1000) {
          final double mt = kg / 1000;
          qtyDisplay = '${mt.toStringAsFixed(mt % 1 == 0 ? 0 : 2)} MT';
        } else if (kg >= 100) {
          final double qtl = kg / 100;
          qtyDisplay = '${qtl.toStringAsFixed(qtl % 1 == 0 ? 0 : 1)} Quintal';
        } else {
          qtyDisplay = '${kg.toInt()} kg';
        }

        final double pricePerKg = (res['price_per_kg'] as num?)?.toDouble() ?? 0;
        final String priceStr = pricePerKg > 0 
            ? '₹ ${(pricePerKg * 100).toStringAsFixed(0)} / Qtl' 
            : 'Pending QC';
        final String assessedStr = pricePerKg > 0 
            ? '₹ ${pricePerKg.toStringAsFixed(1)} / Kg' 
            : 'Under QC Check';
        final double totalVal = pricePerKg * kg;
        final String totalValStr = totalVal > 0 
            ? '₹ ${totalVal.toStringAsFixed(0)}' 
            : 'TBD';

        setState(() {
          _productData = {
            ..._productData,
            ...res,
            'name': res['product_name'] ?? _productData['name'],
            'quantity': qtyDisplay,
            'quantity_kg': kg,
            'price': priceStr,
            'assessedPrice': assessedStr,
            'price_per_kg': pricePerKg,
            'totalValue': totalValStr,
            'grade': res['grade'] ?? (displayStatus == 'Quality Verified' ? 'Grade A' : 'Pending'),
            'location': res['district'] ?? _productData['location'] ?? 'Farm',
            'status': displayStatus,
            'rawStatus': rawStatus,
            'scheduled_visit': res['scheduled_visit'],
            'inspector_name': res['inspector_name'],
          };
        });
        widget.onProductUpdated?.call(_productData);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final status = _productData['status'] as String? ?? 'Under Inspection';
    final isVerified = status == 'Quality Verified';
    final isSold = status == 'Sold to Warehouse';
    final isUnderInspection = status == 'Under Inspection';

    final rawName = _productData['name'] as String? ?? 'Produce';
    final localizedName = langProvider.translateProduce(rawName);
    final inspectionReport = _productData['inspectionReport'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF142C1E), size: 24),
            onPressed: () => Navigator.pop(context, _productData),
          ),
        ),
        title: Text(
          langProvider.translate('inspection_report'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF142C1E),
          ),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh_rounded, color: Color(0xFF142C1E)),
            onPressed: _isRefreshing ? null : _refreshProduceData,
            tooltip: 'Refresh Status',
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: _refreshProduceData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ================= TOP PRODUCE HERO CARD =================
                    AppFadeSlideAnimation(
                      delay: Duration.zero,
                      child: _buildProduceSummaryCard(localizedName, langProvider),
                    ),
                    const SizedBox(height: 16),

                    // ================= INSPECTION STATUS BANNER =================
                    AppFadeSlideAnimation(
                      delay: const Duration(milliseconds: 80),
                      child: _buildStatusBanner(status, langProvider),
                    ),
                    const SizedBox(height: 16),

                    // ================= QUALITY LAB TEST PARAMETERS =================
                    if (isVerified || isSold) ...[
                      AppFadeSlideAnimation(
                        delay: const Duration(milliseconds: 140),
                        child: _buildLabParametersGrid(inspectionReport, langProvider),
                      ),
                      const SizedBox(height: 16),

                      AppFadeSlideAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: _buildOfficialCertificateCard(inspectionReport, langProvider),
                      ),
                      const SizedBox(height: 16),

                      AppFadeSlideAnimation(
                        delay: const Duration(milliseconds: 260),
                        child: _buildMandiValuationCard(langProvider),
                      ),
                      const SizedBox(height: 16),

                      if (isSold) ...[
                        AppFadeSlideAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: _buildSoldToWarehouseCard(langProvider),
                        ),
                      ],
                    ] else if (isUnderInspection) ...[
                      AppFadeSlideAnimation(
                        delay: const Duration(milliseconds: 140),
                        child: _buildUnderInspectionView(inspectionReport, langProvider),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProduceSummaryCard(String localizedName, LanguageProvider langProvider) {
    CropThumbnailType thumb = CropThumbnailType.wheat;
    if (_productData['thumbnail'] is CropThumbnailType) {
      thumb = _productData['thumbnail'] as CropThumbnailType;
    } else {
      final name = (_productData['name'] as String? ?? '').toLowerCase();
      if (name.contains('tomato')) thumb = CropThumbnailType.tomatoes;
      if (name.contains('potato') || name.contains('aloo')) thumb = CropThumbnailType.potatoes;
      if (name.contains('chana') || name.contains('dal')) thumb = CropThumbnailType.chanaDal;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CropThumbnailArt(type: thumb, size: 76),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedName,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF142B1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quantity: ${_productData['quantity'] ?? '50 Qtl'}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A7263),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Location: ${_productData['location'] ?? 'Sehore Farm Gate, MP'}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF7A9382),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(String status, LanguageProvider langProvider) {
    Color bg;
    Color border;
    Color text;
    IconData icon;
    String title;
    String desc;

    final scheduledVisit = _productData['scheduled_visit'];
    final bool hasScheduledVisit = scheduledVisit != null && scheduledVisit.toString().trim().isNotEmpty;

    if (status == 'Quality Verified') {
      bg = const Color(0xFFEAF5EB);
      border = const Color(0xFFC7E4CC);
      text = const Color(0xFF136A36);
      icon = Icons.verified_rounded;
      title = langProvider.translate('status_quality_verified');
      desc = 'Lab testing completed. Official Quality Certificate issued with ${_productData['grade'] ?? 'Grade A'} rating.';
    } else if (status == 'Sold to Warehouse') {
      bg = const Color(0xFFEAF2FC);
      border = const Color(0xFFC5DAF5);
      text = const Color(0xFF1976D2);
      icon = Icons.warehouse_rounded;
      title = langProvider.translate('status_sold_warehouse');
      desc = 'Produce successfully procured by accredited warehouse with valid e-NWR receipt.';
    } else if (hasScheduledVisit) {
      bg = const Color(0xFFEBF5FB);
      border = const Color(0xFFBEE3F8);
      text = const Color(0xFF0288D1);
      icon = Icons.event_available_rounded;
      title = 'Inspection Visit Scheduled';
      desc = 'Warehouse QC officer scheduled to visit your farm: $scheduledVisit.';
    } else {
      bg = const Color(0xFFFFF8E7);
      border = const Color(0xFFFFE0B2);
      text = const Color(0xFFD97706);
      icon = Icons.hourglass_top_rounded;
      title = 'Awaiting Warehouse Schedule';
      desc = 'Listing received by regional warehouse. Inspection schedule will appear once assigned by warehouse manager.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: text, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF4C6053),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabParametersGrid(Map<String, dynamic> report, LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EDE8), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Lab Quality Metrics',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF142B1D),
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
                  'ISO 17025 Certified Lab',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF136A36),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x2 Grid of Quality Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: langProvider.translate('moisture_level'),
                  value: report['moisture'] ?? '11.2%',
                  standard: 'Ideal: < 12.0%',
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFF1976D2),
                  isPass: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: langProvider.translate('purity_rate'),
                  value: report['purity'] ?? '98.8%',
                  standard: 'Min: 97.0%',
                  icon: Icons.grain_rounded,
                  iconColor: const Color(0xFF2E7D32),
                  isPass: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: langProvider.translate('foreign_matter'),
                  value: report['foreignMatter'] ?? '0.5%',
                  standard: 'Max: 1.0%',
                  icon: Icons.filter_alt_rounded,
                  iconColor: const Color(0xFFE65100),
                  isPass: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: langProvider.translate('assigned_grade'),
                  value: report['assignedGrade'] ?? 'Grade A',
                  standard: 'Top Quality',
                  icon: Icons.military_tech_rounded,
                  iconColor: const Color(0xFF136A36),
                  isPass: true,
                  isHighlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String standard,
    required IconData icon,
    required Color iconColor,
    required bool isPass,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFEAF5EB) : const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlight ? const Color(0xFF136A36) : const Color(0xFFE2EDE5),
          width: isHighlight ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5A7263),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isHighlight ? const Color(0xFF136A36) : const Color(0xFF183222),
                ),
              ),
              if (isPass)
                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            standard,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF7E9687),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialCertificateCard(Map<String, dynamic> report, LanguageProvider langProvider) {
    final certNo = report['certNo'] ?? 'AGRI-QC-${_productData['id']?.toString().split('-')[0].toUpperCase() ?? '2026-9810'}';
    final inspector = _productData['inspector_name'] ?? report['inspector'] ?? 'Govt Certified Quality Inspector';
    final lab = report['lab'] ?? '${_productData['location'] ?? 'Regional'} APMC Quality Testing Lab';
    final verifiedDate = report['verifiedDate'] ?? 'Verified Quality Lot';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4EBD8), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_membership_rounded, color: Color(0xFF136A36), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  langProvider.translate('inspection_cert_title'),
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF142B1D),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          _buildCertRow(langProvider.translate('lab_cert_no'), certNo),
          _buildCertRow(langProvider.translate('inspector_name'), inspector),
          _buildCertRow('Testing Facility', lab),
          _buildCertRow('Inspection Status', verifiedDate),
        ],
      ),
    );
  }

  Widget _buildCertRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B8374)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF193122)),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandiValuationCard(LanguageProvider langProvider) {
    final grade = _productData['grade'] as String? ?? 'Grade A';
    final currentPrice = _productData['price'] as String? ?? '₹ 2,850 / Qtl';
    final pricePerKg = (_productData['price_per_kg'] as num?)?.toDouble() ?? 28.5;
    final qtyKg = (_productData['quantity_kg'] as num?)?.toDouble() ?? 1000;
    final totalVal = pricePerKg * qtyKg;

    // Slot calculations
    final minSlot = pricePerKg * 0.95;
    final maxSlot = pricePerKg * 1.05;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF136A36), Color(0xFF0F4E29)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF136A36).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'APMC Mandi Quality Price Slot',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFC7EBD2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$grade Certified',
                      style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentPrice,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(₹ ${pricePerKg.toStringAsFixed(2)} / kg)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB8E2C6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Authorized Price Band:',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFC7EBD2)),
                ),
                Text(
                  '₹ ${(minSlot * 100).toStringAsFixed(0)} - ₹ ${(maxSlot * 100).toStringAsFixed(0)} / Qtl',
                  style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
          if (totalVal > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E754C).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Guaranteed DBT Payout:',
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFC7EBD2)),
                  ),
                  Text(
                    '₹ ${totalVal.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFFFFD54F)),
                  ),
                ],
              ),
            ),
          ],
          const Divider(color: Color(0xFF2E754C), height: 18),
          Text(
            'Both farmer selling price and warehouse procurement orders are strictly locked to this APMC Quality Grade Standard slot.',
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFD4EEDC)),
          ),
        ],
      ),
    );
  }

  Widget _buildSoldToWarehouseCard(LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAD5F5), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF1976D2), size: 20),
              const SizedBox(width: 8),
              Text(
                'Procured by Accredited Warehouse',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF104B8A),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          _buildCertRow('Accepted Warehouse', _productData['warehouseName'] ?? 'Central Warehousing Corp (CWC)'),
          _buildCertRow('e-NWR Receipt ID', _productData['enwrId'] ?? 'e-NWR-2026-MP-491028'),
          _buildCertRow('Settlement Status', '100% Direct DBT Payout Completed'),
        ],
      ),
    );
  }

  Widget _buildUnderInspectionView(Map<String, dynamic> report, LanguageProvider langProvider) {
    final scheduledVisit = _productData['scheduled_visit'] ?? report['visitDate'];
    final bool hasScheduledVisit = scheduledVisit != null && scheduledVisit.toString().trim().isNotEmpty;
    final inspector = _productData['inspector_name'] ?? report['inspector'] ?? 'Assigned Field QC Officer';
    final location = _productData['location'] ?? 'Regional';

    if (hasScheduledVisit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildScheduledVisitCard(scheduledVisit.toString(), inspector, location),
          const SizedBox(height: 16),
          _buildVerificationTimeline(activeStepIndex: 2),
          const SizedBox(height: 16),
          _buildPreparationGuidelinesCard(isScheduled: true),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVerificationTimeline(activeStepIndex: 1),
          const SizedBox(height: 16),
          _buildPreparationGuidelinesCard(isScheduled: false),
          const SizedBox(height: 16),
          _buildWarehouseHubContactCard(location),
        ],
      );
    }
  }

  Widget _buildScheduledVisitCard(String scheduledVisit, String inspector, String location) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBCE0C6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF136A36).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_available_rounded, color: Color(0xFF136A36), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirmed Inspection Slot',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF134A26),
                      ),
                    ),
                    Text(
                      'Assigned by Regional Warehouse',
                      style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF5A7A64)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          _buildCertRow('Scheduled Time Slot', scheduledVisit),
          _buildCertRow('Assigned QC Officer', inspector),
          _buildCertRow('Testing Facility', location.contains('Hub') ? location : '$location Agri QC Hub'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF136A36)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Keep 500g lot sample ready at farm gate for sampling. Officer will verify moisture and purity.',
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF2C553B), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationTimeline({required int activeStepIndex}) {
    final steps = [
      {
        'title': 'Produce Listed',
        'subtitle': 'Lot registered on Kisan Sathi network',
      },
      {
        'title': 'Warehouse Review & Slot Booking',
        'subtitle': 'Manager assigns inspector and time slot',
      },
      {
        'title': 'Physical Farm Gate Sampling',
        'subtitle': 'Officer collects sample and verifies lot',
      },
      {
        'title': 'Lab QC & Grade Certification',
        'subtitle': 'Grade assignment and MSP/mandi rate lock',
      },
      {
        'title': 'Warehouse Procurement & DBT',
        'subtitle': '100% Escrow purchase and instant payout',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EDE7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: Color(0xFF136A36), size: 20),
              const SizedBox(width: 8),
              Text(
                'Verification Roadmap',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF142C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: i < activeStepIndex
                            ? const Color(0xFF136A36)
                            : (i == activeStepIndex
                                ? const Color(0xFFE65100)
                                : const Color(0xFFE0E0E0)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: i < activeStepIndex
                            ? const Icon(Icons.check, size: 15, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: i == activeStepIndex ? Colors.white : const Color(0xFF757575),
                                ),
                              ),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2,
                        height: 28,
                        color: i < activeStepIndex
                            ? const Color(0xFF136A36)
                            : const Color(0xFFE0E0E0),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i]['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: i == activeStepIndex ? FontWeight.w700 : FontWeight.w600,
                          color: i == activeStepIndex
                              ? const Color(0xFFE65100)
                              : (i < activeStepIndex ? const Color(0xFF136A36) : const Color(0xFF6B7280)),
                        ),
                      ),
                      Text(
                        steps[i]['subtitle']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF8C9B91),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreparationGuidelinesCard({required bool isScheduled}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5E8DA), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 8),
              Text(
                'Sample Preparation Guidelines',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF173823),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineRow('🌾', 'Representative Sample', 'Take 500g sample evenly mixed across harvest sacks.'),
          const SizedBox(height: 8),
          _buildGuidelineRow('📦', 'Dry & Clean Packaging', 'Keep sample protected in a clean, moisture-free container.'),
          const SizedBox(height: 8),
          _buildGuidelineRow('📱', 'SMS & WhatsApp Notifications', isScheduled ? 'You will be notified once testing report is ready.' : 'You will receive SMS alert the moment warehouse fixes the slot.'),
        ],
      ),
    );
  }

  Widget _buildGuidelineRow(String emoji, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F3D2A),
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF5A7263),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseHubContactCard(String location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warehouse_rounded, color: Color(0xFF136A36), size: 18),
              const SizedBox(width: 8),
              Text(
                'Assigned Regional Hub',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF163823),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          _buildCertRow('Regional Facility', location.contains('Hub') ? location : '$location State Agricultural Godown'),
          _buildCertRow('Kisan Help Desk', '1800-180-1551 (Toll-Free)'),
          _buildCertRow('Schedule Turnaround', 'Usually within 24 Hours'),
        ],
      ),
    );
  }
}
