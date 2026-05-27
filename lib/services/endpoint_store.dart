import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EndpointStore {
  static const _createEndpointUrl = 'https://tinycrud.dev/api/endpoints';
  static const _headers = {'Content-Type': 'application/json'};
  static const _endpointKey = 'tinycrud_endpoint';
  static const _endpointIdKey = 'tinycrud_endpoint_id';
  static const _endpointVisibilityKey = 'tinycrud_endpoint_visibility';
  static const _endpointExpiresAtKey = 'tinycrud_endpoint_expires_at';
  static const _endpointLimitsKey = 'tinycrud_endpoint_limits';
  static const _savedAtEpochMsKey = 'tinycrud_endpoint_saved_at';
  static const _legacyEndpointKey = 'crudcrud_endpoint';
  static const _legacySavedAtEpochMsKey = 'crudcrud_endpoint_saved_at';

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final endpoint = prefs.getString(_endpointKey);
    final expiresAt = prefs.getString(_endpointExpiresAtKey);

    if (endpoint == null || _hasExpired(expiresAt)) {
      return refreshEndpoint();
    }

    return endpoint;
  }

  Future<String> refreshEndpoint() async {
    final res = await http.post(
      Uri.parse(_createEndpointUrl),
      headers: _headers,
      body: jsonEncode({'visibility': 'public'}),
    );
    if (res.statusCode != 201) {
      throw Exception(
        'Échec de la création du point d\'accès TinyCRUD — HTTP ${res.statusCode}: ${res.body}',
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final baseUrl = json['baseUrl'] as String?;
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception(
        'La réponse du point d\'accès TinyCRUD ne contient pas de baseUrl.',
      );
    }

    await _saveEndpoint(json);
    return baseUrl;
  }

  bool _hasExpired(String? expiresAt) {
    if (expiresAt == null) return false;

    final expiry = DateTime.tryParse(expiresAt);
    if (expiry == null) return false;

    return !DateTime.now().toUtc().isBefore(expiry);
  }

  Future<void> saveBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_endpointKey, baseUrl);
    await prefs.setInt(
      _savedAtEpochMsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.remove(_legacyEndpointKey);
    await prefs.remove(_legacySavedAtEpochMsKey);
  }

  Future<void> _saveEndpoint(Map<String, dynamic> endpoint) async {
    await saveBaseUrl(endpoint['baseUrl'] as String);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_endpointIdKey, endpoint['endpointId'] as String);
    await prefs.setString(
      _endpointVisibilityKey,
      endpoint['visibility'] as String,
    );
    await prefs.setString(
      _endpointExpiresAtKey,
      endpoint['expiresAt'] as String,
    );
    await prefs.setString(_endpointLimitsKey, jsonEncode(endpoint['limits']));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_endpointKey);
    await prefs.remove(_endpointIdKey);
    await prefs.remove(_endpointVisibilityKey);
    await prefs.remove(_endpointExpiresAtKey);
    await prefs.remove(_endpointLimitsKey);
    await prefs.remove(_savedAtEpochMsKey);
    await prefs.remove(_legacyEndpointKey);
    await prefs.remove(_legacySavedAtEpochMsKey);
  }

  Future<String?> debugDump() async {
    final prefs = await SharedPreferences.getInstance();
    final endpoint = prefs.getString(_endpointKey);
    final savedAtEpochMs = prefs.getInt(_savedAtEpochMsKey);
    final limitsJson = prefs.getString(_endpointLimitsKey);

    return jsonEncode({
      'endpoint': endpoint,
      'endpointId': prefs.getString(_endpointIdKey),
      'visibility': prefs.getString(_endpointVisibilityKey),
      'expiresAt': prefs.getString(_endpointExpiresAtKey),
      'limits': limitsJson == null ? null : jsonDecode(limitsJson),
      'savedAtEpochMs': savedAtEpochMs,
    });
  }
}
