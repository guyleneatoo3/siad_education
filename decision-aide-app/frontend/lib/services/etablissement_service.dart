import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/etablissement.dart';

class EtablissementService {
  final ApiService _api = ApiService();

  Future<List<EtablissementModele>> lister() async {
    final http.Response res = await _api.get('/api/etablissements');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => EtablissementModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> activer(int id, bool actif) async {
    final http.Response res = await _api.post('/api/etablissements/$id/activation', {'actif': actif});
    return res.statusCode == 200;
  }
}
