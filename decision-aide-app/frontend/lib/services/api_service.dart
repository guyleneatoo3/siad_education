import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<http.Response> put(String chemin, Map<String, dynamic> data) async {
    final jeton = await lireJeton();
    final url = Uri.parse('$baseUrl$chemin');
    return http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (jeton != null && jeton.isNotEmpty) 'Authorization': 'Bearer $jeton',
      },
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(String chemin) async {
    final jeton = await lireJeton();
    final url = Uri.parse('$baseUrl$chemin');
    return http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (jeton != null && jeton.isNotEmpty) 'Authorization': 'Bearer $jeton',
      },
    );
  }

  static const String baseUrl = 'http://localhost:8080';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'jeton';

  Future<void> enregistrerJeton(String jeton) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, jeton);
    } else {
      await _secureStorage.write(key: _tokenKey, value: jeton);
    }
  }

  Future<String?> lireJeton() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } else {
      return _secureStorage.read(key: _tokenKey);
    }
  }

  Future<Map<String, dynamic>?> profilActuel() async {
    // Utilise le nouvel endpoint qui retourne etablissementId
    final res = await get('/api/utilisateurs/profil');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> connexion(
    String identifiant,
    String motDePasse,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/connexion');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifiant': identifiant, 'motDePasse': motDePasse}),
    );
    if (res.statusCode == 200) {
      print("utilisateut existant ");
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final jeton = body['jeton'] as String?;
      if (jeton != null && jeton.isNotEmpty) {
        await enregistrerJeton(jeton);
      }
      return body;
    }
    print("utilisateut inexistant ");
    return null;
  }

  Future<http.Response> get(String chemin) async {
    final jeton = await lireJeton();
    final url = Uri.parse('$baseUrl$chemin');
    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (jeton != null && jeton.isNotEmpty) 'Authorization': 'Bearer $jeton',
      },
    );
  }

  Future<http.Response> post(String chemin, Map<String, dynamic> data) async {
    final jeton = await lireJeton();
    final url = Uri.parse('$baseUrl$chemin');
    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (jeton != null && jeton.isNotEmpty) 'Authorization': 'Bearer $jeton',
      },
      body: jsonEncode(data),
    );
  }
}
