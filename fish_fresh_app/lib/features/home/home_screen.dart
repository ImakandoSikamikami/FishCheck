import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';
import '../../models/freshness_result.dart';
import '../../services/history_service.dart';
import '../../services/offline_queue_service.dart';
import '../../widgets/freshness_widgets.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _stats = {};
  List<FreshnessResult> _recent = [];
  bool _loading = true;
  bool _isOnline = true;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _watchConnectivity();
  }

  void _watchConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (mounted) setState(() => _isOnline = online);
    });
    OfflineQueueService.hasConnectivity().then((online) {
      if (mounted) setState(() => _isOnline = online);
    });
  }

  Future<void> _load() async {
    final stats = await HistoryService.getStats();
    final history = await HistoryService.getHistory();
    final pending = await OfflineQueueService.queueLength();
    if (mounted) {
      setState(() {
        _stats = stats;
        _recent = history.take(4).toList();
        _pendingCount = pending;
        _loading = false;
      });
    }
  }

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.homeGoodMorning;
    if (h < 17) return l.homeGoodAfternoon;
    return l.homeGoodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // ─── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_greeting(l),
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Text('FishCheck ZM',
                            style: Theme.of(context).textTheme.headlineMedium),
                      ]).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      GestureDetector(
                        onTap: () => context.go(AppRouter.settings),
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.border,
                              width: 0.5),
                          ),
                          child: Icon(Icons.settings_outlined, size: 20,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ).animate(delay: 100.ms).fadeIn(),
                    ],
                  ),
                ),
              ),

              // ─── Offline banner ──────────────────────────────────────────
              if (!_isOnline)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _OfflineBanner(pendingCount: _pendingCount),
                  ),
                ),

              // ─── Pending queue badge ─────────────────────────────────────
              if (_isOnline && _pendingCount > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _PendingQueueBanner(
                      count: _pendingCount,
                      onDrain: () async {
                        await OfflineQueueService.drainQueue(
                            onItemProcessed: _load);
                        _load();
                      },
                    ),
                  ),
                ),

              // ─── Stats row ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _loading
                      ? const SizedBox(height: 72)
                      : Row(children: [
                          Expanded(child: _StatCard(
                            label: l.homeScansToday,
                            value: '${_stats['today'] ?? 0}',
                            icon: Icons.camera_alt_rounded,
                            color: AppColors.primary,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _StatCard(
                            label: l.homeFreshRate,
                            value: '${((_stats['freshRate'] ?? 0.0) * 100).round()}%',
                            icon: Icons.trending_up_rounded,
                            color: AppColors.fresh,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _StatCard(
                            label: l.homeTotalScans,
                            value: '${_stats['total'] ?? 0}',
                            icon: Icons.history_rounded,
                            color: AppColors.accent,
                          )),
                        ]).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1),
                ),
              ),

              // ─── Hero scan button ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _HeroScanButton(
                    onTap: () => context.go(AppRouter.scan),
                    topSpecies: _stats['topSpecies'] as String?,
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
                ),
              ),

              // ─── Quick actions ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(children: [
                    Expanded(child: _QuickAction(
                      icon: Icons.menu_book_rounded,
                      label: l.homeSpeciesGuide,
                      color: const Color(0xFF1565A0),
                      onTap: () => context.go(AppRouter.species),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickAction(
                      icon: Icons.history_rounded,
                      label: l.homeScanHistory,
                      color: AppColors.primaryDark,
                      onTap: () => context.go(AppRouter.history),
                    )),
                  ]).animate(delay: 250.ms).fadeIn(),
                ),
              ),

              // ─── Recent scans ────────────────────────────────────────────
              if (!_loading && _recent.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.homeRecentScans,
                            style: Theme.of(context).textTheme.titleMedium),
                        TextButton(
                          onPressed: () => context.go(AppRouter.history),
                          child: Text(l.homeSeeAll,
                              style: const TextStyle(fontFamily: 'Poppins')),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: _RecentScanTile(
                        result: _recent[i],
                        onTap: () => context.push('/result', extra: {
                          'result': _recent[i],
                          'bytes': _recent[i].imageBytes,
                        }),
                      ).animate(delay: Duration(milliseconds: 300 + i * 50))
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.08, end: 0),
                    ),
                    childCount: _recent.length,
                  ),
                ),
              ],

              if (!_loading && _recent.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                    child: _EmptyState(onScan: () => context.go(AppRouter.scan)),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final int pendingCount;
  const _OfflineBanner({required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.poorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.poor.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.poor),
        const SizedBox(width: 10),
        Expanded(child: Text(
          pendingCount > 0
              ? l.homeOfflineQueued(pendingCount)
              : l.homeNoInternet,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: AppColors.poor, fontWeight: FontWeight.w500),
        )),
      ]),
    );
  }
}

class _PendingQueueBanner extends StatelessWidget {
  final int count;
  final VoidCallback onDrain;
  const _PendingQueueBanner({required this.count, required this.onDrain});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(Icons.cloud_upload_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(
          l.homeOfflineReady(count),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: AppColors.primary, fontWeight: FontWeight.w500),
        )),
        TextButton(
          onPressed: onDrain,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(l.homeAnalyseNow,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 20,
            fontWeight: FontWeight.w700, color: color)),
        Text(label, style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _HeroScanButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? topSpecies;
  const _HeroScanButton({required this.onTap, this.topSpecies});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(children: [
          Positioned(right: -16, top: -16,
              child: Container(width: 110, height: 110,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      shape: BoxShape.circle))),
          Positioned(right: 30, bottom: -24,
              child: Container(width: 70, height: 70,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 24),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.homeScanAFish,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 20,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(
                    topSpecies != null && topSpecies != '—'
                        ? l.homeMostScanned(topSpecies!)
                        : l.homeTakeOrUpload,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        color: Colors.white.withOpacity(0.75)),
                  ),
                ]),
              ],
            ),
          ),
          Positioned(
            right: 18, bottom: 18,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Poppins',
              fontSize: 13, fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          Icon(Icons.chevron_right_rounded, size: 16,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
        ]),
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  final FreshnessResult result;
  final VoidCallback onTap;
  const _RecentScanTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = FreshnessColors.forLevel(result.freshness);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: result.imageBytes != null
                ? Image.memory(result.imageBytes!, width: 52, height: 52,
                    fit: BoxFit.cover)
                : Container(width: 52, height: 52,
                    color: color.withOpacity(0.12),
                    child: Icon(Icons.set_meal_rounded, color: color, size: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(result.fishType, style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              FreshnessBadge(level: result.freshness, label: result.freshnessLabel),
              const SizedBox(width: 8),
              if (result.isPending)
                const SizedBox(width: 12, height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: AppColors.acceptable)),
            ]),
            const SizedBox(height: 3),
            Text(DateFormat('d MMM, HH:mm').format(result.analysedAt),
                style: Theme.of(context).textTheme.bodySmall),
          ])),
          if (!result.isPending)
            Text('${result.score}%', style: TextStyle(fontFamily: 'Poppins',
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.set_meal_outlined, size: 60,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextTertiary : AppColors.textHint),
        const SizedBox(height: 14),
        Text(l.homeNoScansYet, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(l.homeScanFirstFish, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.camera_alt_rounded, size: 18),
          label: Text(l.homeScanAFish,
              style: const TextStyle(fontFamily: 'Poppins')),
        ),
      ]),
    );
  }
}
