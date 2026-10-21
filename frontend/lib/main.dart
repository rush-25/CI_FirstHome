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
import 'screens/customer/customer_dashboard_screen.dart';
import 'screens/customer/create_lead_dialog.dart';
import 'screens/provider/provider_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirstHomeApp());
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
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AppRootNavigator(),
      ),
    );
  }
}

class AppRootNavigator extends StatefulWidget {
  const AppRootNavigator({super.key});

  @override
  State<AppRootNavigator> createState() => _AppRootNavigatorState();
}

class _AppRootNavigatorState extends State<AppRootNavigator> {
  String _currentRoute = 'home';
  dynamic _routeArgs;

  void _navigateTo(String route, {dynamic args}) {
    if (route == 'create-lead') {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        setState(() {
          _currentRoute = 'login';
          _routeArgs = null;
        });
        return;
      }
      showDialog(
        context: context,
        builder: (ctx) => CreateLeadDialog(
          preselectedProvider: args is ProviderModel ? args : null,
          onNavigate: _navigateTo,
        ),
      );
      return;
    }

    if (route == 'categories') {
      setState(() {
        _currentRoute = 'directory';
        _routeArgs = null;
      });
      return;
    }

    if (route == 'how-it-works') {
      setState(() {
        _currentRoute = 'home';
        _routeArgs = null;
      });
      return;
    }

    setState(() {
      _currentRoute = route;
      _routeArgs = args;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentRoute) {
      case 'directory':
        return DirectoryScreen(onNavigate: _navigateTo);
      case 'login':
        return LoginScreen(onNavigate: _navigateTo);
      case 'register-customer':
        return RegisterScreen(initialRole: 'Customer', onNavigate: _navigateTo);
      case 'register-provider':
        return RegisterScreen(initialRole: 'Provider', onNavigate: _navigateTo);
      case 'customer-dashboard':
        return CustomerDashboardScreen(onNavigate: _navigateTo);
      case 'provider-dashboard':
        return ProviderDashboardScreen(onNavigate: _navigateTo);
      case 'admin-dashboard':
        return AdminDashboardScreen(onNavigate: _navigateTo);
      case 'home':
      default:
        return LandingScreen(onNavigate: _navigateTo);
    }
  }
}
