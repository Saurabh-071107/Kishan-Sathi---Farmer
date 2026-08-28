import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';
import 'warehouse_sale_screen.dart';
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
  bool _isSimulatingInspection = false;

  @override
  void initState() {
    super.initState();
    _productData = Map<String, dynamic>.from(widget.product);
  }

  void _simulateInspectionApproval() async {
    setState(() => _isSimulatingInspection = true);
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _isSimulatingInspection = false;
      _productData['status'] = 'Quality Verified';
      _productData['grade'] = 'Grade A';
      _productData['price'] = '₹ 2,850 / Qtl';
      _productData['assessedPrice'] = '₹ 2,850 / Qtl';
      _productData['totalValue'] = '₹ 1,42,500';
      _productData['inspectionReport'] = {
        'status': 'Verified',
        'inspector': 'Er. Ankit Sharma (Govt Agri QC)',
        'lab': 'Sehore APMC Quality Testing Lab #4',
        'certNo': 'AGRI-QC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'verifiedDate': 'Today, Just now',
        'moisture': '11.2%',
        'purity': '98.8%',
        'foreignMatter': '0.5%',
        'assignedGrade': 'Grade A',
        'assessedRate': '₹ 2,850 / Qtl',
      };
    });

    widget.onProductUpdated?.call(_productData);
  }

  void _navigateToWarehouseSale() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => WarehouseSaleScreen(product: _productData),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _productData = updated;
      });
      widget.onProductUpdated?.call(updated);
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

                    // Warehouse Purchase Orders Preview Card (for verified produce)
                    if (isVerified) ...[
                      AppFadeSlideAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: _buildWarehouseOrdersPreviewCard(langProvider),
                      ),
                      const SizedBox(height: 24),

                      // Primary Call to Action: Review & Accept Warehouse Orders
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _navigateToWarehouseSale,
                          icon: const Icon(Icons.receipt_long_rounded, size: 20, color: Colors.white),
                          label: Text(
                            langProvider.translate('review_warehouse_orders'),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF136A36),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(0xFF136A36).withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ] else if (isSold) ...[
                      AppFadeSlideAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: _buildSoldToWarehouseCard(langProvider),
                      ),
                    ],
                  ] else if (isUnderInspection) ...[
                    AppFadeSlideAnimation(
                      delay: const Duration(milliseconds: 140),
                      child: _buildUnderInspectionCard(inspectionReport, langProvider),
                    ),
                    const SizedBox(height: 20),

                    // Demo / Testing Action to trigger inspection completion
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FAF7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD3E7D8), width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.science_rounded, color: Color(0xFF136A36), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Inspection Team Verification',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF134E2A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Quality inspector updates test results from field QC app. Tap below to simulate official inspection approval.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF557762),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isSimulatingInspection ? null : _simulateInspectionApproval,
                              icon: _isSimulatingInspection
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.verified_rounded, size: 18, color: Colors.white),
                              label: Text(
                                _isSimulatingInspection ? 'Updating Certificate...' : 'Verify Quality & Assign Grade A',
                                style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF136A36),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
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

    if (status == 'Quality Verified') {
      bg = const Color(0xFFEAF5EB);
      border = const Color(0xFFC7E4CC);
      text = const Color(0xFF136A36);
      icon = Icons.verified_rounded;
      title = langProvider.translate('status_quality_verified');
      desc = 'Lab testing completed. Official Quality Certificate issued with Grade A rating.';
    } else if (status == 'Sold to Warehouse') {
      bg = const Color(0xFFEAF2FC);
      border = const Color(0xFFC5DAF5);
      text = const Color(0xFF1976D2);
      icon = Icons.warehouse_rounded;
      title = langProvider.translate('status_sold_warehouse');
      desc = 'Produce successfully procured by accredited warehouse with valid e-NWR receipt.';
    } else {
      bg = const Color(0xFFFFF3E0);
      border = const Color(0xFFFFD180);
      text = const Color(0xFFE65100);
      icon = Icons.hourglass_top_rounded;
      title = langProvider.translate('status_under_inspection');
      desc = 'Government QC officer scheduled to collect samples and test quality parameters.';
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5E8DA), width: 1.4),
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

          _buildCertRow(langProvider.translate('lab_cert_no'), report['certNo'] ?? 'AGRI-QC-984210'),
          _buildCertRow(langProvider.translate('inspector_name'), report['inspector'] ?? 'Er. Ankit Sharma (Govt Agri QC)'),
          _buildCertRow('Testing Facility', report['lab'] ?? 'Sehore APMC Quality Lab #4'),
          _buildCertRow('Inspection Date', report['verifiedDate'] ?? '28 May 2026, 11:15 AM'),
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
                'Certified Quality Assessed Rate',
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
                    const Icon(Icons.lock_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Rate Locked',
                      style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _productData['price'] as String? ?? '₹ 2,850 / Qtl',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Divider(color: Color(0xFF2E754C), height: 18),
          Text(
            'All official warehouse purchase orders are strictly locked to this certified rate.',
            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFFD4EEDC)),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseOrdersPreviewCard(LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC3E3CB), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Color(0xFF136A36), size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        langProvider.translate('incoming_warehouse_orders'),
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF133A20),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF136A36),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '3 ${langProvider.translate('orders_available')}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildMiniOrderRow('PO-CWC-2026-9814', 'CWC Sehore Godown', _productData['price'] as String? ?? '₹ 2,850 / Qtl'),
          const SizedBox(height: 6),
          _buildMiniOrderRow('PO-MPWLC-2026-4402', 'MP State Godown #4', _productData['price'] as String? ?? '₹ 2,850 / Qtl'),
          const SizedBox(height: 6),
          _buildMiniOrderRow('PO-NAWC-2026-7731', 'National Agro Godown Hub', _productData['price'] as String? ?? '₹ 2,850 / Qtl'),
          const SizedBox(height: 10),
          Text(
            langProvider.translate('warehouse_orders_notice'),
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF4C6B56)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniOrderRow(String poId, String whName, String rate) {
    return InkWell(
      onTap: _navigateToWarehouseSale,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD6EADA)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                poId,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF136A36)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                whName,
                style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF1C3524)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              rate,
              style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF136A36)),
            ),
          ],
        ),
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

  Widget _buildUnderInspectionCard(Map<String, dynamic> report, LanguageProvider langProvider) {
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
              const Icon(Icons.schedule_rounded, color: Color(0xFFE65100), size: 20),
              const SizedBox(width: 8),
              Text(
                'Inspection Schedule Details',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B2F22),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          _buildCertRow('Assigned Officer', report['inspector'] ?? 'Er. Ankit Sharma (Govt Agri QC)'),
          _buildCertRow('Testing Lab', report['lab'] ?? 'Sehore APMC Lab #4'),
          _buildCertRow('Scheduled Visit', report['visitDate'] ?? 'Tomorrow, 10:30 AM'),
          _buildCertRow('Certificate Reference', report['certNo'] ?? 'AGRI-QC-PENDING'),
          const SizedBox(height: 10),
          Text(
            'Keep 500g crop sample ready in clean packaging. Once tested, the grade and evaluated Mandi price will automatically appear on your app, unlocking official warehouse purchase orders.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color(0xFF758D7E),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
