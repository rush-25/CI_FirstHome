import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'models/provider_model.dart';
import 'providers/auth_provider.dart';
import 'providers/directory_provider.dart';
import 'providers/lead_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/directory/directory_screen.dart';
import 'screens/directory/provider_detail_dialog.dart';
import 'screens/customer/customer_dashboard_screen.dart';
import 'screens/customer/create_lead_dialog.dart';
import 'screens/provider/provider_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirstHomeApp());
}

void navigateTo(String route, {dynamic args}) {
  final navContext = rootNavigatorKey.currentContext;

  if (route == 'create-lead') {
    if (navContext != null) {
      final auth = navContext.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        rootNavigatorKey.currentState?.pushNamed('/login');
        return;
      }
      showDialog(
        context: navContext,
        builder: (ctx) => CreateLeadDialog(
          preselectedProvider: args is ProviderModel ? args : null,
          onNavigate: navigateTo,
        ),
      );
    }
    return;
  }

  if (route == 'provider-detail') {
    if (navContext != null) {
      ProviderModel? provider;
      if (args is ProviderModel) {
        provider = args;
      } else if (args is int) {
        final dir = navContext.read<DirectoryProvider>();
        try {
          provider = dir.providers.firstWhere((p) => p.id == args);
        } catch (_) {}
      }
      if (provider != null) {
        showDialog(
          context: navContext,
          builder: (ctx) => ProviderDetailDialog(
            provider: provider!,
            onEnquire: (p) => navigateTo('create-lead', args: p),
          ),
        );
        return;
      }
    }
    navigateTo('directory');
    return;
  }

  if (route == 'categories') {
    navigateTo('directory');
    return;
  }

  if (route == 'how-it-works') {
    navigateTo('home');
    return;
  }

  final normalized = route.startsWith('/') ? route : '/$route';

  if (normalized == '/' || normalized == '/home') {
    if (rootNavigatorKey.currentState?.canPop() == true) {
      rootNavigatorKey.currentState?.popUntil((r) => r.isFirst);
    } else {
      rootNavigatorKey.currentState?.pushReplacementNamed('/');
    }
    return;
  }

  // Push new named route so browser history and back button work natively
  rootNavigatorKey.currentState?.pushNamed(normalized);
}

class FirstHomeApp extends StatelessWidget {
  const FirstHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => DirectoryProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '/');
          final path = uri.path.isEmpty ? '/' : uri.path;

          switch (path) {
            case '/':
            case '/home':
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/'),
                builder: (_) => LandingScreen(onNavigate: navigateTo),
              );
            case '/directory':
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/directory'),
                builder: (_) => DirectoryScreen(onNavigate: navigateTo),
              );
            case '/login':
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/login'),
                builder: (_) => LoginScreen(onNavigate: navigateTo),
              );
            case '/register':
            case '/register-customer':
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/register-customer'),
                builder: (_) => const RegisterScreen(initialRole: 'Customer', onNavigate: navigateTo),
              );
            case '/register-provider':
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/register-provider'),
                builder: (_) => const RegisterScreen(initialRole: 'Provider', onNavigate: navigateTo),
              );
            case '/customer-dashboard':
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/customer-dashboard'),
                builder: (_) => CustomerDashboardScreen(onNavigate: navigateTo),
              );
            case '/provider-dashboard':
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/provider-dashboard'),
                builder: (_) => ProviderDashboardScreen(onNavigate: navigateTo),
              );
            case '/admin-dashboard':
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/admin-dashboard'),
                builder: (_) => AdminDashboardScreen(onNavigate: navigateTo),
              );
            default:
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/'),
                builder: (_) => LandingScreen(onNavigate: navigateTo),
              );
          }
        },
      ),
    );
  }
}
