import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/animated_count_text.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';
import '../../reports/presentation/sales_report_screen.dart';
import '../../../../core/services/api_service.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  double _balance = 0.00;
  double _earnedThisMonth = 0.00;
  double _withdrawn = 0.00;
  bool _hideBalance = false;
  bool _isLoading = true;
  bool _isActionLoading = false;
  String _selectedTxnFilter = 'All';
  int _selectedBankIndex = 0;

  final List<Map<String, dynamic>> _bankAccounts = [
    {
      'bankName': 'State Bank of India',
      'accountNo': '•••• •••• 8941',
      'fullAccountNo': '38491028941',
      'ifsc': 'SBIN0001234',
      'branch': 'Jaipur Mandi Branch',
      'accountType': 'Savings Account (DBT Primary)',
      'isPrimary': true,
      'isDbtVerified': true,
    },
  ];

  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getWalletData();
      final Map<String, dynamic> data = (res is Map<String, dynamic> && res['data'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(res['data'])
          : (res is Map<String, dynamic> ? Map<String, dynamic>.from(res) : {});

      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      final earned = (data['earned_this_month'] as num?)?.toDouble() ?? 0.0;
      final withdrawn = (data['withdrawn'] as num?)?.toDouble() ?? 0.0;
      final txns = (data['transactions'] as List?) ?? [];

      final parsedTxns = List<Map<String, dynamic>>.from(txns.map((t) {
        final isCredit = t['type'] == 'Credit';
        final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
        final refId = t['id']?.toString() ?? 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        return {
          'id': refId,
          'title': t['description'] ?? (isCredit ? 'DBT Direct Settlement' : 'Bank Account Withdrawal'),
          'date': t['date'] != null
              ? DateTime.tryParse(t['date'].toString())?.toLocal().toString().split(' ')[0] ?? 'Today'
              : 'Today',
          'amount': '${isCredit ? '+ ' : '- '}₹ ${amt.toStringAsFixed(0)}',
          'rawAmount': amt,
          'isCredit': isCredit,
          'status': t['status'] ?? 'Completed',
          'enwrId': t['reference_id'] ?? 'e-NWR-Verified',
        };
      }));

      final user = ApiService().currentUser;
      final bankName = user?['bank_name']?.toString() ?? 'State Bank of India';
      final accountNo = user?['account_no']?.toString() ?? '38491028941';
      final maskedAccountNo = accountNo.length >= 4 
          ? '•••• •••• ${accountNo.substring(accountNo.length - 4)}'
          : '•••• •••• 8941';
      final district = user?['district']?.toString() ?? 'Jaipur';

      if (mounted) {
        setState(() {
          _bankAccounts[0] = {
            'bankName': bankName,
            'accountNo': maskedAccountNo,
            'fullAccountNo': accountNo,
            'ifsc': user?['ifsc']?.toString() ?? 'SBIN0001234',
            'branch': '$district Mandi Branch',
            'accountType': 'Savings Account (DBT Primary)',
            'isPrimary': true,
            'isDbtVerified': true,
          };
          _balance = balance;
          _earnedThisMonth = earned > 0 ? earned : balance;
          _withdrawn = withdrawn;
          _transactions = parsedTxns;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showWithdrawModal() {
    final TextEditingController amountController = TextEditingController();
    double quickAmount = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(22, 18, 22, MediaQuery.of(context).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Color(0xFF136A36), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instant Bank Transfer',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F2617)),
                        ),
                        Text(
                          'Available to withdraw: ₹ ${_balance.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF5A7263), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FBF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4EBD9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_outlined, color: Color(0xFF136A36), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'State Bank of India (Primary)',
                            style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF122C1A)),
                          ),
                          Text(
                            'A/c •••• •••• 8941 • IFSC SBIN0001234',
                            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF678270)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF136A36),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DBT Linked',
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Enter Withdrawal Amount',
                style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF1A3824)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF136A36)),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF136A36)),
                  hintText: '0',
                  hintStyle: GoogleFonts.poppins(fontSize: 22, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF9FDF9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFCFE8D5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF136A36), width: 1.8),
                  ),
                ),
                onChanged: (val) {
                  setModalState(() {
                    quickAmount = double.tryParse(val) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildQuickPill('₹ 500', 500, amountController, setModalState),
                  const SizedBox(width: 8),
                  _buildQuickPill('₹ 1,000', 1000, amountController, setModalState),
                  const SizedBox(width: 8),
                  _buildQuickPill('₹ 5,000', 5000, amountController, setModalState),
                  const SizedBox(width: 8),
                  _buildQuickPill('Full ₹ ${_balance.toInt()}', _balance, amountController, setModalState),
                ],
              ),
              const SizedBox(height: 22),

              ElevatedButton(
                onPressed: (_isActionLoading || _balance <= 0)
                    ? null
                    : () async {
                        final amt = double.tryParse(amountController.text.trim()) ?? quickAmount;
                        if (amt <= 0) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount to withdraw')),
                          );
                          return;
                        }
                        if (amt > _balance) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Withdrawal amount exceeds your wallet balance')),
                          );
                          return;
                        }

                        Navigator.pop(ctx);
                        setState(() => _isActionLoading = true);

                        try {
                          await ApiService().withdrawFunds(amount: amt);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '₹ ${amt.toStringAsFixed(0)} transferred to SBI (•••• 8941)!',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF136A36),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                          await _fetchWalletData();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Withdrawal note: $e'),
                                backgroundColor: Colors.red.shade700,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isActionLoading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136A36),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isActionLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Confirm Transfer to Bank',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
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

  Widget _buildQuickPill(String label, double val, TextEditingController controller, StateSetter setModalState) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setModalState(() {
            controller.text = val.toInt().toString();
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F7F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4E7D8)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF163E22)),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetailModal(Map<String, dynamic> txn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
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
                  'e-Payment Receipt',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF102819)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF136A36)),
                      const SizedBox(width: 4),
                      Text(
                        'NPCI Settled',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF136A36)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            Center(
              child: Column(
                children: [
                  Text(
                    txn['amount'] ?? '₹ 0',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: txn['isCredit'] == true ? const Color(0xFF136A36) : const Color(0xFFD84315),
                    ),
                  ),
                  Text(
                    txn['title'] ?? 'Direct DBT Settlement',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF4C6655)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6EFE8)),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Transaction Ref', txn['id'] ?? 'TXN-DBT-9821'),
                  _buildReceiptRow('Date & Time', txn['date'] ?? 'Today'),
                  _buildReceiptRow('Beneficiary Bank', 'State Bank of India (••8941)'),
                  _buildReceiptRow('e-NWR Lot ID', txn['enwrId'] ?? 'e-NWR-2026-RJ-Verified'),
                  _buildReceiptRow('Payment Mode', 'Government DBT Escrow Transfer'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF136A36),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text('Close Receipt', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B8273))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF162D1F)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final filteredList = _transactions.where((t) {
      if (_selectedTxnFilter == 'Credits') return t['isCredit'] == true;
      if (_selectedTxnFilter == 'Debits') return t['isCredit'] == false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F2),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: RefreshIndicator(
              onRefresh: _fetchWalletData,
              color: const Color(0xFF136A36),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ================= 1. COMPACT TOP HEADER =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCCE8D2)),
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF136A36), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  langProvider.translate('my_wallet'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF11291A),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'DBT Escrow Active (NPCI)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF166534),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        IconButton(
                          onPressed: _fetchWalletData,
                          icon: _isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF136A36)))
                              : const Icon(Icons.sync_rounded, color: Color(0xFF136A36), size: 22),
                          tooltip: 'Sync Wallet',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ================= 2. HERO LUXURY FINTECH CARD =================
                    AppFadeSlideAnimation(
                      delay: Duration.zero,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF072716),
                              Color(0xFF0F4E29),
                              Color(0xFF156534),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F4E29).withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      langProvider.translate('total_balance'),
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFD3EED8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => setState(() => _hideBalance = !_hideBalance),
                                      child: Icon(
                                        _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        size: 16,
                                        color: const Color(0xFFAEDBB6),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_user_rounded, color: Color(0xFFFFD54F), size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        '100% Escrow Protected',
                                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            _hideBalance
                                ? Text(
                                    '••••••••',
                                    style: GoogleFonts.poppins(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '₹ ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFFFD54F),
                                        ),
                                      ),
                                      AnimatedCountText(
                                        targetValue: _balance,
                                        style: GoogleFonts.poppins(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        formatCurrency: false,
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 18),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _showWithdrawModal,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFD54F),
                                      foregroundColor: const Color(0xFF0F381D),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                                    label: Text(
                                      langProvider.translate('withdraw'),
                                      style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.2),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    icon: const Icon(Icons.insert_drive_file_outlined, size: 16),
                                    label: Text(
                                      'Passbook',
                                      style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ================= 3. CASHFLOW METRICS STRIP =================
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xFF136A36),
                            bgColor: const Color(0xFFEBF7EE),
                            borderColor: const Color(0xFFCBEAD2),
                            label: langProvider.translate('earned_this_month'),
                            value: '₹ ${_earnedThisMonth.toStringAsFixed(0)}',
                            valueColor: const Color(0xFF136A36),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricTile(
                            icon: Icons.account_balance_outlined,
                            iconColor: const Color(0xFF0288D1),
                            bgColor: const Color(0xFFEEF7FC),
                            borderColor: const Color(0xFFCEE8F7),
                            label: langProvider.translate('withdrawn'),
                            value: '₹ ${_withdrawn.toStringAsFixed(0)}',
                            valueColor: const Color(0xFF0288D1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricTile(
                            icon: Icons.receipt_long_rounded,
                            iconColor: const Color(0xFFE65100),
                            bgColor: const Color(0xFFFFF3E0),
                            borderColor: const Color(0xFFFFE0B2),
                            label: 'DBT Payouts',
                            value: '${_transactions.where((t) => t['isCredit'] == true).length} Settled',
                            valueColor: const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ================= 4. LINKED BANK ACCOUNT CARD =================
                    Text(
                      langProvider.translate('linked_bank_accounts'),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF102819),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF136A36), width: 1.4),
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.account_balance_rounded, color: Color(0xFF136A36), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _bankAccounts[_selectedBankIndex]['bankName'],
                                        style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700, color: const Color(0xFF122C1A)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Primary',
                                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF136A36)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'A/c ${_bankAccounts[_selectedBankIndex]['accountNo']} • IFSC ${_bankAccounts[_selectedBankIndex]['ifsc']}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF627D6B), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'DBT Verified',
                              style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF136A36)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ================= 5. RECENT TRANSACTIONS / DBT PASSBOOK =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          langProvider.translate('recent_transactions'),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF102819),
                          ),
                        ),
                        Row(
                          children: [
                            _buildFilterChip('All', 'All'),
                            const SizedBox(width: 6),
                            _buildFilterChip('Credits', 'DBT (+)'),
                            const SizedBox(width: 6),
                            _buildFilterChip('Debits', 'Payouts (-)'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (filteredList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8E5DA)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_outlined, color: Color(0xFF136A36), size: 28),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Direct Benefit Transfer (DBT) Escrow Protected',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF102819)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'When the warehouse marks your produce as delivered/picked up, payment is credited instantly into this wallet and deposited to your bank account.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B8374), height: 1.4),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final txn = filteredList[index];
                          final isCredit = txn['isCredit'] == true;

                          return InkWell(
                            onTap: () => _showTransactionDetailModal(txn),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE8EFE9)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.015),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                      color: isCredit ? const Color(0xFF136A36) : const Color(0xFFE65100),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          txn['title'] ?? 'Transaction',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700, color: const Color(0xFF122C1A)),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              txn['date'] ?? 'Today',
                                              style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF7A9383)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text('•', style: GoogleFonts.poppins(color: Colors.grey.shade400)),
                                            const SizedBox(width: 6),
                                            Text(
                                              isCredit ? 'DBT Credited' : 'Bank Payout',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: isCredit ? const Color(0xFF136A36) : const Color(0xFFE65100),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        txn['amount'] ?? '₹ 0',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: isCredit ? const Color(0xFF136A36) : const Color(0xFFD84315),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Verified',
                                        style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF6B8374), fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 18),

                    // ================= 6. SALES REPORT ACTION BUTTON =================
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF136A36),
                        side: const BorderSide(color: Color(0xFF136A36), width: 1.4),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.analytics_outlined, size: 18),
                      label: Text(
                        'View Detailed Sales Report',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
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

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w500, color: const Color(0xFF506A58)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w800, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedTxnFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _selectedTxnFilter = filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF136A36) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF136A36) : const Color(0xFFDCE8DF)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF557060),
          ),
        ),
      ),
    );
  }
}
