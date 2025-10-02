import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/decision.dart';

class DecisionService {
  Future<bool> modifierDecision(
      int id, String titre, String contenu, bool publie) async {
    final http.Response res = await _api.put(
      '/api/decisions/$id',
      {
        'titre': titre,
        'contenu': contenu,
        'publie': publie,
      },
    );
    return res.statusCode == 200;
  }

  Future<bool> supprimerDecision(int id) async {
    final http.Response res = await _api.delete('/api/decisions/$id');
    return res.statusCode == 204 || res.statusCode == 200;
  }

  Future<bool> creerDecision(String titre, String contenu, bool publie) async {
    final http.Response res = await _api.post(
      '/api/decisions',
      {
        'titre': titre,
        'contenu': contenu,
        'publie': publie,
      },
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  final ApiService _api = ApiService();

  Future<List<DecisionModele>> lister() async {
    final http.Response res = await _api.get('/api/decisions');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => DecisionModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<DecisionModele>> listerPubliques() async {
    final url = Uri.parse('${ApiService.baseUrl}/api/public/decisions');
    final res =
        await http.get(url, headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => DecisionModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
