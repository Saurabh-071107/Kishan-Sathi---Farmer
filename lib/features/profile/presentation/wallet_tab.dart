import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/animated_count_text.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';
import '../../reports/presentation/sales_report_screen.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  double _balance = 25680.00;
  int _selectedBankIndex = 0;

  final List<Map<String, dynamic>> _bankAccounts = [
    {
      'bankName': 'State Bank of India',
      'accountNo': '•••• •••• 8941',
      'fullAccountNo': '38491028941',
      'ifsc': 'SBIN0001234',
      'branch': 'Sehore Main Branch',
      'accountType': 'Savings Account',
      'isPrimary': true,
      'isDbtVerified': true,
    },
  ];

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Order #ORD12345',
      'date': '20 May 2026',
      'amount': '+ ₹ 560',
      'isCredit': true,
      'iconBg': Color(0xFFFFF3E0),
      'iconColor': Color(0xFF136A36),
    },
    {
      'title': 'Order #ORD12344',
      'date': '19 May 2026',
      'amount': '+ ₹ 600',
      'isCredit': true,
      'iconBg': Color(0xFFFFF3E0),
      'iconColor': Color(0xFFE67E22),
    },
    {
      'title': 'Order #ORD12343',
      'date': '18 May 2026',
      'amount': '+ ₹ 750',
      'isCredit': true,
      'iconBg': Color(0xFFE8F5E9),
      'iconColor': Color(0xFF136A36),
    },
    {
      'title': 'Withdrawal',
      'date': '17 May 2026',
      'amount': '- ₹ 2,000',
      'isCredit': false,
      'iconBg': Color(0xFFFEEFE6),
      'iconColor': Color(0xFFD84315),
    },
  ];

  void _openAddBankAccountSheet(LanguageProvider langProvider) {
    final nameController = TextEditingController(text: 'Rameshwar Singh');
    final accNoController = TextEditingController();
    final confirmAccNoController = TextEditingController();
    final ifscController = TextEditingController();
    String selectedBank = 'State Bank of India';
    String selectedAccountType = 'Savings Account';
    bool setAsPrimary = true;

    final bankList = [
      'State Bank of India',
      'Bank of Baroda',
      'Punjab National Bank',
      'HDFC Bank',
      'ICICI Bank',
      'Union Bank of India',
      'Canara Bank',
      'Bank of India',
      'Central Bank of India',
    ];

    final accountTypes = ['Savings Account', 'Current Account', 'Kisan Credit Card (KCC)'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.account_balance_rounded, color: Color(0xFF136A36), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            langProvider.translate('add_bank_account'),
                            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF162D1F)),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF6B8374)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Account Holder Name
                  Text(
                    langProvider.translate('account_holder_name'),
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4C6354)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF162D1F)),
                    decoration: _inputDecoration('e.g. Rameshwar Singh', Icons.person_outline_rounded),
                  ),
                  const SizedBox(height: 12),

                  // Select Bank
                  Text(
                    langProvider.translate('select_bank'),
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4C6354)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFCFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE4EDE7), width: 1.2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBank,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF136A36)),
                        items: bankList.map((b) => DropdownMenuItem(value: b, child: Text(b, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedBank = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Account Number
                  Text(
                    langProvider.translate('account_number'),
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4C6354)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: accNoController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF162D1F)),
                    decoration: _inputDecoration('e.g. 109283746501', Icons.credit_card_rounded),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Account Number
                  Text(
                    langProvider.translate('confirm_account_number'),
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4C6354)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: confirmAccNoController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF162D1F)),
                    decoration: _inputDecoration('Re-enter account number', Icons.check_circle_outline_rounded),
                  ),
                  const SizedBox(height: 12),

                  // IFSC Code
                  Text(
                    langProvider.translate('ifsc_code'),
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4C6354)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: ifscController,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF162D1F)),
                    decoration: _inputDecoration('e.g. SBIN0001234', Icons.pin_outlined),
                  ),
                  const SizedBox(height: 12),

                  // Account Type
                  Text(
                    langProvider.translate('account_type'),
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4C6354)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFCFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE4EDE7), width: 1.2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedAccountType,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF136A36)),
                        items: accountTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedAccountType = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Primary DBT Checkbox
                  InkWell(
                    onTap: () => setModalState(() => setAsPrimary = !setAsPrimary),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Checkbox(
                            value: setAsPrimary,
                            activeColor: const Color(0xFF136A36),
                            onChanged: (val) => setModalState(() => setAsPrimary = val ?? true),
                          ),
                          Expanded(
                            child: Text(
                              'Set as Primary Direct Benefit Transfer (DBT) Payout Account',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF334A3C)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final accNo = accNoController.text.trim();
                        final confirmAccNo = confirmAccNoController.text.trim();
                        final ifsc = ifscController.text.trim().toUpperCase();

                        if (accNo.isEmpty || accNo.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid bank account number.')),
                          );
                          return;
                        }

                        if (accNo != confirmAccNo) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account numbers do not match.')),
                          );
                          return;
                        }

                        if (ifsc.isEmpty || ifsc.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid IFSC code.')),
                          );
                          return;
                        }

                        final masked = '•••• •••• ${accNo.substring(accNo.length - 4)}';

                        setState(() {
                          if (setAsPrimary) {
                            for (var b in _bankAccounts) {
                              b['isPrimary'] = false;
                            }
                          }

                          _bankAccounts.add({
                            'bankName': selectedBank,
                            'accountNo': masked,
                            'fullAccountNo': accNo,
                            'ifsc': ifsc,
                            'branch': 'Branch Verified',
                            'accountType': selectedAccountType,
                            'isPrimary': setAsPrimary,
                            'isDbtVerified': true,
                          });

                          if (setAsPrimary) {
                            _selectedBankIndex = _bankAccounts.length - 1;
                          }
                        });

                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '$selectedBank account added & verified with DBT!',
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF136A36),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        langProvider.translate('verify_and_link'),
                        style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF136A36), size: 20),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFFAFCFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE4EDE7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE4EDE7), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF136A36), width: 1.6),
      ),
    );
  }

  void _openWithdrawalSheet(LanguageProvider langProvider) {
    final amountController = TextEditingController();
    final primaryAccount = _bankAccounts.isNotEmpty
        ? _bankAccounts[_selectedBankIndex.clamp(0, _bankAccounts.length - 1)]
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
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
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  langProvider.translate('withdraw_btn'),
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 20),

            // Linked Bank Summary
            if (primaryAccount != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F8F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD6EADA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_rounded, color: Color(0xFF136A36), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            primaryAccount['bankName'] as String,
                            style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF162E1F)),
                          ),
                          Text(
                            'A/c: ${primaryAccount['accountNo']} • IFSC: ${primaryAccount['ifsc']}',
                            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF758C7E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'Enter Amount to Withdraw',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4C6354)),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF162E1F)),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                hintText: 'Available: ₹${_balance.toStringAsFixed(0)}',
                hintStyle: GoogleFonts.poppins(fontSize: 13.5, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: const Color(0xFFFAFCFA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE4EDE7)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Preset Buttons
            Row(
              children: [
                _buildPresetButton(ctx, amountController, '₹ 5,000', 5000),
                const SizedBox(width: 8),
                _buildPresetButton(ctx, amountController, '₹ 10,000', 10000),
                const SizedBox(width: 8),
                _buildPresetButton(ctx, amountController, 'All (₹ ${_balance.toStringAsFixed(0)})', _balance.toInt()),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text.trim()) ?? _balance;
                  if (amount > 0 && amount <= _balance) {
                    setState(() {
                      _balance -= amount;
                      _transactions.insert(0, {
                        'title': 'Withdrawal',
                        'date': 'Today',
                        'amount': '- ₹ ${amount.toStringAsFixed(0)}',
                        'isCredit': false,
                        'iconBg': const Color(0xFFFEEFE6),
                        'iconColor': const Color(0xFFD84315),
                      });
                    });
                    Navigator.pop(ctx);
                    final bankName = primaryAccount?['bankName'] ?? 'Bank Account';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Instant withdrawal of ₹${amount.toStringAsFixed(0)} transferred to $bankName!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Confirm Instant Withdrawal', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(BuildContext ctx, TextEditingController ctrl, String label, int value) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          ctrl.text = value.toString();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: const BorderSide(color: Color(0xFFD4E7DA)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F2),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= TOP HEADER =================
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
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
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFF136A36),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          langProvider.translate('my_wallet'),
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

                  // ================= HERO BALANCE CARD =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 60),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F5A2C), Color(0xFF136A36), Color(0xFF197A40)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF136A36).withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: Balance Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                langProvider.translate('total_balance'),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedCountText(
                                targetValue: _balance,
                                prefix: '₹ ',
                                formatCurrency: true,
                                duration: const Duration(milliseconds: 850),
                                curve: Curves.easeOutCubic,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),

                          // Right: Withdraw Pill Button
                          ScaleBounceOnTap(
                            child: ElevatedButton(
                              onPressed: () => _openWithdrawalSheet(langProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF136A36),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                langProvider.translate('withdraw_btn'),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= MONTHLY STATS STRIP =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 120),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat(langProvider.translate('earned_this_month'), '₹ 28,500', isHighlight: true),
                          Container(width: 1, height: 26, color: const Color(0xFFE8E5DA)),
                          _buildSummaryStat(langProvider.translate('withdrawn'), '₹ 2,820'),
                          Container(width: 1, height: 26, color: const Color(0xFFE8E5DA)),
                          _buildSummaryStat('IMPS Fee', '₹ 0.00'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ================= LINKED BANK ACCOUNTS SECTION =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                langProvider.translate('linked_bank_accounts'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF162D1E),
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ScaleBounceOnTap(
                              child: TextButton.icon(
                                onPressed: () => _openAddBankAccountSheet(langProvider),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 17, color: Color(0xFF136A36)),
                                label: Text(
                                  langProvider.translate('add_bank_account'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF136A36),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ..._bankAccounts.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final acc = entry.value;
                          final isSelected = _selectedBankIndex == idx;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF136A36) : const Color(0xFFE8E5DA),
                                width: isSelected ? 1.6 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.025),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.account_balance_rounded, color: Color(0xFF136A36), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              acc['bankName'] as String,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF162D1F),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (acc['isPrimary'] == true) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Primary',
                                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF136A36)),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'A/c ${acc['accountNo']} • IFSC ${acc['ifsc']}',
                                        style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF758A7E)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'DBT Verified',
                                    style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF136A36)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= TRANSACTIONS LIST =================
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.translate('recent_transactions'),
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF162D1E),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _transactions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            final isCredit = tx['isCredit'] as bool;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE8E5DA)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: tx['iconBg'] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                      color: tx['iconColor'] as Color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          langProvider.translateProduce(tx['title'] as String),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF162D1F),
                                          ),
                                        ),
                                        Text(
                                          tx['date'] as String,
                                          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF758C7E)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    tx['amount'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isCredit ? const Color(0xFF136A36) : const Color(0xFFD84315),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // View Detailed Sales Report Button
                  AppFadeSlideAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                          );
                        },
                        icon: const Icon(Icons.insights_rounded, color: Color(0xFF136A36), size: 20),
                        label: Text(
                          'View Detailed Sales Report',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF136A36),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF136A36), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
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

  Widget _buildSummaryStat(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF758C7E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: isHighlight ? const Color(0xFF136A36) : const Color(0xFF162D1F),
          ),
        ),
      ],
    );
  }
}
