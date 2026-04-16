import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../models/vendor.dart';
import '../backend/vendor_backend_service.dart';
import '../backend/supabase_config.dart';
import '../../services/vendor_service.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});
  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  List<Vendor> _vendors = [];
  bool _loading = true;
  String _search = '';
  String _cityFilter = 'All';

  static const _cities = ['All', 'Lusaka', 'Ndola', 'Livingstone', 'Kitwe'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    List<Vendor> vendors;

    if (SupabaseConfig.isLoggedIn) {
      // Use backend if logged in
      vendors = await VendorBackendService.getVendors(
          city: _cityFilter == 'All' ? null : _cityFilter);
    } else {
      // Fall back to local seed data
      vendors = await VendorService.getAll();
    }

    if (mounted) setState(() { _vendors = vendors; _loading = false; });
  }

  Future<void> _search_() async {
    if (_search.isEmpty) { _load(); return; }
    setState(() => _loading = true);
    final results = SupabaseConfig.isLoggedIn
        ? await VendorBackendService.search(_search)
        : (await VendorService.getAll())
            .where((v) => v.name.toLowerCase().contains(_search.toLowerCase()) ||
                v.marketName.toLowerCase().contains(_search.toLowerCase()))
            .toList();
    if (mounted) setState(() { _vendors = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish vendors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded),
            tooltip: 'Register as vendor',
            onPressed: () => _showRegisterSheet(),
          ),
        ],
      ),
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: (v) {
              setState(() => _search = v);
              _search_();
            },
            decoration: InputDecoration(
              hintText: 'Search vendors or markets...',
              hintStyle: const TextStyle(fontFamily: 'Poppins'),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        setState(() => _search = '');
                        _load();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // City filter chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _cities.map((c) {
              final active = _cityFilter == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c,
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? AppColors.primary : AppColors.textSecondary,
                      )),
                  selected: active,
                  onSelected: (_) {
                    setState(() => _cityFilter = c);
                    _load();
                  },
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
        ),

        // Vendor list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _vendors.isEmpty
                  ? _EmptyState(onRefresh: _load)
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _vendors.length,
                        itemBuilder: (_, i) => _VendorCard(vendor: _vendors[i])
                            .animate(delay: Duration(milliseconds: i * 40))
                            .fadeIn(duration: 250.ms)
                            .slideY(begin: 0.05, end: 0),
                      ),
                    ),
        ),
      ]),
    );
  }

  void _showRegisterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _RegisterVendorSheet(),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  const _VendorCard({required this.vendor});

  Future<void> _openWhatsApp() async {
    final url = Uri.parse(vendor.whatsappUrl);
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _call() async {
    final url = Uri.parse('tel:${vendor.phone}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5),
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            // Avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(vendor.initials,
                    style: const TextStyle(fontFamily: 'Poppins',
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(vendor.name, style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 15,
                      fontWeight: FontWeight.w600)),
                  if (vendor.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded,
                        size: 15, color: AppColors.primary),
                  ],
                ]),
                Text(vendor.locationLabel, style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary
                        : AppColors.textSecondary)),
              ],
            )),
            // Rating
            if (vendor.averageRating != null && vendor.averageRating! > 0)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded,
                      size: 14, color: AppColors.accent),
                  const SizedBox(width: 2),
                  Text(vendor.averageRating!.toStringAsFixed(1),
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
                Text('${vendor.totalScans} scans',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                        color: isDark ? AppColors.darkTextTertiary
                            : AppColors.textTertiary)),
              ]),
          ]),
        ),

        // Description
        if (vendor.description != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Text(vendor.description!,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.5),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),

        // Species chips
        if (vendor.fishSpecies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Wrap(spacing: 6, runSpacing: 4,
              children: vendor.fishSpecies.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s, style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 10,
                    fontWeight: FontWeight.w500, color: AppColors.primary)),
              )).toList(),
            ),
          ),

        // Action buttons
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                width: 0.5)),
          ),
          child: Row(children: [
            Expanded(child: TextButton.icon(
              onPressed: _call,
              icon: const Icon(Icons.phone_rounded, size: 16),
              label: const Text('Call',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
            )),
            Container(width: 0.5,
                color: isDark ? AppColors.darkBorder : AppColors.borderLight),
            Expanded(child: TextButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.chat_rounded, size: 16),
              label: const Text('WhatsApp',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF25D366)),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.store_rounded, size: 56,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextTertiary : AppColors.textHint),
      const SizedBox(height: 16),
      const Text('No vendors found',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      const Text('Try a different city or search term',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Refresh',
            style: TextStyle(fontFamily: 'Poppins')),
      ),
    ]),
  );
}

class _RegisterVendorSheet extends StatelessWidget {
  const _RegisterVendorSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('Register as a vendor',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
          'List your fish stall so customers can find you on FishCheck ZM.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to auth if not logged in
              if (!SupabaseConfig.isLoggedIn) {
                context.push('/auth');
              } else {
                // TODO: vendor registration form - Phase 5b
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(
                      'Vendor registration form coming soon!')),
                );
              }
            },
            icon: const Icon(Icons.store_rounded, size: 18),
            label: const Text('Register my stall',
                style: TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now',
              style: TextStyle(fontFamily: 'Poppins')),
        ),
      ]),
    );
  }
}
