import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/freshness_result.dart';

/// Custom exceptions for better error handling in the UI
class NoApiKeyException implements Exception {
  const NoApiKeyException();
  @override
  String toString() => 'No API key set. Go to Settings to add your key.';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  @override
  String toString() => message;
}

class AnalysisException implements Exception {
  final String message;
  const AnalysisException(this.message);
  @override
  String toString() => message;
}

/// FishCheck ZM AI Analysis Service
class AiService {
  static const _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const _modelVersion = 'claude-sonnet-4-20250514';
  static const _apiVersion = '2023-06-01';
  static const _timeoutSeconds = 30;
  static const _maxRetries = 2;

  static Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fishcheck_api_key') ?? '';
  }

  // Rich prompt engineered for maximum accuracy on Zambian fish
  static const _prompt = '''
You are an expert fish quality inspector with deep knowledge of fish sold in Zambian markets.
Analyse this fish image carefully and return ONLY a valid JSON object with no markdown or backticks.

Identify the species using these Zambian common names where possible:
- Kapenta (Lake Tanganyika/Kariba sardines — tiny silver fish, often dried)
- Bream / Tilapia (flat oval silver-green fish, most common in Zambia)
- Tiger fish / Nkupi (silver with black stripes, long jaw with teeth)
- Mpumbu (deep silver oval fish from Lake Bangweulu)
- Chessa / Lisabi (silver lake fish, similar to bream)
- Vundu / Mamba (large catfish, grey-brown, no scales)
- Pale / Lusungu (large lake fish, silver-blue)

Assess freshness by examining:
- Eyes: clear/bright = fresh; cloudy/sunken = deteriorating
- Skin: shiny/metallic = fresh; dull/discoloured/slime = old
- Gills (if visible): bright red/pink = fresh; brown/grey = old
- Flesh firmness (if cross-section visible)
- Any visible signs of decay, unusual smell indicators, or discolouration

Return this exact JSON schema:
{
  "freshness": "Fresh" | "Acceptable" | "Poor" | "Spoiled",
  "score": <integer 0-100>,
  "fish_type": "<species name or Unknown fish>",
  "confidence": <integer 0-100 — how confident you are in the species ID>,
  "eyes": "<clear and bright | slightly cloudy | cloudy | sunken | not visible>",
  "skin": "<bright and shiny | slightly dull | dull | discoloured | not visible>",
  "gills": "<bright red | pink | pale | brown | grey | not visible>",
  "flesh": "<firm | slightly soft | soft | not visible>",
  "odour_guess": "<likely fresh | mild | developing | strong>",
  "safe_to_eat": true | false,
  "advice": "<one clear practical sentence for a Zambian vendor or consumer>",
  "sell_by": "<Sell today | Within 24 hours | Within 48 hours | Do not sell>",
  "storage_tip": "<one sentence on how to store this fish to maximise shelf life>",
  "price_impact": "<No discount needed | 10-20% discount | 30-50% discount | Remove from sale>"
}

If the image does not clearly show a fish, set fish_type to "No fish detected", score to 0, safe_to_eat to false.
''';

  /// Analyse image bytes with retry logic and proper error handling.
  static Future<FreshnessResult> analyseBytes(
    Uint8List bytes,
    String mediaType,
  ) async {
    final apiKey = await _getApiKey();
    if (apiKey.isEmpty) throw const NoApiKeyException();

    Exception? lastError;

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        return await _doRequest(bytes, mediaType, apiKey);
      } on TimeoutException {
        lastError = const NetworkException(
            'Request timed out. Check your internet connection.');
        // Don't retry on timeout — likely a connectivity issue
        break;
      } on http.ClientException catch (e) {
        lastError = NetworkException('Network error: ${e.message}');
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
      } on FormatException {
        lastError = const AnalysisException(
            'Could not read the analysis response. Please try again.');
        if (attempt < _maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
      } catch (e) {
        lastError = AnalysisException(e.toString().replaceFirst('Exception: ', ''));
        break;
      }
    }

    throw lastError ?? const AnalysisException('Analysis failed. Please try again.');
  }

  static Future<FreshnessResult> _doRequest(
    Uint8List bytes,
    String mediaType,
    String apiKey,
  ) async {
    final b64 = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': _apiVersion,
      },
      body: jsonEncode({
        'model': _modelVersion,
        'max_tokens': 800,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {'type': 'base64', 'media_type': mediaType, 'data': b64},
              },
              {'type': 'text', 'text': _prompt},
            ],
          },
        ],
      }),
    ).timeout(const Duration(seconds: _timeoutSeconds));

    if (response.statusCode == 401) {
      throw const NoApiKeyException();
    }
    if (response.statusCode == 429) {
      throw const NetworkException('Too many requests. Please wait a moment.');
    }
    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw AnalysisException(
          err['error']?['message'] ?? 'Server error (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final rawText =
        (data['content'] as List).map((b) => b['text'] ?? '').join('');
    final cleaned = rawText.replaceAll(RegExp(r'```json|```'), '').trim();

    Map<String, dynamic> resultJson;
    try {
      resultJson = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      // Try to extract JSON from within the response if it contains extra text
      final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(cleaned);
      if (match == null) throw const FormatException('No JSON found in response');
      resultJson = jsonDecode(match.group(0)!) as Map<String, dynamic>;
    }

    return FreshnessResult.fromJson(
      resultJson,
      id: const Uuid().v4(),
      imageBytes: bytes,
    );
  }
}
