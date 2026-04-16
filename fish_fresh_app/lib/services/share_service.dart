import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/freshness_result.dart';
import '../models/vendor.dart';

class ShareService {
  /// Share a result as a plain text summary via any app (WhatsApp, SMS, etc.)
  static Future<void> shareResult(FreshnessResult result, {Vendor? vendor}) async {
    final emoji = _emoji(result.freshness);
    final lines = [
      '$emoji *FishCheck ZM — Freshness Report*',
      '',
      '🐟 *Fish:* ${result.fishType}',
      '📊 *Freshness:* ${result.freshnessLabel} (${result.score}%)',
      '🗓️ *Sell by:* ${result.sellBy}',
      '✅ *Safe to eat:* ${result.safeToEat ? "Yes" : "No — avoid"}',
      '',
      '👁️ Eyes: ${result.eyes}',
      '🐠 Skin: ${result.skin}',
      '🩸 Gills: ${result.gills}',
      '',
      '💡 ${result.advice}',
    ];
    if (vendor != null) {
      lines.addAll([
        '',
        '🏪 *Vendor:* ${vendor.name}',
        '📍 ${vendor.locationLabel}',
        '📞 ${vendor.phone}',
      ]);
    }
    lines.addAll(['', '_Analysed by FishCheck ZM_']);

    await Share.share(lines.join('\n'), subject: 'Fish freshness: ${result.fishType}');
  }

  /// Open WhatsApp directly with a pre-filled message to a vendor
  static Future<void> contactVendorWhatsApp(Vendor vendor, {String? message}) async {
    final text = message ?? 'Hello ${vendor.name}, I found you on FishCheck ZM. Are you open today?';
    final encoded = Uri.encodeComponent(text);
    final number = vendor.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$number?text=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Open phone dialler
  static Future<void> callVendor(Vendor vendor) async {
    final url = Uri.parse('tel:${vendor.phone}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  /// Open maps to vendor location
  static Future<void> openMap(Vendor vendor) async {
    if (vendor.latitude == null || vendor.longitude == null) return;
    final url = Uri.parse(
      'https://maps.google.com/?q=${vendor.latitude},${vendor.longitude}&label=${Uri.encodeComponent(vendor.marketName)}'
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static String _emoji(FreshnessLevel level) {
    switch (level) {
      case FreshnessLevel.fresh: return '🟢';
      case FreshnessLevel.acceptable: return '🟡';
      case FreshnessLevel.poor: return '🟠';
      case FreshnessLevel.spoiled: return '🔴';
      case FreshnessLevel.unknown: return '⚪';
    }
  }
}
