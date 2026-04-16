import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/freshness_result.dart';
import '../services/history_service.dart';
import '../widgets/freshness_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<FreshnessResult> _history = [];
  bool _loading = true;
  String _filter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = _searchQuery.isNotEmpty
        ? await HistoryService.search(_searchQuery)
        : await HistoryService.getHistory();
    if (mounted) setState(() { _history = h; _loading = false; });
  }

  Future<void> _delete(FreshnessResult r) async {
    await HistoryService.deleteResult(r.id);
    await _load();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all history',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        content: const Text('This will delete all scan records. This cannot be undone.',
            style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear all',
                style: TextStyle(fontFamily: 'Poppins', color: AppColors.spoiled,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HistoryService.clearHistory();
      await _load();
    }
  }

  List<FreshnessResult> get _filtered {
    if (_filter == 'all') return _history;
    return _history.where((r) => r.freshness.name == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan history'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear all',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty && _searchQuery.isEmpty
              ? const _EmptyState()
              : Column(children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextField(
                      onChanged: (v) {
                        setState(() { _searchQuery = v; _loading = true; });
                        _load();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by fish name...',
                        hintStyle: const TextStyle(fontFamily: 'Poppins'),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  setState(() { _searchQuery = ''; _loading = true; });
                                  _load();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  // Filter chips
                  _FilterRow(
                    selected: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                  ),
                  // List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: _filtered.isEmpty
                          ? _NoResultsState(filter: _filter)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _HistoryTile(
                                result: _filtered[i],
                                onTap: () => context.push('/result',
                                    extra: {'result': _filtered[i], 'bytes': _filtered[i].imageBytes}),
                                onDelete: () => _delete(_filtered[i]),
                              )
                                  .animate(delay: Duration(milliseconds: i * 40))
                                  .fadeIn(duration: 250.ms)
                                  .slideX(begin: 0.04, end: 0),
                            ),
                    ),
                  ),
                ]),
    );
  }
}

// ─── Filter Row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _FilterRow({required this.selected, required this.onChanged});

  static const _chips = [
    ('all', 'All'),
    ('fresh', 'Fresh'),
    ('acceptable', 'Acceptable'),
    ('poor', 'Poor'),
    ('spoiled', 'Spoiled'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _chips.map((c) {
          final active = selected == c.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(c.$2,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                  )),
              selected: active,
              onSelected: (_) => onChanged(c.$1),
              selectedColor: AppColors.primarySurface,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: active ? AppColors.primary : AppColors.border,
                width: active ? 1.5 : 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── History tile ─────────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final FreshnessResult result;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _HistoryTile({required this.result, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = FreshnessColors.forLevel(result.freshness);
    return Dismissible(
      key: Key(result.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.spoiled,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.5,
            ),
          ),
          child: Row(children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: result.imageBytes != null
                  ? Image.memory(result.imageBytes!, width: 58, height: 58, fit: BoxFit.cover)
                  : Container(
                      width: 58, height: 58,
                      color: color.withOpacity(0.12),
                      child: Icon(Icons.set_meal_rounded, color: color, size: 28),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(result.fishType,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              FreshnessBadge(level: result.freshness, label: result.freshnessLabel),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMM yyyy · HH:mm').format(result.analysedAt),
                style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 11,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                ),
              ),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${result.score}%',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 18,
                      fontWeight: FontWeight.w700, color: color)),
              Text('score',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─── Empty states ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.history_rounded, size: 64,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextTertiary : AppColors.textHint),
      const SizedBox(height: 16),
      const Text('No scans yet',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      Text('Analyse a fish to see your history here',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextTertiary : AppColors.textTertiary)),
    ]),
  );
}

class _NoResultsState extends StatelessWidget {
  final String filter;
  const _NoResultsState({required this.filter});
  @override
  Widget build(BuildContext context) => Center(
    child: Text('No $filter scans found',
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
  );
}
