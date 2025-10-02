import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class CommentService {
  final ApiService _api = ApiService();

  Future<bool> envoyerCommentaireEtablissement(
      int etabId, String commentaire) async {
    final res = await _api.post(
      '/api/inspection/commentaire',
      {
        'etablissementId': etabId,
        'commentaire': commentaire,
      },
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> envoyerCommentaireInspection(
      int rapportId, String commentaire) async {
    final res = await _api.post(
      '/api/ministere/commentaire',
      {
        'rapportId': rapportId,
        'commentaire': commentaire,
      },
    );
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> listerCommentairesEtablissement(
      int etabId) async {
    final res = await _api.get('/api/inspection/commentaires/$etabId');
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> listerCommentairesInspection(
      int rapportId) async {
    final res = await _api.get('/api/ministere/commentaires/$rapportId');
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    return [];
  }
}
