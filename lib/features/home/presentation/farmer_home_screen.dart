import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/app_fade_slide_animation.dart';
import '../../../../core/services/api_service.dart';
import '../../marketplace/presentation/add_product_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import 'widgets/farmer_advisory_card.dart';
import 'widgets/harvest_crate_art.dart';
import 'widgets/live_mandi_rates_card.dart';
import 'widgets/metric_stat_card.dart';
import 'widgets/overview_stat_card.dart';

class FarmerHomeScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final Function(int tabIndex)? onNavigateToTab;
  final Function(String statusFilter)? onFilterOrders;

  const FarmerHomeScreen({
    super.key,
    this.userProfile,
    this.onNavigateToTab,
    this.onFilterOrders,
  });

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  bool _isLoading = true;

  int _totalProducts = 0;
  int _totalOrders = 0;
  String _totalSales = '₹ 0';

  int _newOrdersCount = 0;
  int _inProcessingCount = 0;
  int _completedOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final results = await Future.wait([
        ApiService().getFarmerDashboardStats(),
        ApiService().getMyProduce(),
        ApiService().getFarmerOrders(),
      ]);

      final stats = results[0] as Map<String, dynamic>;
      final produceList = results[1] as List<dynamic>;
      final ordersList = results[2] as List<dynamic>;

      final newOrders = ordersList.where((o) => ['pending', 'new'].contains((o['status'] ?? '').toString().toLowerCase())).length;
      final processingOrders = ordersList.where((o) => ['in_progress', 'processing', 'in process', 'in processing', 'accepted'].contains((o['status'] ?? '').toString().toLowerCase())).length;
      final completedOrders = ordersList.where((o) => ['completed', 'delivered'].contains((o['status'] ?? '').toString().toLowerCase())).length;

      final finalNew = newOrders > 0 ? newOrders : (stats['newOrders'] is int ? stats['newOrders'] as int : 0);
      final finalProcessing = processingOrders > 0 ? processingOrders : (stats['processingOrders'] is int ? stats['processingOrders'] as int : 0);
      final finalCompleted = completedOrders > 0 ? completedOrders : (stats['completedOrders'] is int ? stats['completedOrders'] as int : 0);

      double completedRevenue = 0.0;
      for (final o in ordersList) {
        final st = (o['status'] ?? '').toString().toLowerCase();
        if (['completed', 'delivered'].contains(st)) {
          final amt = (o['total_amount'] as num?)?.toDouble() ??
              (o['amount'] as num?)?.toDouble() ??
              0.0;
          completedRevenue += amt;
        }
      }

      String resolvedSales = stats['totalRevenue']?.toString() ?? '₹ 0';
      if ((resolvedSales == '₹ 0' || resolvedSales.isEmpty) && completedRevenue > 0) {
        resolvedSales = '₹ ${completedRevenue.toInt()}';
      }

      final int totalOrderCount = (finalNew + finalProcessing + finalCompleted) > 0
          ? (finalNew + finalProcessing + finalCompleted)
          : ordersList.length;

      if (mounted) {
        setState(() {
          _totalSales = resolvedSales;
          _totalProducts = produceList.length;
          _totalOrders = totalOrderCount;
          _newOrdersCount = finalNew;
          _inProcessingCount = finalProcessing;
          _completedOrdersCount = finalCompleted;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _totalSales = '₹ 0';
          _totalProducts = 0;
          _totalOrders = 0;
          _newOrdersCount = 0;
          _inProcessingCount = 0;
          _completedOrdersCount = 0;
          _isLoading = false;
        });
      }
    }
  }

  void _openAddProductSheet() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewProductScreen(
          onProductAdded: (product) {
            setState(() {
              _totalProducts += 1;
            });
          },
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _totalProducts += 1;
      });
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final displayName = widget.userProfile?.fullName.isNotEmpty == true
        ? widget.userProfile!.fullName
        : 'Farmer';
    final locationName = langProvider.translate('location_mp');

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F2),
      body: SafeArea(
        bottom: false,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: RefreshIndicator(
                    onRefresh: _fetchDashboardData,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppFadeSlideAnimation(
                            delay: Duration.zero,
                            child: _buildHeader(displayName, locationName, langProvider),
                          ),
                          const SizedBox(height: 12),
                          AppFadeSlideAnimation(
                            delay: const Duration(milliseconds: 40),
                            child: _buildHeroBanner(langProvider),
                          ),
                          const SizedBox(height: 14),
                          AppFadeSlideAnimation(
                            delay: const Duration(milliseconds: 80),
                            child: _buildMetricsRow(langProvider),
                          ),
                          const SizedBox(height: 18),
                          AppFadeSlideAnimation(
                            delay: const Duration(milliseconds: 120),
                            child: _buildTodayOverviewSection(langProvider),
                          ),
                          const SizedBox(height: 18),
                          AppFadeSlideAnimation(
                            delay: const Duration(milliseconds: 160),
                            child: LiveMandiRatesCard(
                              onViewAll: () => widget.onNavigateToTab?.call(1),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const AppFadeSlideAnimation(
                            delay: Duration(milliseconds: 200),
                            child: FarmerAdvisoryCard(),
                          ),
                          const SizedBox(height: 14),
                          const AppFadeSlideAnimation(
                            delay: Duration(milliseconds: 240),
                            child: FarmerQuickToolsRow(),
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

  Widget _buildHeader(String name, String location, LanguageProvider langProvider) {
    final greetingText = langProvider.currentLanguage == AppLanguage.english
        ? 'Hello $name! \u{1F44B}'
        : '${langProvider.translate('greeting')} \u{1F44B}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF134E2A),
              border: Border.all(color: const Color(0xFFE0ECE3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF134E2A).withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                AppAssets.realFarmerAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greetingText,
                  style: GoogleFonts.poppins(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF162D1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Color(0xFF136A36),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5A7264),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openNotifications,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E9E2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1F3528),
                      size: 23,
                    ),
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF136A36),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE9F5EA),
            Color(0xFFF1F8F1),
            Color(0xFFF7FAF7),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6E8D9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF136A36).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -25,
              bottom: -25,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC8E6C9).withValues(alpha: 0.2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 10, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          langProvider.translate('sell_produce_title'),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF104422),
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          langProvider.translate('sell_produce_sub'),
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF266E40),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _openAddProductSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF136A36),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: const Color(0xFF136A36).withValues(alpha: 0.35),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  langProvider.translate('add_product_btn'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 12,
                    child: Center(
                      child: Image.asset(
                        AppAssets.harvestCrate,
                        height: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const HarvestCrateArt(
                          width: 280,
                          height: 190,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow(LanguageProvider langProvider) {
    return Row(
      children: [
        MetricStatCard(
          title: langProvider.translate('total_products'),
          value: '$_totalProducts',
          onTap: () => widget.onNavigateToTab?.call(1),
        ),
        const SizedBox(width: 10),
        MetricStatCard(
          title: langProvider.translate('total_orders'),
          value: '$_totalOrders',
          onTap: () => widget.onNavigateToTab?.call(2),
        ),
        const SizedBox(width: 10),
        MetricStatCard(
          title: langProvider.translate('total_sales'),
          value: _totalSales,
          onTap: () => widget.onNavigateToTab?.call(3),
        ),
      ],
    );
  }

  Widget _buildTodayOverviewSection(LanguageProvider langProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langProvider.translate('today_overview'),
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF162D1E),
                letterSpacing: -0.2,
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigateToTab?.call(2),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                langProvider.translate('view_all'),
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OverviewStatCard(
              type: OverviewCardType.newOrders,
              title: langProvider.translate('new_orders'),
              count: '$_newOrdersCount',
              onTap: () {
                widget.onFilterOrders?.call('New');
                widget.onNavigateToTab?.call(2);
              },
            ),
            const SizedBox(width: 10),
            OverviewStatCard(
              type: OverviewCardType.inProcessing,
              title: langProvider.translate('in_processing'),
              count: '$_inProcessingCount',
              onTap: () {
                widget.onFilterOrders?.call('Processing');
                widget.onNavigateToTab?.call(2);
              },
            ),
            const SizedBox(width: 10),
            OverviewStatCard(
              type: OverviewCardType.completed,
              title: langProvider.translate('completed'),
              count: '$_completedOrdersCount',
              onTap: () {
                widget.onFilterOrders?.call('Completed');
                widget.onNavigateToTab?.call(2);
              },
            ),
          ],
        ),
      ],
    );
  }
}
