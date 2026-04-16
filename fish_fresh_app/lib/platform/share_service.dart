import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/freshness_result.dart';

class PlatformShareService {
  /// Share a freshness result. On mobile this uses the native share sheet.
  /// On web/desktop it copies a summary to the clipboard.
  static Future<void> shareResult(BuildContext context, FreshnessResult result) async {
    final text = _buildShareText(result);

    final canShare = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (canShare) {
      await Share.share(text, subject: 'FishCheck ZM — ${result.fishType} result');
    } else {
      // Web / Windows: copy to clipboard and show a snackbar
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Result copied to clipboard'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  static String _buildShareText(FreshnessResult result) {
    return '''
🐟 FishCheck ZM — Freshness Report
━━━━━━━━━━━━━━━━━━━━
Species:   ${result.fishType}
Freshness: ${result.freshnessLabel}  (${result.score}%)
Sell by:   ${result.sellBy}
Safe:      ${result.safeToEat ? 'Yes ✓' : 'No — avoid'}

Eyes:      ${result.eyes}
Skin:      ${result.skin}
Gills:     ${result.gills}
Odour:     ${result.odourGuess}

Advice: ${result.advice}

Analysed with FishCheck ZM — AI fish freshness checker
''';
  }
}
