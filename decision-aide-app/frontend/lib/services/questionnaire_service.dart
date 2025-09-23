import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../modeles/questionnaire.dart';
import '../modeles/utilisateur.dart';

class QuestionnaireService {
  /// Liste les questionnaires créés par l'utilisateur connecté (inspecteur)
  Future<List<QuestionnaireModele>> listerParCreateur() async {
    final http.Response res =
        await _api.get('/api/inspection/mes-questionnaires');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => QuestionnaireModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Liste les questionnaires créés par l'utilisateur connecté filtrés par destinataire ("ELEVE" ou "ENSEIGNANT")
  Future<List<QuestionnaireModele>> listerParCreateurEtDestinataire(
      String destinataire) async {
    final http.Response res =
        await _api.get('/api/inspection/mes-questionnaires/$destinataire');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => QuestionnaireModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

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
      'destinataire': questionnaire.destinataire,
      if (utilisateur != null) 'creePar': utilisateur,
    };
    final http.Response res = await _api.post(
      '/api/questionnaires',
      data,
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      final q = QuestionnaireModele.fromJson(jsonDecode(res.body));
      // Stocker l'ID dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_question', q.id);
      return q;
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

  Future<List<QuestionnaireModele>> listerFiltresParRole() async {
    final http.Response res = await _api.get('/api/questionnaires');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      final utilisateur = await profilActuel();
      String role = '';
      if (utilisateur != null) {
        role = utilisateur.role.toString().toUpperCase();
      }
      // On filtre selon le rôle : si ENSEIGNANT, on ne voit que les questionnaires destinés aux enseignants, etc.
      return data
          .map((e) => QuestionnaireModele.fromJson(e as Map<String, dynamic>))
          .where(
              (q) => q.destinataire.toUpperCase() == role && q.partage == true)
          .toList();
    }
    return [];
  }

  /// Partage un questionnaire (met à jour les champs partage et dateFinPartage)
  Future<bool> partager(int id, DateTime dateFinPartage) async {
    final http.Response res = await _api.patch(
      '/api/questionnaires/$id/partage',
      {
        'partage': true,
        'dateFinPartage': dateFinPartage.toIso8601String(),
      },
    );
    print("partage reponse: ${res.statusCode}");
    return res.statusCode == 200;
  }
}
