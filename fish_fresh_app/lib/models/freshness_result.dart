import 'dart:convert';
import 'dart:typed_data';

enum FreshnessLevel { fresh, acceptable, poor, spoiled, unknown }

class FreshnessResult {
  final FreshnessLevel freshness;
  final int score;
  final String fishType;
  final int confidence;       // 0-100: how confident the AI is in species ID
  final String eyes;
  final String skin;
  final String gills;
  final String flesh;         // New: flesh firmness
  final String odourGuess;
  final bool safeToEat;
  final String advice;
  final String sellBy;
  final String storageTip;    // New: how to store this fish
  final String priceImpact;   // New: recommended price adjustment
  final DateTime analysedAt;
  final String id;
  final Uint8List? imageBytes;
  final bool isPending;       // New: true when queued offline, not yet analysed

  const FreshnessResult({
    required this.freshness,
    required this.score,
    required this.fishType,
    this.confidence = 0,
    required this.eyes,
    required this.skin,
    required this.gills,
    this.flesh = '—',
    required this.odourGuess,
    required this.safeToEat,
    required this.advice,
    required this.sellBy,
    this.storageTip = '',
    this.priceImpact = '',
    required this.analysedAt,
    required this.id,
    this.imageBytes,
    this.isPending = false,
  });

  factory FreshnessResult.fromJson(
    Map<String, dynamic> json, {
    required String id,
    Uint8List? imageBytes,
  }) {
    FreshnessLevel level;
    final raw = (json['freshness'] ?? '').toString().toLowerCase();
    if (raw == 'fresh') level = FreshnessLevel.fresh;
    else if (raw == 'acceptable') level = FreshnessLevel.acceptable;
    else if (raw == 'poor') level = FreshnessLevel.poor;
    else if (raw == 'spoiled') level = FreshnessLevel.spoiled;
    else level = FreshnessLevel.unknown;

    return FreshnessResult(
      freshness: level,
      score: (json['score'] as num?)?.toInt() ?? 0,
      fishType: json['fish_type'] ?? 'Unknown fish',
      confidence: (json['confidence'] as num?)?.toInt() ?? 0,
      eyes: json['eyes'] ?? '—',
      skin: json['skin'] ?? '—',
      gills: json['gills'] ?? '—',
      flesh: json['flesh'] ?? '—',
      odourGuess: json['odour_guess'] ?? '—',
      safeToEat: json['safe_to_eat'] == true,
      advice: json['advice'] ?? '',
      sellBy: json['sell_by'] ?? '—',
      storageTip: json['storage_tip'] ?? '',
      priceImpact: json['price_impact'] ?? '',
      analysedAt: DateTime.now(),
      id: id,
      imageBytes: imageBytes,
    );
  }

  /// Create a pending (offline-queued) result placeholder
  factory FreshnessResult.pending({
    required String id,
    required Uint8List imageBytes,
  }) => FreshnessResult(
    freshness: FreshnessLevel.unknown,
    score: 0,
    fishType: 'Pending analysis...',
    eyes: '—', skin: '—', gills: '—', odourGuess: '—',
    safeToEat: false,
    advice: 'This scan is queued and will be analysed when internet is available.',
    sellBy: '—',
    analysedAt: DateTime.now(),
    id: id,
    imageBytes: imageBytes,
    isPending: true,
  );

  Map<String, dynamic> toStorageMap() => {
    'freshness': freshness.name,
    'score': score,
    'fishType': fishType,
    'confidence': confidence,
    'eyes': eyes,
    'skin': skin,
    'gills': gills,
    'flesh': flesh,
    'odourGuess': odourGuess,
    'safeToEat': safeToEat,
    'advice': advice,
    'sellBy': sellBy,
    'storageTip': storageTip,
    'priceImpact': priceImpact,
    'analysedAt': analysedAt.toIso8601String(),
    'id': id,
    'isPending': isPending,
    'imageB64': (imageBytes != null && imageBytes!.length <= 200000)
        ? base64Encode(imageBytes!)
        : null,
  };

  factory FreshnessResult.fromStorageMap(Map<String, dynamic> m) {
    FreshnessLevel level;
    switch (m['freshness']) {
      case 'fresh': level = FreshnessLevel.fresh; break;
      case 'acceptable': level = FreshnessLevel.acceptable; break;
      case 'poor': level = FreshnessLevel.poor; break;
      case 'spoiled': level = FreshnessLevel.spoiled; break;
      default: level = FreshnessLevel.unknown;
    }
    Uint8List? bytes;
    try {
      if (m['imageB64'] != null) bytes = base64Decode(m['imageB64'] as String);
    } catch (_) {}

    return FreshnessResult(
      freshness: level,
      score: m['score'] ?? 0,
      fishType: m['fishType'] ?? 'Unknown fish',
      confidence: m['confidence'] ?? 0,
      eyes: m['eyes'] ?? '—',
      skin: m['skin'] ?? '—',
      gills: m['gills'] ?? '—',
      flesh: m['flesh'] ?? '—',
      odourGuess: m['odourGuess'] ?? '—',
      safeToEat: m['safeToEat'] == true,
      advice: m['advice'] ?? '',
      sellBy: m['sellBy'] ?? '—',
      storageTip: m['storageTip'] ?? '',
      priceImpact: m['priceImpact'] ?? '',
      analysedAt: DateTime.tryParse(m['analysedAt'] ?? '') ?? DateTime.now(),
      id: m['id'] ?? '',
      imageBytes: bytes,
      isPending: m['isPending'] == true,
    );
  }

  FreshnessResult copyWith({
    FreshnessLevel? freshness,
    int? score,
    String? fishType,
    int? confidence,
    String? eyes,
    String? skin,
    String? gills,
    String? flesh,
    String? odourGuess,
    bool? safeToEat,
    String? advice,
    String? sellBy,
    String? storageTip,
    String? priceImpact,
    bool? isPending,
  }) => FreshnessResult(
    freshness: freshness ?? this.freshness,
    score: score ?? this.score,
    fishType: fishType ?? this.fishType,
    confidence: confidence ?? this.confidence,
    eyes: eyes ?? this.eyes,
    skin: skin ?? this.skin,
    gills: gills ?? this.gills,
    flesh: flesh ?? this.flesh,
    odourGuess: odourGuess ?? this.odourGuess,
    safeToEat: safeToEat ?? this.safeToEat,
    advice: advice ?? this.advice,
    sellBy: sellBy ?? this.sellBy,
    storageTip: storageTip ?? this.storageTip,
    priceImpact: priceImpact ?? this.priceImpact,
    analysedAt: analysedAt,
    id: id,
    imageBytes: imageBytes,
    isPending: isPending ?? this.isPending,
  );

  String get freshnessLabel {
    switch (freshness) {
      case FreshnessLevel.fresh: return 'Fresh';
      case FreshnessLevel.acceptable: return 'Acceptable';
      case FreshnessLevel.poor: return 'Poor';
      case FreshnessLevel.spoiled: return 'Spoiled';
      case FreshnessLevel.unknown: return isPending ? 'Pending' : 'Unknown';
    }
  }
}
