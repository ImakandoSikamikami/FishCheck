import 'dart:convert';

class Vendor {
  final String id;
  final String name;
  final String phone;
  final String whatsapp;
  final String marketName;
  final String city;
  final String province;
  final double? latitude;
  final double? longitude;
  final List<String> fishSpecies;
  final String? description;
  final bool isVerified;
  final DateTime createdAt;
  final double? averageRating;
  final int totalScans;

  Vendor({
    required this.id,
    required this.name,
    required this.phone,
    required this.whatsapp,
    required this.marketName,
    required this.city,
    required this.province,
    this.latitude,
    this.longitude,
    required this.fishSpecies,
    this.description,
    this.isVerified = false,
    required this.createdAt,
    this.averageRating,
    this.totalScans = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'whatsapp': whatsapp,
    'marketName': marketName,
    'city': city,
    'province': province,
    'latitude': latitude,
    'longitude': longitude,
    'fishSpecies': fishSpecies,
    'description': description,
    'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
    'averageRating': averageRating,
    'totalScans': totalScans,
  };

  factory Vendor.fromMap(Map<String, dynamic> m) => Vendor(
    id: m['id'] ?? '',
    name: m['name'] ?? '',
    phone: m['phone'] ?? '',
    whatsapp: m['whatsapp'] ?? '',
    marketName: m['marketName'] ?? '',
    city: m['city'] ?? '',
    province: m['province'] ?? '',
    latitude: (m['latitude'] as num?)?.toDouble(),
    longitude: (m['longitude'] as num?)?.toDouble(),
    fishSpecies: List<String>.from(m['fishSpecies'] ?? []),
    description: m['description'],
    isVerified: m['isVerified'] == true,
    createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
    averageRating: (m['averageRating'] as num?)?.toDouble(),
    totalScans: m['totalScans'] ?? 0,
  );

  Vendor copyWith({int? totalScans, double? averageRating}) => Vendor(
    id: id, name: name, phone: phone, whatsapp: whatsapp,
    marketName: marketName, city: city, province: province,
    latitude: latitude, longitude: longitude, fishSpecies: fishSpecies,
    description: description, isVerified: isVerified, createdAt: createdAt,
    averageRating: averageRating ?? this.averageRating,
    totalScans: totalScans ?? this.totalScans,
  );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'V';
  }

  String get locationLabel => '$marketName, $city';
  String get whatsappUrl => 'https://wa.me/${whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}';
}

// Sample seed data for Zambian markets
List<Vendor> get sampleVendors => [
  Vendor(
    id: 'v1', name: 'Chanda Mwale', phone: '+260977123456', whatsapp: '+260977123456',
    marketName: 'Soweto Market', city: 'Lusaka', province: 'Lusaka Province',
    latitude: -15.4167, longitude: 28.2833,
    fishSpecies: ['Kapenta', 'Bream', 'Tiger fish'],
    description: 'Fresh fish daily from Lake Kariba. Been selling for 12 years.',
    isVerified: true, createdAt: DateTime(2024, 1, 15), averageRating: 4.7, totalScans: 42,
  ),
  Vendor(
    id: 'v2', name: 'Mutale Banda', phone: '+260966234567', whatsapp: '+260966234567',
    marketName: 'City Market', city: 'Lusaka', province: 'Lusaka Province',
    latitude: -15.4200, longitude: 28.2780,
    fishSpecies: ['Bream', 'Mpumbu', 'Vundu'],
    description: 'Specialising in Lake Bangweulu fish. Wholesale and retail.',
    isVerified: true, createdAt: DateTime(2024, 2, 10), averageRating: 4.5, totalScans: 28,
  ),
  Vendor(
    id: 'v3', name: 'Bupe Phiri', phone: '+260955345678', whatsapp: '+260955345678',
    marketName: 'Luburma Market', city: 'Lusaka', province: 'Lusaka Province',
    latitude: -15.4100, longitude: 28.3100,
    fishSpecies: ['Kapenta', 'Chessa'],
    description: 'Dried and fresh kapenta specialist. Lake Tanganyika source.',
    isVerified: false, createdAt: DateTime(2024, 3, 5), averageRating: 4.2, totalScans: 15,
  ),
  Vendor(
    id: 'v4', name: 'Namukolo Simu', phone: '+260977456789', whatsapp: '+260977456789',
    marketName: 'Kamwala Market', city: 'Lusaka', province: 'Lusaka Province',
    latitude: -15.4250, longitude: 28.2900,
    fishSpecies: ['Bream', 'Tiger fish', 'Mpumbu'],
    description: 'Fresh catch every Tuesday and Friday. Best bream in Lusaka.',
    isVerified: true, createdAt: DateTime(2024, 1, 28), averageRating: 4.8, totalScans: 61,
  ),
  Vendor(
    id: 'v5', name: 'Kelvin Mulenga', phone: '+260966567890', whatsapp: '+260966567890',
    marketName: 'Masala Market', city: 'Ndola', province: 'Copperbelt Province',
    latitude: -12.9667, longitude: 28.6333,
    fishSpecies: ['Kapenta', 'Bream', 'Chessa'],
    description: 'Copperbelt distributor. Bulk orders welcome.',
    isVerified: false, createdAt: DateTime(2024, 4, 1), averageRating: 4.1, totalScans: 19,
  ),
];
