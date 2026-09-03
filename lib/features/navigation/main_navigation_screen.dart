import 'package:flutter/material.dart';
import '../../core/models/user_profile.dart';
import '../home/presentation/farmer_home_screen.dart';
import '../marketplace/presentation/my_products_tab.dart';
import '../marketplace/presentation/orders_tab.dart';
import '../profile/presentation/profile_tab.dart';
import '../profile/presentation/wallet_tab.dart';
import 'widgets/floating_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final int initialTabIndex;

  const MainNavigationScreen({
    super.key,
    this.userProfile,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  String? _ordersFilter;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _filterOrders(String statusFilter) {
    setState(() {
      _ordersFilter = statusFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      FarmerHomeScreen(
        key: ValueKey('farmer_home_$_currentIndex'),
        userProfile: widget.userProfile,
        onNavigateToTab: _navigateToTab,
        onFilterOrders: _filterOrders,
      ),
      const MyProductsTab(),
      OrdersTab(
        key: ValueKey(_ordersFilter ?? 'all_orders'),
        initialFilter: _ordersFilter,
      ),
      WalletTab(
        key: ValueKey('wallet_tab_$_currentIndex'),
      ),
      ProfileTab(userProfile: widget.userProfile),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F2),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Active Screen Tab View
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Floating Navigation Bar at the bottom
          FloatingNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                if (index != 2) {
                  _ordersFilter = 'All';
                }
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
