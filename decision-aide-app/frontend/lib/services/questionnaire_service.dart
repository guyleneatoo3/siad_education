import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/questionnaire.dart';
import '../modeles/utilisateur.dart';

class QuestionnaireService {
  /// Retourne l'utilisateur actuellement connecté (objet UtilisateurModele)
  Future<UtilisateurModele?> profilActuel() async {
    final utilisateurMap = await _api.profilActuel();
    if (utilisateurMap != null) {
      return UtilisateurModele.fromJson(utilisateurMap);
    }
    return null;
  }

  /// Crée un nouveau questionnaire
  Future<QuestionnaireModele?> creer(QuestionnaireModele questionnaire) async {
    // Récupérer l'utilisateur connecté
    final utilisateur = await _api.profilActuel();
    final Map<String, dynamic> data = {
      'titre': questionnaire.titre,
      'contenuJson': questionnaire.contenuJson,
      if (utilisateur != null) 'creePar': utilisateur,
    };
    final http.Response res = await _api.post(
      '/api/questionnaires',
      data,
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return QuestionnaireModele.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  /// Récupère un questionnaire par son identifiant
  Future<QuestionnaireModele?> lire(int id) async {
    final http.Response res = await _api.get('/api/questionnaires/$id');
    if (res.statusCode == 200) {
      return QuestionnaireModele.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  /// Met à jour un questionnaire existant
  Future<bool> mettreAJour(QuestionnaireModele questionnaire) async {
    final http.Response res = await _api.put(
      '/api/questionnaires/${questionnaire.id}',
      {
        'titre': questionnaire.titre,
        'contenuJson': questionnaire.contenuJson,
      },
    );
    return res.statusCode == 200;
  }

  /// Supprime un questionnaire par son identifiant
  Future<bool> supprimer(int id) async {
    final http.Response res = await _api.delete('/api/questionnaires/$id');
    return res.statusCode == 204 || res.statusCode == 200;
  }

  final ApiService _api = ApiService();

  Future<List<QuestionnaireModele>> lister() async {
    final http.Response res = await _api.get('/api/questionnaires');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => QuestionnaireModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
