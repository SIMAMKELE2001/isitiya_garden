import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/widgets/state_views.dart';
import '../features/auth/data/auth_providers.dart';
import '../features/auth/models/user_profile.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/onboarding_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/buyer/presentation/buyer_shell.dart';
import '../features/farmer/presentation/farmer_home_page.dart';
import 'theme/app_theme.dart';

/// The root widget of the whole application.
class IsitiyaGardenApp extends StatelessWidget {
  const IsitiyaGardenApp({super.key, required this.configured});

  /// False when the Supabase settings were not supplied at startup.
  final bool configured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'isitiyaGarden',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: configured ? const AppGate() : const _SetupMissingPage(),
    );
  }
}

/// Decides which screen to show: splash, onboarding, login, or the home
/// screen for the logged-in user's role (FR03).
class AppGate extends ConsumerStatefulWidget {
  const AppGate({super.key});

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> {
  static const _seenKey = 'onboarding_seen';

  bool _splashDone = false;
  bool _onboardingSeen = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    setState(() {
      _onboardingSeen = prefs.getBool(_seenKey) ?? false;
      _splashDone = true;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
    if (mounted) setState(() => _onboardingSeen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) return const SplashPage();

    final profile = ref.watch(currentProfileProvider);
    return profile.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: ErrorState(
            message: 'Something went wrong. Please try again.',
            onRetry: () => ref.invalidate(currentProfileProvider),
          ),
        ),
      ),
      data: (p) {
        if (p != null) {
          return p.role == UserRole.farmer
              ? const FarmerHomePage()
              : const BuyerShell();
        }
        if (!_onboardingSeen) {
          return OnboardingPage(onFinished: _finishOnboarding);
        }
        return const LoginPage();
      },
    );
  }
}

class _SetupMissingPage extends StatelessWidget {
  const _SetupMissingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Supabase settings are missing.\n\n'
              'Create env.json (copy env.example.json) and start the app with:\n'
              'flutter run --dart-define-from-file=env.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
