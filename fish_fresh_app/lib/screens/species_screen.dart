import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';
import '../l10n/app_localizations.dart';

class SpeciesScreen extends StatefulWidget {
  const SpeciesScreen({super.key});
  @override
  State<SpeciesScreen> createState() => _SpeciesScreenState();
}

class _SpeciesData {
  final String name;
  final List<String> localNames;
  final String habitat;
  final String season;
  final String priceRange;
  final String description;
  final String freshIndicators;
  final String spoilageWarning;
  final String cookingTip;
  final String emoji;
  final Color color;

  const _SpeciesData({
    required this.name, required this.localNames, required this.habitat,
    required this.season, required this.priceRange, required this.description,
    required this.freshIndicators, required this.spoilageWarning,
    required this.cookingTip, required this.emoji, required this.color,
  });
}

List<_SpeciesData> _buildSpecies(AppLocalizations l) => [
  _SpeciesData(
    name: l.kapentaName, emoji: '🐟',
    color: const Color(0xFF185FA5),
    localNames: const ['Kapenta', 'Ndakala', 'Matemba'],
    habitat: l.kapentaHabitat,
    season: l.kapentaSeason,
    priceRange: l.kapentaPriceRange,
    description: l.kapentaDescription,
    freshIndicators: l.kapentaFreshIndicators,
    spoilageWarning: l.kapentaSpoilageWarning,
    cookingTip: l.kapentaCookingTip,
  ),
  _SpeciesData(
    name: l.breamName, emoji: '🐠',
    color: const Color(0xFF0A7B5C),
    localNames: const ['Brim', 'Tilapia', 'Ngumbu', 'Chisense'],
    habitat: l.breamHabitat,
    season: l.breamSeason,
    priceRange: l.breamPriceRange,
    description: l.breamDescription,
    freshIndicators: l.breamFreshIndicators,
    spoilageWarning: l.breamSpoilageWarning,
    cookingTip: l.breamCookingTip,
  ),
  _SpeciesData(
    name: l.tigerName, emoji: '🦷',
    color: const Color(0xFF854F0B),
    localNames: const ['Nkupi', 'Mupende', 'Mputi'],
    habitat: l.tigerHabitat,
    season: l.tigerSeason,
    priceRange: l.tigerPriceRange,
    description: l.tigerDescription,
    freshIndicators: l.tigerFreshIndicators,
    spoilageWarning: l.tigerSpoilageWarning,
    cookingTip: l.tigerCookingTip,
  ),
  _SpeciesData(
    name: l.mpumbuName, emoji: '🐡',
    color: const Color(0xFF534AB7),
    localNames: const ['Mpumbu', 'Mupumbu'],
    habitat: l.mpumbuHabitat,
    season: l.mpumbuSeason,
    priceRange: l.mpumbuPriceRange,
    description: l.mpumbuDescription,
    freshIndicators: l.mpumbuFreshIndicators,
    spoilageWarning: l.mpumbuSpoilageWarning,
    cookingTip: l.mpumbuCookingTip,
  ),
  _SpeciesData(
    name: l.chessaName, emoji: '🐟',
    color: const Color(0xFF3B6D11),
    localNames: const ['Chessa', 'Lisabi', 'Chisense'],
    habitat: l.chessaHabitat,
    season: l.chessaSeason,
    priceRange: l.chessaPriceRange,
    description: l.chessaDescription,
    freshIndicators: l.chessaFreshIndicators,
    spoilageWarning: l.chessaSpoilageWarning,
    cookingTip: l.chessaCookingTip,
  ),
  _SpeciesData(
    name: l.vunduName, emoji: '🐟',
    color: const Color(0xFF5F5E5A),
    localNames: const ['Vundu', 'Mamba', 'Kampoyo', 'Pale'],
    habitat: l.vunduHabitat,
    season: l.vunduSeason,
    priceRange: l.vunduPriceRange,
    description: l.vunduDescription,
    freshIndicators: l.vunduFreshIndicators,
    spoilageWarning: l.vunduSpoilageWarning,
    cookingTip: l.vunduCookingTip,
  ),
];

