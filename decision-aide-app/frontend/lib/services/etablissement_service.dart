import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/etablissement.dart';
import '../modeles/utilisateur.dart';

class EtablissementService {
  // Lister tous les élèves de l'établissement
  Future<List<UtilisateurModele>> listerEleves(int etabId) async {
    final http.Response res =
        await _api.get('/api/etablissements/$etabId/eleves');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => UtilisateurModele.fromJson(e)).toList();
    }
    return [];
  }

  // Lister tous les enseignants de l'établissement
  Future<List<UtilisateurModele>> listerEnseignants(int etabId) async {
    final http.Response res =
        await _api.get('/api/etablissements/$etabId/enseignants');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => UtilisateurModele.fromJson(e)).toList();
    }
    return [];
  }

  // Ajouter un élève
  Future<UtilisateurModele?> ajouterEleve(
      int etabId, UtilisateurModele eleve) async {
    final http.Response res =
        await _api.post('/api/etablissements/$etabId/eleves', eleve.toJson());
    if (res.statusCode == 201 || res.statusCode == 200) {
      return UtilisateurModele.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  // Modifier un élève
  Future<bool> modifierEleve(int etabId, UtilisateurModele eleve) async {
    final http.Response res = await _api.put(
        '/api/etablissements/$etabId/eleves/${eleve.id}', eleve.toJson());
    return res.statusCode == 200;
  }

  // Supprimer un élève
  Future<bool> supprimerEleve(int etabId, int id) async {
    final http.Response res =
        await _api.delete('/api/etablissements/$etabId/eleves/$id');
    return res.statusCode == 204 || res.statusCode == 200;
  }

  // Ajouter un enseignant
  Future<UtilisateurModele?> ajouterEnseignant(
      int etabId, UtilisateurModele enseignant) async {
    final http.Response res = await _api.post(
        '/api/etablissements/$etabId/enseignants', enseignant.toJson());
    if (res.statusCode == 201 || res.statusCode == 200) {
      return UtilisateurModele.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  // Modifier un enseignant
  Future<bool> modifierEnseignant(
      int etabId, UtilisateurModele enseignant) async {
    final http.Response res = await _api.put(
        '/api/etablissements/$etabId/enseignants/${enseignant.id}',
        enseignant.toJson());
    return res.statusCode == 200;
  }

  // Supprimer un enseignant
  Future<bool> supprimerEnseignant(int etabId, int id) async {
    final http.Response res =
        await _api.delete('/api/etablissements/$etabId/enseignants/$id');
    return res.statusCode == 204 || res.statusCode == 200;
  }

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
    final http.Response res =
        await _api.post('/api/etablissements/$id/activation', {'actif': actif});
    return res.statusCode == 200;
  }

// Vérifie si un email existe déjà
// (méthode déplacée ou renommée pour éviter la duplication)

  // Inscription d'un établissement avec vérification de l'existence de l'email
Future<bool> inscrireEtablissement(
    EtablissementModele etab, String motDePasse) async {
  // Vérification de l'existence de l'email
  final bool existe = await emailExiste(etab.email);
  if (existe) {
    throw Exception("Un établissement avec cet email existe déjà.");
  }       

  // Appel direct sans jeton pour l'inscription publique
  final url =
      Uri.parse('${ApiService.baseUrl}/api/etablissements/inscription');
  final res = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      ...etab.toJson(),
      'motDePasse': motDePasse,
    }),
  );

  if (res.statusCode == 201 || res.statusCode == 200) {
    return true;
  } else {
    try {
      final body = res.body;
      String msg = 'Erreur inconnue (${res.statusCode})';
      if (body.isNotEmpty) {
        try {
          final decoded = body.startsWith('{') ? jsonDecode(body) : null;
          if (decoded != null &&
              decoded is Map &&
              decoded.containsKey('message')) {
            msg = decoded['message'].toString();
          } else {
            msg = body;
          }
        } catch (_) {
          msg = body;
        }
      }
      throw Exception(msg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

// Nouvelle méthode : vérifier si un email existe déjà
Future<bool> emailExiste(String email) async {
  final url = Uri.parse('${ApiService.baseUrl}/api/utilisateurs/email-existe?email=$email');
  final res = await http.get(url);

  if (res.statusCode == 200) {
    final body = jsonDecode(res.body);
    return body['existe'] == true;
  } else {
    throw Exception("Erreur lors de la vérification de l'email (${res.statusCode})");
  }
}
}