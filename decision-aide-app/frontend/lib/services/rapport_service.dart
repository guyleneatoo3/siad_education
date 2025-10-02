import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/rapport.dart';

class RapportService {
  Future<List<Map<String, dynamic>>> listerAvis(
      int rapportId, String type) async {
    final http.Response res =
        await _api.get('/api/avis/rapport/$rapportId/type/$type');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<bool> ajouterAvis({
    required int rapportId,
    required String contenu,
    required String auteurNom,
    required String type,
  }) async {
    final http.Response res = await _api.post(
      '/api/avis',
      {
        'rapportId': rapportId,
        'contenu': contenu,
        'auteurNom': auteurNom,
        'type': type,
      },
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

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

  Future<List<Map<String, dynamic>>> listerCommentairesEtablissements(
      int rapportId) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<bool> envoyerCommentaireAuMinistere(int rapportId, String contenu,
      {String auteurNom = "INSPECTION",
      String type = "INSPECTION_TO_MINISTERE"}) async {
    final http.Response res = await _api.post(
      '/api/avis',
      {
        'rapportId': rapportId,
        'contenu': contenu,
        'auteurNom': auteurNom,
        'type': type,
      },
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> listerCommentairesInspection(
      int rapportId) async {
    // TODO: Implement actual API call
    return [];
  }
}
