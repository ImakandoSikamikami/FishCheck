import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';

class _NavDest {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavDest({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _destinations = [
  _NavDest(route: AppRouter.home,     icon: Icons.home_outlined,       activeIcon: Icons.home_rounded,         label: 'Home'),
  _NavDest(route: AppRouter.scan,     icon: Icons.camera_alt_outlined,  activeIcon: Icons.camera_alt_rounded,   label: 'Scan'),
  _NavDest(route: AppRouter.vendors,  icon: Icons.store_outlined,       activeIcon: Icons.store_rounded,        label: 'Vendors'),
  _NavDest(route: AppRouter.history,  icon: Icons.history_outlined,     activeIcon: Icons.history_rounded,      label: 'History'),
  _NavDest(route: AppRouter.settings, icon: Icons.settings_outlined,    activeIcon: Icons.settings_rounded,     label: 'Settings'),
];

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _indexForLocation(String location) {
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  bool get _isWide {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexForLocation(location);
    final wide = _isWide ||
        MediaQuery.of(context).size.width > 700;

    if (wide) return _WideShell(child: child, index: index);

    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(
        index: index,
        onTap: (i) => context.go(_destinations[i].route),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_destinations.length, (i) {
              final d = _destinations[i];
              final active = i == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primarySurface : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            active ? d.activeIcon : d.icon,
                            size: 22,
                            color: active
                                ? AppColors.primary
                                : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active
                                ? AppColors.primary
                                : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _WideShell extends StatelessWidget {
  final Widget child;
  final int index;
  const _WideShell({required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Row(
        children: [
          // Side rail
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.set_meal_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('FishCheck ZM', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Freshness App', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textTertiary)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(_destinations.length, (i) {
                    final d = _destinations[i];
                    final active = i == index;
                    return GestureDetector(
                      onTap: () => context.go(d.route),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primarySurface : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          Icon(active ? d.activeIcon : d.icon, size: 20,
                              color: active ? AppColors.primary : AppColors.textTertiary),
                          const SizedBox(width: 12),
                          Text(d.label, style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 14,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active ? AppColors.primary : AppColors.textSecondary,
                          )),
                        ]),
                      ),
                    );
                  }),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('FishCheck ZM · Instant Analysis',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