class _SpeciesScreenState extends State<SpeciesScreen> {
  String _search = '';
  late List<_SpeciesData> _allSpecies;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _allSpecies = _buildSpecies(AppLocalizations.of(context)!);
  }

  List<_SpeciesData> get _filtered => _allSpecies.where((s) {
    if (_search.isEmpty) return true;
    final q = _search.toLowerCase();
    return s.name.toLowerCase().contains(q) ||
        s.localNames.any((n) => n.toLowerCase().contains(q));
  }).toList();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.speciesTitle)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: l.speciesSearch,
              hintStyle: const TextStyle(fontFamily: 'Poppins'),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() => _search = ''),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _SpeciesTile(species: _filtered[i])
                .animate(delay: Duration(milliseconds: i * 40))
                .fadeIn(duration: 250.ms)
                .slideY(begin: 0.05, end: 0),
          ),
        ),
      ]),
    );
  }
}

class _SpeciesTile extends StatelessWidget {
  final _SpeciesData species;
  const _SpeciesTile({required this.species});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => _SpeciesSheet(species: species),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: species.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(species.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(species.name, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(species.localNames.join(' · '),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.place_rounded, size: 11,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                const SizedBox(width: 3),
                Expanded(child: Text(species.habitat,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(species.priceRange.split('·').first.trim(),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                    fontWeight: FontWeight.w600, color: species.color)),
            const SizedBox(height: 4),
            Icon(Icons.chevron_right_rounded, size: 18,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
          ]),
        ]),
      ),
    );
  }
}

class _SpeciesSheet extends StatelessWidget {
  final _SpeciesData species;
  const _SpeciesSheet({required this.species});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: ListView(controller: ctrl, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          Row(children: [
            Container(width: 60, height: 60,
              decoration: BoxDecoration(
                  color: species.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(species.emoji,
                  style: const TextStyle(fontSize: 32)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(species.name, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700)),
              Text(species.localNames.join(' · '),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
            ])),
          ]),
          const SizedBox(height: 20),

          Text(species.description,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.6)),
          const SizedBox(height: 20),

          _FactRow(icon: Icons.water_rounded, label: l.speciesHabitat, value: species.habitat, color: species.color),
          _FactRow(icon: Icons.calendar_today_rounded, label: l.speciesBestSeason, value: species.season, color: species.color),
          _FactRow(icon: Icons.sell_rounded, label: l.speciesMarketPrice, value: species.priceRange, color: species.color),
          const SizedBox(height: 20),

          _InfoSection(
            icon: Icons.check_circle_rounded,
            title: l.speciesSignsOfFreshness,
            text: species.freshIndicators,
            bgColor: AppColors.freshSurface,
            textColor: AppColors.primaryDark,
            iconColor: AppColors.fresh,
          ),
          const SizedBox(height: 10),

          _InfoSection(
            icon: Icons.warning_rounded,
            title: l.speciesSpoilageWarning,
            text: species.spoilageWarning,
            bgColor: AppColors.poorSurface,
            textColor: AppColors.poor,
            iconColor: AppColors.poor,
          ),
          const SizedBox(height: 10),

          _InfoSection(
            icon: Icons.restaurant_rounded,
            title: l.speciesCookingTip,
            text: species.cookingTip,
            bgColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
            textColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            iconColor: AppColors.accent,
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _FactRow({required this.icon, required this.label,
      required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
          color: AppColors.textSecondary)),
      Expanded(child: Text(value, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color bgColor;
  final Color textColor;
  final Color iconColor;
  const _InfoSection({required this.icon, required this.title,
      required this.text, required this.bgColor,
      required this.textColor, required this.iconColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 7),
        Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
            fontWeight: FontWeight.w600, color: textColor)),
      ]),
      const SizedBox(height: 8),
      Text(text, style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
          height: 1.5, color: textColor)),
    ]),
  );
}
