import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/models/user_profile.dart';
import 'core/providers/language_provider.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final currentUser = await AuthService().getCurrentUser();
  runApp(FarmerApp(initialUserProfile: currentUser));
}

class FarmerApp extends StatefulWidget {
  final LanguageProvider? languageProvider;
  final UserProfile? initialUserProfile;

  const FarmerApp({
    super.key,
    this.languageProvider,
    this.initialUserProfile,
  });

  @override
  State<FarmerApp> createState() => _FarmerAppState();
}

class _FarmerAppState extends State<FarmerApp> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialUserProfile != null) {
      _userProfile = widget.initialUserProfile;
      _isLoading = false;
    } else {
      _checkCurrentUser();
    }
  }

  Future<void> _checkCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) {
      setState(() {
        _userProfile = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => widget.languageProvider ?? LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return MaterialApp(
            title: langProvider.translate('app_title'),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: langProvider.currentLocale,
            home: _isLoading
                ? const Scaffold(
                    backgroundColor: Color(0xFFFBF9F2),
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF136A36),
                      ),
                    ),
                  )
                : (_userProfile != null
                    ? DashboardScreen(userProfile: _userProfile!)
                    : const WelcomeScreen()),
          );
        },
      ),
    );
  }
}
