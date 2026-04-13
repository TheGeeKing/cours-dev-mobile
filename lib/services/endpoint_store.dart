import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EndpointStore {
  static const _crudCrudPageUrl = 'https://crudcrud.com/';
  static const _endpointKey = 'crudcrud_endpoint';
  static const _savedAtEpochMsKey = 'crudcrud_endpoint_saved_at';
  static const _ttl = Duration(hours: 24);

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final endpoint = prefs.getString(_endpointKey);
    final savedAtEpochMs = prefs.getInt(_savedAtEpochMsKey);

    if (endpoint == null || savedAtEpochMs == null) {
      return refreshEndpointFromCrudCrudPage();
    }

    final savedAt = DateTime.fromMillisecondsSinceEpoch(savedAtEpochMs);
    final isExpired = DateTime.now().difference(savedAt) >= _ttl;
    if (isExpired) {
      return refreshEndpointFromCrudCrudPage();
    }

    return endpoint;
  }

  Future<String> refreshEndpointFromCrudCrudPage() async {
    final res = await http.get(Uri.parse(_crudCrudPageUrl));
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load CrudCrud page — HTTP ${res.statusCode}: ${res.body}',
      );
    }

    final endpoint = _extractEndpointUrl(res.body);
    if (endpoint == null) {
      throw Exception('Failed to extract endpoint URL from CrudCrud page.');
    }

    await saveBaseUrl(endpoint);
    return endpoint;
  }

  Future<void> saveBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_endpointKey, baseUrl);
    await prefs.setInt(
      _savedAtEpochMsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  String? _extractEndpointUrl(String html) {
    final endpointDivPattern = RegExp(
      r'class="endpoint-url"[^>]*>\s*(https://crudcrud\.com/api/[a-zA-Z0-9]+)\s*<',
      caseSensitive: false,
    );
    final endpointDivMatch = endpointDivPattern.firstMatch(html);
    if (endpointDivMatch != null) {
      return endpointDivMatch.group(1);
    }

    final fallbackPattern = RegExp(
      r'https://crudcrud\.com/api/[a-zA-Z0-9]+',
      caseSensitive: false,
    );
    return fallbackPattern.firstMatch(html)?.group(0);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_endpointKey);
    await prefs.remove(_savedAtEpochMsKey);
  }

  Future<String?> debugDump() async {
    final prefs = await SharedPreferences.getInstance();
    final endpoint = prefs.getString(_endpointKey);
    final savedAtEpochMs = prefs.getInt(_savedAtEpochMsKey);
    return jsonEncode({
      'endpoint': endpoint,
      'savedAtEpochMs': savedAtEpochMs,
    });
  }
}
