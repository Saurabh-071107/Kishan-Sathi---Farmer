import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'category_icon_art.dart';

class AddProductSheet extends StatefulWidget {
  final Function(Map<String, dynamic>)? onProductAdded;

  const AddProductSheet({super.key, this.onProductAdded});

  static Future<void> show(BuildContext context, {Function(Map<String, dynamic>)? onProductAdded}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddProductSheet(onProductAdded: onProductAdded),
    );
  }

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController(text: 'Sehore APMC Mandi, MP');

  CategoryType _selectedCategory = CategoryType.grains;
  String _unit = 'Quintal';
  String _qualityGrade = 'Grade A (Premium)';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cropNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final newProduct = {
      'name': _cropNameController.text.trim(),
      'category': _selectedCategory.name,
      'quantity': '${_quantityController.text.trim()} $_unit',
      'price': '₹ ${_priceController.text.trim()} / $_unit',
      'grade': _qualityGrade,
      'location': _locationController.text.trim(),
      'date': DateTime.now(),
    };

    if (mounted) {
      widget.onProductAdded?.call(newProduct);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_cropNameController.text.trim()} listed successfully for buyers!',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle pill
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sell Your Produce',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'List fresh crop stock directly to verified buyers & FPOs',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // Category Selector Chips
              Text(
                'Category',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildCategoryChip('Grains', CategoryType.grains),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Fruits', CategoryType.fruits),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Veggies', CategoryType.vegetables),
                  const SizedBox(width: 8),
                  _buildCategoryChip('Pulses', CategoryType.pulses),
                ],
              ),
              const SizedBox(height: 16),

              // Crop Name
              TextFormField(
                controller: _cropNameController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Crop / Product Name',
                  hintText: 'e.g. Sharbati Wheat, Fresh Tomatoes',
                  prefixIcon: const Icon(Icons.grass_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter crop name' : null,
              ),
              const SizedBox(height: 14),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Available Stock',
                        hintText: 'e.g. 50',
                        prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter quantity' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      items: const [
                        DropdownMenuItem(value: 'Quintal', child: Text('Quintal')),
                        DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                        DropdownMenuItem(value: 'Ton', child: Text('Ton')),
                        DropdownMenuItem(value: 'Crates', child: Text('Crates')),
                      ],
                      onChanged: (val) => setState(() => _unit = val ?? 'Quintal'),
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Expected Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Expected Price (₹)',
                  hintText: 'e.g. 2450',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primary),
                  suffixText: '/ $_unit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter price per unit' : null,
              ),
              const SizedBox(height: 14),

              // Quality Grade
              DropdownButtonFormField<String>(
                initialValue: _qualityGrade,
                items: const [
                  DropdownMenuItem(value: 'Grade A (Premium)', child: Text('Grade A (Premium)')),
                  DropdownMenuItem(value: 'Grade B (Standard)', child: Text('Grade B (Standard)')),
                  DropdownMenuItem(value: 'Organic Certified', child: Text('Organic Certified')),
                ],
                onChanged: (val) => setState(() => _qualityGrade = val ?? 'Grade A (Premium)'),
                decoration: InputDecoration(
                  labelText: 'Quality Grade',
                  prefixIcon: const Icon(Icons.verified_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 22),

              // Submit Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                            const Icon(Icons.add_circle_outline_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Publish Crop Listing',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, CategoryType type) {
    final isSelected = _selectedCategory == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFDEE6E0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
