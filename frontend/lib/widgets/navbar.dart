import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String route)? onNavigate;

  const Navbar({super.key, this.onNavigate});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Container(
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo
              Flexible(
                child: InkWell(
                  onTap: () => onNavigate?.call('home'),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.home_work_rounded, color: AppColors.gold, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'FirstHome',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Nigeria',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Trusted Home Services',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Desktop Navigation Links
              if (!isMobile)
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NavLink(label: 'Find Professionals', onTap: () => onNavigate?.call('directory')),
                        _NavLink(label: 'How It Works', onTap: () => onNavigate?.call('how-it-works')),
                        _NavLink(label: 'Become a Provider', onTap: () => onNavigate?.call('register-provider')),
                      ],
                    ),
                  ),
                ),

              // Desktop Auth Actions
              if (!isMobile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (auth.isAuthenticated) ...[
                      InkWell(
                        onTap: () {
                          if (auth.isAdmin) {
                            onNavigate?.call('admin-dashboard');
                          } else if (auth.isProvider) {
                            onNavigate?.call('provider-dashboard');
                          } else {
                            onNavigate?.call('customer-dashboard');
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.sage.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  auth.currentUser?.fullName.isNotEmpty == true
                                      ? auth.currentUser!.fullName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auth.currentUser?.fullName ?? 'User',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${auth.currentUser?.role} Dashboard',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 18),
                        tooltip: 'Sign Out',
                        onPressed: () async {
                          await auth.logout();
                          onNavigate?.call('home');
                        },
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: () => onNavigate?.call('login'),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => onNavigate?.call('register-customer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        child: const Text('Get Started', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ],
                ),

              // Mobile Navigation
              if (isMobile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (auth.isAuthenticated) ...[
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          auth.currentUser?.fullName.isNotEmpty == true
                              ? auth.currentUser!.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 18),
                        tooltip: 'Sign Out',
                        onPressed: () async {
                          await auth.logout();
                          onNavigate?.call('home');
                        },
                      ),
                    ],
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                      onSelected: (val) => onNavigate?.call(val),
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'home', child: Text('Home')),
                        const PopupMenuItem(value: 'directory', child: Text('Find Professionals')),
                        const PopupMenuItem(value: 'register-provider', child: Text('Become a Provider')),
                        if (!auth.isAuthenticated) ...[
                          const PopupMenuItem(value: 'login', child: Text('Log In')),
                          const PopupMenuItem(value: 'register-customer', child: Text('Register as Customer')),
                        ] else ...[
                          PopupMenuItem(
                            value: auth.isAdmin
                                ? 'admin-dashboard'
                                : auth.isProvider
                                    ? 'provider-dashboard'
                                    : 'customer-dashboard',
                            child: Text('My Dashboard (${auth.currentUser?.role})'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
