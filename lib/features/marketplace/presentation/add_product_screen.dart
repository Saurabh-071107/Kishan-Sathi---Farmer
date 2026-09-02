import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/device_hardware_service.dart';
import '../../../../core/services/api_service.dart';
import '../../navigation/widgets/floating_nav_bar.dart';

class AddNewProductScreen extends StatefulWidget {
  final bool showFloatingNav;
  final Function(Map<String, dynamic>)? onProductAdded;

  const AddNewProductScreen({
    super.key,
    this.showFloatingNav = false,
    this.onProductAdded,
  });

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(text: 'Jaipur, Rajasthan');
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory = 'Grains (अनाज)';
  String _selectedUnit = 'Quintal';
  String? _selectedPhotoAsset;
  XFile? _pickedImageFile;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Grains (अनाज)',
    'Fruits (फल)',
    'Vegetables (सब्जियाँ)',
    'Pulses & Lentils (दालें)',
    'Oilseeds (तिलहन)',
    'Spices (मसाले)',
    'Organic Produce (जैविक उत्पाद)',
  ];

  final List<String> _units = [
    'Quintal',
    'Kg',
    'Ton',
    'Crate',
    'Bag',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _choosePhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Harvest / Crop Sample Photo',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Take a clear picture of your harvest sample for quality inspectors',
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: Text('Take Camera Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('Capture sample directly using Camera', style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await DeviceHardwareService().captureFromCamera();
                if (file != null) {
                  setState(() {
                    _pickedImageFile = file;
                    _selectedPhotoAsset = null;
                  });
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.photo_library_rounded, color: AppColors.accentOrange),
              ),
              title: Text('Choose from Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('Upload saved crop pictures from Storage', style: GoogleFonts.poppins(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await DeviceHardwareService().pickFromGallery();
                if (file != null) {
                  setState(() {
                    _pickedImageFile = file;
                    _selectedPhotoAsset = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a product category', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      double quantityValue = double.tryParse(_quantityController.text.trim()) ?? 0;
      double quantityKg = quantityValue;
      if (_selectedUnit == 'Quintal') {
        quantityKg *= 100;
      } else if (_selectedUnit == 'Ton') {
        quantityKg *= 1000;
      } else if (_selectedUnit == 'Bag') {
        quantityKg *= 50;
      }

      String locationStr = _locationController.text.trim();
      String district = locationStr;
      if (locationStr.contains(',')) {
        district = locationStr.split(',')[0].trim();
      }

      final payload = {
        'category': _selectedCategory!.split(' (')[0],
        'product_name': _nameController.text.trim(),
        'quantity_kg': quantityKg,
        'price_per_kg': 0,
        'district': district,
        'description': _descriptionController.text.trim(),
      };

      await ApiService().addProduce(payload);

      if (mounted) {
        widget.onProductAdded?.call(payload);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_nameController.text.trim()} submitted! Field inspection scheduled.',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.pop(context, payload);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

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
          langProvider.translate('add_new_product'),
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
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    18,
                    8,
                    18,
                    widget.showFloatingNav ? 110 : 30,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ================= 1. QUALITY VALUATION NOTICE BANNER =================
                        _buildQualityInspectionNotice(langProvider),
                        const SizedBox(height: 14),

                        // ================= 2. TOP PHOTO UPLOAD CARD =================
                        _buildPhotoUploadCard(),
                        const SizedBox(height: 14),

                        // ================= 3. CROP DETAILS CARD =================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(langProvider.translate('product_name')),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                style: GoogleFonts.poppins(fontSize: 14.5, color: const Color(0xFF1A2F22)),
                                decoration: _inputDecoration(hintText: 'e.g. Sharbati Wheat'),
                                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter product name' : null,
                              ),
                              const SizedBox(height: 14),

                              _buildSectionLabel(langProvider.translate('category')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                hint: Text(
                                  'Select Category',
                                  style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF8B9E92)),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5A7264)),
                                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A2F22)),
                                decoration: _inputDecoration(),
                                items: _categories.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat,
                                    child: Text(cat, style: GoogleFonts.poppins(fontSize: 13.5)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedCategory = val),
                                validator: (val) => val == null ? 'Please select a category' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ================= 4. QUANTITY & LOCATION CARD =================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(langProvider.translate('quantity_to_sell')),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: TextFormField(
                                      controller: _quantityController,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.poppins(fontSize: 14.5, color: const Color(0xFF1A2F22)),
                                      decoration: _inputDecoration(hintText: 'Enter quantity (e.g. 50)'),
                                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter quantity' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 5,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedUnit,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5A7264)),
                                      style: GoogleFonts.poppins(fontSize: 14.5, color: const Color(0xFF1A2F22)),
                                      decoration: _inputDecoration(),
                                      items: _units.map((unit) {
                                        return DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(unit),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedUnit = val ?? 'Quintal'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              _buildSectionLabel(langProvider.translate('farm_pickup_location')),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _locationController,
                                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A2F22)),
                                decoration: _inputDecoration(
                                  hintText: 'Farm location for inspector visit',
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter farm location' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ================= 5. DESCRIPTION (OPTIONAL) =================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(langProvider.translate('description_optional')),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 2,
                                style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF1A2F22)),
                                decoration: _inputDecoration(
                                  hintText: 'Add crop variety, harvest date, or special features...',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ================= 6. SUBMIT BUTTON =================
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF136A36),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: const Color(0xFF136A36).withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.verified_outlined, size: 20, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        langProvider.translate('submit_for_inspection'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
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

            if (widget.showFloatingNav)
              FloatingNavBar(
                currentIndex: 1,
                onTap: (index) {
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityInspectionNotice(LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC7E5CE), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF136A36).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.balance_rounded,
                  color: Color(0xFF136A36),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APMC Quality Standard Price Slot',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF114725),
                      ),
                    ),
                    Text(
                      'Strict Govt/APMC Benchmark Protection',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF336345)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD3E7D8)),
            ),
            child: Column(
              children: [
                _buildPriceSlotMiniRow('Grade A+ (Premium Export)', 'Moisture < 10%', '₹ 2,850 - 3,100 / Qtl'),
                const Divider(height: 10, color: Color(0xFFE8F2EA)),
                _buildPriceSlotMiniRow('Grade A (Standard Mandi)', 'Moisture 10-12%', '₹ 2,650 - 2,800 / Qtl'),
                const Divider(height: 10, color: Color(0xFFE8F2EA)),
                _buildPriceSlotMiniRow('Grade B (FAQ Quality)', 'Moisture 12-14%', '₹ 2,400 - 2,600 / Qtl'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The warehouse inspector certifies the grade during on-site sampling. Both farmer payout and warehouse procurement are locked to this slot.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF336345),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSlotMiniRow(String title, String param, String rate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF193824))),
            Text(param, style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFF5A7A66))),
          ],
        ),
        Text(rate, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF136A36))),
      ],
    );
  }

  Widget _buildPhotoUploadCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _choosePhoto,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF1E3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF5DECA), width: 1.2),
          ),
          child: Row(
            children: [
              if (_pickedImageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: kIsWeb
                      ? Image.network(
                          _pickedImageFile!.path,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_pickedImageFile!.path),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                )
              else if (_selectedPhotoAsset != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    _selectedPhotoAsset!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFE8F5E9),
                      child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 28),
                    ),
                  ),
                )
              else
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7E6D3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF6D5239), size: 28),
                ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF136A36), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Add Photo',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4C3623),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Take a clear photo to make your produce look attractive',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8C715A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to change photo',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B2F22),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13.5,
        color: const Color(0xFF8B9E92),
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: const Color(0xFFFCFDFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4EDE7), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF136A36), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
      ),
    );
  }
}
