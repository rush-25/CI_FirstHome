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
final AppRouterDelegate appRouterDelegate = AppRouterDelegate(navigatorKey: rootNavigatorKey);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirstHomeApp());
}

String extractPathFromRouteInfo(RouteInformation info) {
  final uri = info.uri;
  if (uri.fragment.isNotEmpty) {
    final frag = uri.fragment;
    return frag.startsWith('/') ? frag : '/$frag';
  }
  if (uri.path.isNotEmpty) {
    return uri.path;
  }
  return '/';
}

String normalizeRoute(String raw) {
  var p = raw.trim();
  if (p.startsWith('#')) p = p.substring(1);
  if (!p.startsWith('/')) p = '/$p';
  if (p.length > 1 && p.endsWith('/')) p = p.substring(0, p.length - 1);
  if (p == '/home') return '/';
  if (p == '/register') return '/register-customer';
  return p;
}

void navigateTo(String route, {dynamic args}) {
  final navContext = rootNavigatorKey.currentContext;

  if (route == 'create-lead') {
    if (navContext != null) {
      final auth = navContext.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        navigateTo('login');
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

  appRouterDelegate.pushRoute(route);
}

class AppRouteInformationParser extends RouteInformationParser<RouteInformation> {
  const AppRouteInformationParser();

  @override
  Future<RouteInformation> parseRouteInformation(RouteInformation routeInformation) async {
    return routeInformation;
  }

  @override
  RouteInformation? restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}

class AppRouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  String _currentPath = '/';

  AppRouterDelegate({required this.navigatorKey});

  String get currentPath => _currentPath;

  void reset() {
    _currentPath = '/';
  }

  void pushRoute(String path) {
    final normalized = normalizeRoute(path);
    if (_currentPath != normalized) {
      _currentPath = normalized;
      notifyListeners();
    }
  }

  @override
  RouteInformation get currentConfiguration => RouteInformation(uri: Uri.parse(_currentPath));

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    final path = extractPathFromRouteInfo(configuration);
    final normalized = normalizeRoute(path);
    if (_currentPath != normalized) {
      _currentPath = normalized;
      notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey('landing-page'),
          name: '/',
          child: LandingScreen(onNavigate: navigateTo),
        ),
        if (_currentPath == '/directory')
          MaterialPage(
            key: const ValueKey('directory-page'),
            name: '/directory',
            child: DirectoryScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/login')
          MaterialPage(
            key: const ValueKey('login-page'),
            name: '/login',
            child: LoginScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/register' || _currentPath == '/register-customer')
          const MaterialPage(
            key: ValueKey('register-customer-page'),
            name: '/register-customer',
            child: RegisterScreen(initialRole: 'Customer', onNavigate: navigateTo),
          )
        else if (_currentPath == '/register-provider')
          const MaterialPage(
            key: ValueKey('register-provider-page'),
            name: '/register-provider',
            child: RegisterScreen(initialRole: 'Provider', onNavigate: navigateTo),
          )
        else if (_currentPath == '/customer-dashboard')
          MaterialPage(
            key: const ValueKey('customer-dashboard-page'),
            name: '/customer-dashboard',
            child: CustomerDashboardScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/provider-dashboard')
          MaterialPage(
            key: const ValueKey('provider-dashboard-page'),
            name: '/provider-dashboard',
            child: ProviderDashboardScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/admin-dashboard')
          MaterialPage(
            key: const ValueKey('admin-dashboard-page'),
            name: '/admin-dashboard',
            child: AdminDashboardScreen(onNavigate: navigateTo),
          ),
      ],
      onDidRemovePage: (page) {
        if (_currentPath != '/') {
          _currentPath = '/';
          notifyListeners();
        }
      },
    );
  }
}

class FirstHomeApp extends StatefulWidget {
  const FirstHomeApp({super.key});

  @override
  State<FirstHomeApp> createState() => _FirstHomeAppState();
}

class _FirstHomeAppState extends State<FirstHomeApp> {
  late final AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    appRouterDelegate.reset();
    _routeInformationParser = const AppRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => DirectoryProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerDelegate: appRouterDelegate,
        routeInformationParser: _routeInformationParser,
      ),
    );
  }
}
