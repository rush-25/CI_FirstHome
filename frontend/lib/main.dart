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
import 'screens/landing/how_it_works_screen.dart';
import 'screens/landing/about_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/directory/directory_screen.dart';
import 'screens/directory/provider_detail_dialog.dart';
import 'screens/customer/customer_dashboard_screen.dart';
import 'screens/customer/create_lead_dialog.dart';
import 'screens/provider/provider_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final AppRouterDelegate appRouterDelegate = AppRouterDelegate(
  navigatorKey: rootNavigatorKey,
);

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

  if (route == 'home' || route == '/') {
    if (navContext != null) {
      Navigator.of(navContext, rootNavigator: true).popUntil((r) => r.isFirst);
    }
    appRouterDelegate.pushRoute('home');
    return;
  }

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

  appRouterDelegate.pushRoute(route);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) {
      PrimaryScrollController.maybeOf(ctx)?.jumpTo(0.0);
    }
  });
}

class AppRouteInformationParser
    extends RouteInformationParser<RouteInformation> {
  const AppRouteInformationParser();

  @override
  Future<RouteInformation> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return routeInformation;
  }

  @override
  RouteInformation? restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}

class LuxuryPage<T> extends Page<T> {
  final Widget child;

  const LuxuryPage({
    required LocalKey super.key,
    required super.name,
    required this.child,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.015),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class AppRouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  String _currentPath = '/';
  int _routeId = 0;

  AppRouterDelegate({required this.navigatorKey});

  String get currentPath => _currentPath;

  void reset() {
    _currentPath = '/';
    _routeId++;
    notifyListeners();
  }

  void pushRoute(String path) {
    final normalized = normalizeRoute(path);
    if (_currentPath != normalized) {
      _currentPath = normalized;
      _routeId++;
      notifyListeners();
    }
    if (normalized == '/') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeScrollTrigger.value++;
      });
    }
  }

  @override
  RouteInformation get currentConfiguration =>
      RouteInformation(uri: Uri.parse(_currentPath));

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) async {
    final path = extractPathFromRouteInfo(configuration);
    final normalized = normalizeRoute(path);
    if (_currentPath != normalized) {
      _currentPath = normalized;
      _routeId++;
      notifyListeners();
    }
    if (normalized == '/') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeScrollTrigger.value++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        LuxuryPage(
          key: ValueKey('landing-page-$_routeId'),
          name: '/',
          child: LandingScreen(onNavigate: navigateTo),
        ),
        if (_currentPath == '/directory')
          LuxuryPage(
            key: ValueKey('directory-page-$_routeId'),
            name: '/directory',
            child: DirectoryScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/how-it-works')
          LuxuryPage(
            key: ValueKey('how-it-works-page-$_routeId'),
            name: '/how-it-works',
            child: HowItWorksScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/about')
          LuxuryPage(
            key: ValueKey('about-page-$_routeId'),
            name: '/about',
            child: AboutScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/login')
          LuxuryPage(
            key: ValueKey('login-page-$_routeId'),
            name: '/login',
            child: LoginScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/register' ||
            _currentPath == '/register-customer')
          LuxuryPage(
            key: ValueKey('register-customer-page-$_routeId'),
            name: '/register-customer',
            child: const RegisterScreen(
              initialRole: 'Customer',
              onNavigate: navigateTo,
            ),
          )
        else if (_currentPath == '/register-provider')
          LuxuryPage(
            key: ValueKey('register-provider-page-$_routeId'),
            name: '/register-provider',
            child: const RegisterScreen(
              initialRole: 'Provider',
              onNavigate: navigateTo,
            ),
          )
        else if (_currentPath == '/customer-dashboard')
          LuxuryPage(
            key: ValueKey('customer-dashboard-page-$_routeId'),
            name: '/customer-dashboard',
            child: CustomerDashboardScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/provider-dashboard')
          LuxuryPage(
            key: ValueKey('provider-dashboard-page-$_routeId'),
            name: '/provider-dashboard',
            child: ProviderDashboardScreen(onNavigate: navigateTo),
          )
        else if (_currentPath == '/admin-dashboard')
          LuxuryPage(
            key: ValueKey('admin-dashboard-page-$_routeId'),
            name: '/admin-dashboard',
            child: AdminDashboardScreen(onNavigate: navigateTo),
          ),
      ],
      onDidRemovePage: (page) {
        if (_currentPath != '/') {
          _currentPath = '/';
          _routeId++;
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
