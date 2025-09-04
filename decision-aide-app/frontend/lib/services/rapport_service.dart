import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/rapport.dart';

class RapportService {
  final ApiService _api = ApiService();

  Future<List<RapportAnalyseModele>> lister() async {
    final http.Response res = await _api.get('/api/rapports');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => RapportAnalyseModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> creer(RapportAnalyseModele rapport) async {
    final http.Response res = await _api.post('/api/rapports', {
      'titre': rapport.titre,
      'contenu': rapport.contenu,
    });
    return res.statusCode == 200;
  }
}
