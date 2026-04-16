import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_colors.dart';

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

const _allSpecies = [
  _SpeciesData(
    name: 'Kapenta', emoji: '🐟',
    color: Color(0xFF185FA5),
    localNames: ['Kapenta', 'Ndakala', 'Matemba'],
    habitat: 'Lakes Tanganyika & Kariba',
    season: 'Year-round',
    priceRange: 'ZMW 20–60/kg (fresh) · ZMW 80–150/kg (dried)',
    description: 'Tiny freshwater sardines — the most commercially important fish in Zambia. '
        'Sold fresh or sun-dried. Dried kapenta is a staple across all provinces.',
    freshIndicators: 'Fresh kapenta: silver sheen, clear eyes, mild sea smell. '
        'Dried kapenta: uniform light-brown colour, dry to touch, no mould, mild smell.',
    spoilageWarning: 'Yellowish colour, strong fishy odour, or stickiness on fresh kapenta means it is no longer safe. '
        'Dried kapenta with dark patches or visible mould should be discarded.',
    cookingTip: 'Best fried crispy with onions and tomatoes, or simmered in groundnut relish (nshima accompaniment).',
  ),
  _SpeciesData(
    name: 'Bream (Tilapia)', emoji: '🐠',
    color: Color(0xFF0A7B5C),
    localNames: ['Brim', 'Tilapia', 'Ngumbu', 'Chisense'],
    habitat: 'Most freshwater bodies',
    season: 'Year-round',
    priceRange: 'ZMW 35–100/kg',
    description: 'The most widely consumed fish in Zambia. Found in rivers, dams and lakes nationwide. '
        'Available in nearly every market, often sold live.',
    freshIndicators: 'Bright red or deep pink gills, clear bulging eyes, firm flesh that springs back when pressed, '
        'shiny silver-green skin with tight scales.',
    spoilageWarning: 'Brown or grey gills, sunken or cloudy eyes, soft mushy flesh, and strong sour smell '
        'are all clear signs of deterioration.',
    cookingTip: 'Excellent grilled whole with tomatoes and onions, or fried. Commonly used in Zambian relish.',
  ),
  _SpeciesData(
    name: 'Tiger fish', emoji: '🦷',
    color: Color(0xFF854F0B),
    localNames: ['Nkupi', 'Mupende', 'Mputi'],
    habitat: 'Zambezi River, Lake Kariba',
    season: 'Best Aug–Oct',
    priceRange: 'ZMW 60–140/kg',
    description: 'Fierce predatory fish from the Zambezi and Lake Kariba. Prized for its firm, '
        'white flesh. Popular with sport anglers and a delicacy at markets near Kariba.',
    freshIndicators: 'Distinctive silver body with black tiger stripes. Bright eyes, firm white flesh, '
        'and a mild fresh smell. Teeth remain prominent and jaw is well-defined.',
    spoilageWarning: 'Fading stripes, dull discoloured skin, loose scales and a strong ammonia-like smell '
        'indicate the fish is past its best.',
    cookingTip: 'Best grilled or baked whole with lemon and herbs. The firm flesh holds well on a braai.',
  ),
  _SpeciesData(
    name: 'Mpumbu', emoji: '🐡',
    color: Color(0xFF534AB7),
    localNames: ['Mpumbu', 'Mupumbu'],
    habitat: 'Lake Bangweulu',
    season: 'Jun–Oct',
    priceRange: 'ZMW 50–120/kg',
    description: 'A prized, large lake fish endemic to Lake Bangweulu. Highly valued by local communities '
        'and often dried or smoked. Scarcity makes it relatively expensive.',
    freshIndicators: 'Deep silver body with prominent scales. Clear eyes, bright red-pink gills, and '
        'firm iridescent flesh. Fresh specimens have almost no smell.',
    spoilageWarning: 'Any discolouration of the flesh from white to yellowish, combined with a sour or '
        'strong fishy odour, indicates spoilage.',
    cookingTip: 'Wonderful smoked or grilled. The flavour is rich — pairs well with simple seasoning to let the fish shine.',
  ),
  _SpeciesData(
    name: 'Chessa', emoji: '🐟',
    color: Color(0xFF3B6D11),
    localNames: ['Chessa', 'Lisabi', 'Chisense'],
    habitat: 'Lakes Bangweulu & Mweru',
    season: 'Year-round',
    priceRange: 'ZMW 25–70/kg',
    description: 'A medium-sized lake fish common in Lake Bangweulu and Lake Mweru. '
        'Often sold dried in bulk. An important protein source in Northern and Luapula provinces.',
    freshIndicators: 'Silvery skin with firm texture. Clear eyes and tight intact scales. '
        'Fresh smell with no sourness. Dried chessa should be golden-brown and dry throughout.',
    spoilageWarning: 'Soft spots on the flesh, visible slime on the skin, cloudy eyes, '
        'or an ammonia-like odour are all signs to avoid.',
    cookingTip: 'Usually fried or dried and powdered as a flavouring. Works well in stews and nshima relish.',
  ),
  _SpeciesData(
    name: 'Vundu (Catfish)', emoji: '🐟',
    color: Color(0xFF5F5E5A),
    localNames: ['Vundu', 'Mamba', 'Kampoyo', 'Pale'],
    habitat: 'Zambezi River & major rivers',
    season: 'Year-round',
    priceRange: 'ZMW 40–100/kg',
    description: 'Large freshwater catfish found in the Zambezi and Kafue rivers. Can grow very large — '
        'up to 50kg. Has no scales. Excellent firm white flesh, popular for smoking.',
    freshIndicators: 'Moist, slightly slimy skin (normal for catfish). Firm pale flesh, '
        'clear eyes, and mild fresh smell with no sourness.',
    spoilageWarning: 'Excessive stickiness, yellowing of the flesh, strong ammonia smell, '
        'or visibly soft flesh are warning signs.',
    cookingTip: 'Superb smoked, grilled in large cuts, or curried. The thick flesh is very forgiving to cook.',
  ),
];

