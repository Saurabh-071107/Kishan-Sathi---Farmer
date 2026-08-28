import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';
import '../../../../core/widgets/scroll_reveal_item.dart';
import 'add_product_screen.dart';
import 'inspection_report_screen.dart';
import 'warehouse_sale_screen.dart';
import 'widgets/crop_thumbnail_art.dart';

class MyProductsTab extends StatefulWidget {
  const MyProductsTab({super.key});

  @override
  State<MyProductsTab> createState() => _MyProductsTabState();
}

class _MyProductsTabState extends State<MyProductsTab> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Wheat (Local Quality)',
      'quantity': '50 Qtl',
      'price': '₹ 2,850 / Qtl',
      'assessedPrice': '₹ 2,850 / Qtl',
      'totalValue': '₹ 1,42,500',
      'grade': 'Grade A',
      'location': 'Sehore Mandi Yard, MP',
      'views': 45,
      'status': 'Quality Verified',
      'thumbnail': CropThumbnailType.wheat,
      'inspectionReport': {
        'status': 'Verified',
        'inspector': 'Er. Ankit Sharma (Govt Agri QC)',
        'lab': 'Sehore APMC Quality Testing Lab #4',
        'certNo': 'AGRI-QC-984210',
        'verifiedDate': '26 May 2026, 11:15 AM',
        'moisture': '11.2%',
        'purity': '98.8%',
        'foreignMatter': '0.5%',
        'assignedGrade': 'Grade A',
        'assessedRate': '₹ 2,850 / Qtl',
      },
    },
    {
      'name': 'Tomatoes',
      'quantity': '100 Kg',
      'price': '₹ 20 / Kg',
      'assessedPrice': '₹ 20 / Kg',
      'totalValue': '₹ 2,000',
      'grade': 'Grade A',
      'location': 'Ashta Gram, Sehore',
      'views': 42,
      'status': 'Quality Verified',
      'thumbnail': CropThumbnailType.tomatoes,
      'inspectionReport': {
        'status': 'Verified',
        'inspector': 'Dr. S. K. Verma (Horticulture QC)',
        'lab': 'Bhopal Central Agro Testing Hub',
        'certNo': 'AGRI-QC-983109',
        'verifiedDate': '25 May 2026, 04:30 PM',
        'moisture': '14.0%',
        'purity': '99.1%',
        'foreignMatter': '0.2%',
        'assignedGrade': 'Grade A',
        'assessedRate': '₹ 20 / Kg',
      },
    },
    {
      'name': 'Yellow Soyabean',
      'quantity': '60 Qtl',
      'price': 'Pending Inspection',
      'assessedPrice': null,
      'totalValue': 'Awaiting Inspection',
      'grade': 'Under Inspection',
      'location': 'Sehore Farm Gate, MP',
      'views': 18,
      'status': 'Under Inspection',
      'thumbnail': CropThumbnailType.wheat,
      'inspectionReport': {
        'status': 'Scheduled',
        'inspector': 'Er. Ankit Sharma (Govt Agri QC)',
        'lab': 'Sehore APMC Quality Testing Lab #4',
        'certNo': 'AGRI-QC-PENDING-71',
        'visitDate': 'Tomorrow, 10:30 AM',
        'moisture': '11.5%',
        'purity': '98.0%',
        'foreignMatter': '0.8%',
        'assignedGrade': 'Grade A',
        'assessedRate': '₹ 4,750 / Qtl',
      },
    },
    {
      'name': 'Chana Dal',
      'quantity': '40 Qtl',
      'price': '₹ 5,800 / Qtl',
      'assessedPrice': '₹ 5,800 / Qtl',
      'totalValue': '₹ 2,32,000',
      'grade': 'Grade A',
      'location': 'Central Godown #2, Ujjain',
      'views': 31,
      'status': 'Sold to Warehouse',
      'warehouseName': 'Central Warehousing Corp (CWC) Sehore',
      'enwrId': 'e-NWR-2026-MP-491028',
      'thumbnail': CropThumbnailType.chanaDal,
      'inspectionReport': {
        'status': 'Verified',
        'inspector': 'Shri R. P. Mishra (APMC Inspector)',
        'lab': 'Ujjain Division Quality Center',
        'certNo': 'AGRI-QC-981120',
        'verifiedDate': '20 May 2026, 09:00 AM',
        'moisture': '10.8%',
        'purity': '99.2%',
        'foreignMatter': '0.4%',
        'assignedGrade': 'Grade A',
        'assessedRate': '₹ 5,800 / Qtl',
      },
    },
    {
      'name': 'Potatoes',
      'quantity': '80 Kg',
      'price': '₹ 15 / Kg',
      'assessedPrice': '₹ 15 / Kg',
      'totalValue': '₹ 1,200',
      'grade': 'Standard',
      'location': 'Sehore Farm, MP',
      'views': 18,
      'status': 'Quality Verified',
      'thumbnail': CropThumbnailType.potatoes,
      'inspectionReport': {
        'status': 'Verified',
        'inspector': 'Dr. S. K. Verma (Horticulture QC)',
        'lab': 'Bhopal Central Agro Testing Hub',
        'certNo': 'AGRI-QC-982245',
        'verifiedDate': '22 May 2026, 02:00 PM',
        'moisture': '13.5%',
        'purity': '98.2%',
        'foreignMatter': '0.6%',
        'assignedGrade': 'Standard',
        'assessedRate': '₹ 15 / Kg',
      },
    },
  ];

  void _addNewProduct() async {
    final newProd = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewProductScreen(
          onProductAdded: (prod) {
            CropThumbnailType thumb = CropThumbnailType.wheat;
            final cat = (prod['category'] as String?)?.toLowerCase() ?? '';
            final name = (prod['name'] as String?)?.toLowerCase() ?? '';

            if (cat.contains('veg') || name.contains('tomato')) {
              thumb = CropThumbnailType.tomatoes;
            } else if (name.contains('potato') || name.contains('aloo')) {
              thumb = CropThumbnailType.potatoes;
            } else if (cat.contains('pulse') || name.contains('dal') || name.contains('chana')) {
              thumb = CropThumbnailType.chanaDal;
            }

            final fullProduct = Map<String, dynamic>.from(prod);
            fullProduct['thumbnail'] = thumb;
            fullProduct['views'] = 1;

            setState(() {
              _products.insert(0, fullProduct);
            });
          },
        ),
      ),
    );

    if (newProd != null && mounted) {
      // Handled in callback
    }
  }

  void _openInspectionReport(Map<String, dynamic> item, int index) async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => InspectionReportScreen(
          product: item,
          onProductUpdated: (prod) {
            setState(() {
              _products[index] = prod;
            });
          },
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _products[index] = updated;
      });
    }
  }

  void _sellToWarehouseDirectly(Map<String, dynamic> item, int index) async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => WarehouseSaleScreen(product: item),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _products[index] = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final filteredList = _selectedFilter == 'All'
        ? _products
        : _products.where((p) => p['status'] == _selectedFilter).toList();

    final verifiedCount = _products.where((p) => p['status'] == 'Quality Verified').length;
    final underInspectionCount = _products.where((p) => p['status'] == 'Under Inspection').length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F2),
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
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(color: const Color(0xFFD4EBD8), width: 1.2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF136A36),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        langProvider.translate('my_products_title'),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF142C1E),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= INVENTORY SUMMARY CARD =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEAF5EB), Color(0xFFF6FAF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD6EADA), width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryStat(
                          langProvider.translate('listed_produce'),
                          '${_products.length} ${langProvider.translate('items_count')}',
                        ),
                        Container(width: 1, height: 26, color: const Color(0xFFD0E5D4)),
                        _buildSummaryStat(
                          langProvider.translate('status_quality_verified'),
                          '$verifiedCount ${langProvider.translate('crops_count')}',
                        ),
                        Container(width: 1, height: 26, color: const Color(0xFFD0E5D4)),
                        _buildSummaryStat(
                          langProvider.translate('status_under_inspection'),
                          '$underInspectionCount ${langProvider.translate('items_count')}',
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ================= FILTER SEGMENTED SCROLLABLE ROW =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterPill('All', langProvider.translate('all_filter')),
                        const SizedBox(width: 10),
                        _buildFilterPill('Quality Verified', langProvider.translate('filter_verified')),
                        const SizedBox(width: 10),
                        _buildFilterPill('Under Inspection', langProvider.translate('filter_inspection')),
                        const SizedBox(width: 10),
                        _buildFilterPill('Sold to Warehouse', langProvider.translate('filter_sold')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ================= PRODUCT LIST =================
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Text(
                            'No items found in this section.',
                            style: GoogleFonts.poppins(color: const Color(0xFF758D7E)),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 160),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final status = item['status'] as String? ?? 'Under Inspection';
                            final isVerified = status == 'Quality Verified';
                            final isUnderInspection = status == 'Under Inspection';
                            final isSold = status == 'Sold to Warehouse';

                            final rawName = item['name'] as String;
                            final localizedName = langProvider.translateProduce(rawName);

                            return ScrollRevealItem(
                              delay: Duration(milliseconds: index < 6 ? index * 55 : 0),
                              child: ScaleBounceOnTap(
                                child: InkWell(
                                  onTap: () => _openInspectionReport(item, _products.indexOf(item)),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
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
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Left Real Crop Thumbnail
                                            CropThumbnailArt(
                                              type: item['thumbnail'] is CropThumbnailType
                                                  ? item['thumbnail'] as CropThumbnailType
                                                  : CropThumbnailType.wheat,
                                              size: 80,
                                            ),
                                            const SizedBox(width: 14),

                                            // Details
                                            Expanded(
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
                                                            fontSize: 15.5,
                                                            fontWeight: FontWeight.w700,
                                                            color: const Color(0xFF182D20),
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      _buildStatusBadge(status, langProvider),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),

                                                  Row(
                                                    children: [
                                                      Text(
                                                        item['quantity'] as String,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color(0xFF556F5E),
                                                        ),
                                                      ),
                                                      if (item['grade'] != null && isVerified) ...[
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '• ${langProvider.translateProduce(item['grade'] as String)}',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                            color: const Color(0xFF136A36),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),

                                                  // Price or Inspection State
                                                  if (isUnderInspection)
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.access_time_filled_rounded, size: 14, color: Color(0xFFE65100)),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            langProvider.translate('price_pending_inspection'),
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w700,
                                                              color: const Color(0xFFE65100),
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    Text(
                                                      item['price'] as String,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 15.5,
                                                        fontWeight: FontWeight.w800,
                                                        color: const Color(0xFF142B1E),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),
                                        const Divider(height: 1, color: Color(0xFFEFF4F0)),
                                        const SizedBox(height: 8),

                                        // Bottom Action Row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                langProvider.translate('view_inspection_report'),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF436B51),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (isVerified)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F5E9),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFC6E7CD)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.receipt_long_rounded, size: 13, color: Color(0xFF136A36)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '3 ${langProvider.translate('orders_available')}',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color: const Color(0xFF136A36),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else if (isSold)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F1FC),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  item['enwrId'] ?? 'e-NWR Issued',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF1976D2),
                                                  ),
                                                ),
                                              )
                                            else
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'QC Visit Tomorrow',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xFFE65100),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFE65100)),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
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

      // ================= BOTTOM FIXED ACTION BUTTON =================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 85),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _addNewProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136A36),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: const Color(0xFF136A36).withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, size: 22, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      langProvider.translate('add_new_product'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, LanguageProvider langProvider) {
    Color bg;
    Color color;
    String label;

    if (status == 'Quality Verified') {
      bg = const Color(0xFFE8F5E9);
      color = const Color(0xFF136A36);
      label = langProvider.translate('status_quality_verified');
    } else if (status == 'Sold to Warehouse') {
      bg = const Color(0xFFE8F1FC);
      color = const Color(0xFF1976D2);
      label = langProvider.translate('status_sold_warehouse');
    } else {
      bg = const Color(0xFFFFF3E0);
      color = const Color(0xFFE65100);
      label = langProvider.translate('status_under_inspection');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, {bool isHighlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B8374),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isHighlight ? const Color(0xFFE65100) : const Color(0xFF1A2F22),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill(String filterKey, String displayLabel) {
    final isSelected = _selectedFilter == filterKey;

    return GestureDetector(
      key: ValueKey('filter_pill_$filterKey'),
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          textAlign: TextAlign.center,
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
