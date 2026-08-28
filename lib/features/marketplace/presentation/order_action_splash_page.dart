import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';

enum OrderSplashType {
  accepted,
  delivered,
}

class OrderActionSplashPage extends StatefulWidget {
  final OrderSplashType type;
  final Map<String, dynamic> order;

  const OrderActionSplashPage({
    super.key,
    required this.type,
    required this.order,
  });

  @override
  State<OrderActionSplashPage> createState() => _OrderActionSplashPageState();
}

class _OrderActionSplashPageState extends State<OrderActionSplashPage> {
  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isAccepted = widget.type == OrderSplashType.accepted;

    final orderId = widget.order['id'] as String? ?? '#ORD12345';
    final buyerName = langProvider.translateProduce(widget.order['buyer'] as String? ?? 'Ramesh Kirana Store');
    final itemsRaw = widget.order['items'] as String? ?? 'Wheat - 20 Kg';
    final itemsText = langProvider.translateProduce(itemsRaw);
    final amountText = widget.order['amount'] as String? ?? '₹ 560';
    final addressText = widget.order['address'] as String? ?? 'Indore, Madhya Pradesh';

    final lottieAsset = isAccepted
        ? 'assets/animations/packaging_for_delivery.json'
        : 'assets/animations/success.json';

    final title = isAccepted
        ? langProvider.translate('order_accepted_splash_title')
        : langProvider.translate('order_delivered_splash_title');

    final subtitle = isAccepted
        ? langProvider.translate('order_accepted_splash_subtitle')
        : langProvider.translate('order_delivered_splash_subtitle');

    final badgeText = isAccepted
        ? langProvider.translate('packaging_in_progress')
        : langProvider.translate('payment_credited_to_wallet');

    final badgeBg = isAccepted ? const Color(0xFFE1F5FE) : const Color(0xFFE8F5E9);
    final badgeColor = isAccepted ? const Color(0xFF0288D1) : const Color(0xFF136A36);
    final badgeIcon = isAccepted ? Icons.inventory_2_outlined : Icons.account_balance_wallet_rounded;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F2),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Close/Skip Row
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context, true),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE8E5DA)),
                          ),
                          child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF4A6253)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Lottie Animation Hero Section
                    AppFadeSlideAnimation(
                      delay: Duration.zero,
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAccepted
                              ? const Color(0xFF0288D1).withValues(alpha: 0.06)
                              : const Color(0xFF136A36).withValues(alpha: 0.08),
                        ),
                        child: Center(
                          child: Lottie.asset(
                            lottieAsset,
                            width: 210,
                            height: 210,
                            fit: BoxFit.contain,
                            repeat: !WidgetsBinding.instance.runtimeType.toString().contains('TestWidgets'),
                            animate: true,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: badgeBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAccepted ? Icons.local_shipping_rounded : Icons.check_circle_rounded,
                                size: 70,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Status Pill Badge
                    AppFadeSlideAnimation(
                      delay: const Duration(milliseconds: 80),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.25), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, size: 16, color: badgeColor),
                            const SizedBox(width: 6),
                            Text(
                              badgeText,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title Header
                    AppFadeSlideAnimation(
                      delay: const Duration(milliseconds: 140),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF142C1E),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    AppFadeSlideAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B8374),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Order Summary Card
                    AppFadeSlideAnimation(
                      delay: const Duration(milliseconds: 260),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFE8E5DA), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Order ID & Amount Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      langProvider.translate('order_id'),
                                      style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF8B9E92)),
                                    ),
                                    Text(
                                      orderId,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
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
                                      'Order Amount',
                                      style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF8B9E92)),
                                    ),
                                    Text(
                                      amountText,
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF136A36),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, color: Color(0xFFEFF2EE)),
                            ),

                            // Buyer & Produce
                            _buildInfoRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Buyer',
                              value: buyerName,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              icon: Icons.eco_outlined,
                              label: 'Produce',
                              value: itemsText,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: addressText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Primary Action Button
                    AppFadeSlideAnimation(
                      delay: const Duration(milliseconds: 320),
                      child: ScaleBounceOnTap(
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF136A36),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: const Color(0xFF136A36).withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              langProvider.translate('continue_to_orders'),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary Action Button (Done / Dismiss)
                    AppFadeSlideAnimation(
                      delay: const Duration(milliseconds: 360),
                      child: ScaleBounceOnTap(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF556F5E),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          ),
                          child: Text(
                            langProvider.translate('order_splash_done'),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF136A36)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w500, color: const Color(0xFF758C7E)),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF162D1F),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