class _SpeciesScreenState extends State<SpeciesScreen> {
  String _search = '';

  List<_SpeciesData> get _filtered => _allSpecies.where((s) {
    if (_search.isEmpty) return true;
    final q = _search.toLowerCase();
    return s.name.toLowerCase().contains(q) ||
        s.localNames.any((n) => n.toLowerCase().contains(q));
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fish directory')),
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search species or local name...',
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
        // List
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
          // Coloured emoji container
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: ListView(controller: ctrl, children: [
          // Handle
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          // Header
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

          // Description
          Text(species.description,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.6)),
          const SizedBox(height: 20),

          // Quick facts
          _FactRow(icon: Icons.water_rounded, label: 'Habitat', value: species.habitat, color: species.color),
          _FactRow(icon: Icons.calendar_today_rounded, label: 'Best season', value: species.season, color: species.color),
          _FactRow(icon: Icons.sell_rounded, label: 'Market price', value: species.priceRange, color: species.color),
          const SizedBox(height: 20),

          // Freshness indicators
          _InfoSection(
            icon: Icons.check_circle_rounded,
            title: 'Signs of freshness',
            text: species.freshIndicators,
            bgColor: AppColors.freshSurface,
            textColor: AppColors.primaryDark,
            iconColor: AppColors.fresh,
          ),
          const SizedBox(height: 10),

          // Spoilage warning
          _InfoSection(
            icon: Icons.warning_rounded,
            title: 'Spoilage warning signs',
            text: species.spoilageWarning,
            bgColor: AppColors.poorSurface,
            textColor: AppColors.poor,
            iconColor: AppColors.poor,
          ),
          const SizedBox(height: 10),

          // Cooking tip
          _InfoSection(
            icon: Icons.restaurant_rounded,
            title: 'Cooking tip',
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
      Text('$label: ', style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
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
