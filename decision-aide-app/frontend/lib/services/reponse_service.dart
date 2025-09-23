import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/reponse.dart';

class ReponseService {
  final ApiService _api = ApiService();

  Future<List<ReponseQuestionnaireModele>> lister() async {
    final http.Response res = await _api.get('/api/reponses');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      
      return data
          .map((e) =>
              ReponseQuestionnaireModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    print('Erreur lors de la récupération des réponses: ${res.statusCode}');
    return [];
  }

  Future<bool> enregistrer(ReponseQuestionnaireModele reponse) async {
    final http.Response res = await _api.post('/api/reponses', {
      'id': reponse.id,
      'questionnaireId': reponse.questionnaireId,
      'reponsesJson': reponse.reponsesJson,
      if (reponse.utilisateurNom != null)
        'utilisateurNom': reponse.utilisateurNom,
      if (reponse.dateSoumission != null)
        'dateSoumission': reponse.dateSoumission!.toIso8601String(),
    });
    return res.statusCode == 200;
  }
}
