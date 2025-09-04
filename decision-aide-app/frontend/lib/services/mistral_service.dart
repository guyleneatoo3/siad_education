import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/mistral_config.dart';

class MistralService {
  /// Génère des questions pour un questionnaire pédagogique
  static Future<Map<String, dynamic>> genererQuestions({
    required int nombre,
    required String type,
    String? niveau,
    String? matiere,
    String? destinataire, // 'eleve' ou 'enseignant'
  }) async {
    try {
      // Vérifier la configuration
      if (!MistralConfig.isConfigured) {
        return {
          'success': false,
          'error': MistralConfig.errorNotConfigured,
        };
      }

      final prompt = _construirePromptQuestions(
          nombre, type, niveau, matiere, destinataire);

      final response = await http.post(
        Uri.parse('${MistralConfig.baseUrl}${MistralConfig.chatEndpoint}'),
        headers: MistralConfig.defaultHeaders,
        body: jsonEncode({
          'model': MistralConfig.defaultModel,
          'messages': [
            {
              'role': 'system',
              'content': 'Tu es un expert en pédagogie et en évaluation éducative. '
                  'Tu génères des questions pertinentes et adaptées au niveau scolaire Camerounais du secondaire.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': MistralConfig.defaultTemperature,
          'max_tokens': MistralConfig.defaultMaxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['choices'][0]['message']['content'] as String;

        return {
          'success': true,
          'questions': content,
          'raw_response': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error':
              'Erreur 401: Clé API invalide ou expirée. Veuillez vérifier votre clé API Mistral.',
          'details': response.body,
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error':
              'Erreur 429: Limite de taux dépassée. Veuillez réessayer dans quelques minutes.',
          'details': response.body,
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur API: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Analyse les réponses d'un questionnaire
  static Future<Map<String, dynamic>> analyserReponses({
    required String reponsesJson,
    required String typeQuestionnaire,
    String? contexte,
  }) async {
    try {
      // Vérifier la configuration
      if (!MistralConfig.isConfigured) {
        return {
          'success': false,
          'error': MistralConfig.errorNotConfigured,
        };
      }

      final prompt =
          _construirePromptAnalyse(reponsesJson, typeQuestionnaire, contexte);

      final response = await http.post(
        Uri.parse('${MistralConfig.baseUrl}${MistralConfig.chatEndpoint}'),
        headers: MistralConfig.defaultHeaders,
        body: jsonEncode({
          'model': MistralConfig.defaultModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Tu es un expert en analyse pédagogique et en évaluation éducative. '
                      'Tu analyses les réponses des élèves/enseignants et génères des insights pertinents.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.5,
          'max_tokens': 3000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['choices'][0]['message']['content'] as String;

        return {
          'success': true,
          'analyse': content,
          'raw_response': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error':
              'Erreur 401: Clé API invalide ou expirée. Veuillez vérifier votre clé API Mistral.',
          'details': response.body,
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error':
              'Erreur 429: Limite de taux dépassée. Veuillez réessayer dans quelques minutes.',
          'details': response.body,
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur API: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Génère un rapport final combinant analyse et avis
  static Future<Map<String, dynamic>> genererRapportFinal({
    required String analyseReponses,
    required String avisInspection,
    String? titre,
  }) async {
    try {
      // Vérifier la configuration
      if (!MistralConfig.isConfigured) {
        return {
          'success': false,
          'error': MistralConfig.errorNotConfigured,
        };
      }

      final prompt =
          _construirePromptRapport(analyseReponses, avisInspection, titre);

      final response = await http.post(
        Uri.parse('${MistralConfig.baseUrl}${MistralConfig.chatEndpoint}'),
        headers: MistralConfig.defaultHeaders,
        body: jsonEncode({
          'model': MistralConfig.defaultModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Tu es un expert en rédaction de rapports pédagogiques pour le Ministère de l\'Éducation. '
                      'Tu rédiges des rapports structurés, professionnels et actionnables.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 4000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['choices'][0]['message']['content'] as String;

        return {
          'success': true,
          'rapport': content,
          'raw_response': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error':
              'Erreur 401: Clé API invalide ou expirée. Veuillez vérifier votre clé API Mistral.',
          'details': response.body,
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error':
              'Erreur 429: Limite de taux dépassée. Veuillez réessayer dans quelques minutes.',
          'details': response.body,
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur API: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Génère des recommandations pédagogiques
  static Future<Map<String, dynamic>> genererRecommandations({
    required String contexte,
    String? niveau,
    String? matiere,
  }) async {
    try {
      // Vérifier la configuration
      if (!MistralConfig.isConfigured) {
        return {
          'success': false,
          'error': MistralConfig.errorNotConfigured,
        };
      }

      final prompt =
          _construirePromptRecommandations(contexte, niveau, matiere);

      final response = await http.post(
        Uri.parse('${MistralConfig.baseUrl}${MistralConfig.chatEndpoint}'),
        headers: MistralConfig.defaultHeaders,
        body: jsonEncode({
          'model': MistralConfig.defaultModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Tu es un conseiller pédagogique expert du système éducatif Camerounais du secondaire. '
                      'Tu proposes des recommandations pratiques et réalisables.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.6,
          'max_tokens': 2500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['choices'][0]['message']['content'] as String;

        return {
          'success': true,
          'recommandations': content,
          'raw_response': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error':
              'Erreur 401: Clé API invalide ou expirée. Veuillez vérifier votre clé API Mistral.',
          'details': response.body,
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error':
              'Erreur 429: Limite de taux dépassée. Veuillez réessayer dans quelques minutes.',
          'details': response.body,
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur API: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // Méthodes privées pour construire les prompts
  static String _construirePromptQuestions(int nombre, String type,
      String? niveau, String? matiere, String? destinataire) {
    final niveauText = niveau != null ? ' pour le niveau $niveau' : '';
    final matiereText = matiere != null ? ' en $matiere' : '';
    final destinataireText =
        destinataire != null ? ' destiné aux $destinataire' : '';

    // Prompt spécifique selon le destinataire
    if (destinataire == 'eleve') {
      return '''
Génère $nombre questions de type "$type"$niveauText$matiereText$destinataireText pour l'évaluation pédagogique.

CONTEXTE: Questionnaire destiné aux ÉLÈVES du système éducatif Camerounais du secondaire.

Les questions doivent être :
- Adaptées au niveau scolaire des élèves
- Claires et compréhensibles pour des étudiants
- Variées en difficulté (facile, moyen, difficile)
- Pertinentes pour évaluer les connaissances et compétences
- Formulées de manière simple et directe
- Adaptées au contexte culturel Camerounais du secondaire

EXEMPLES DE QUESTIONS ÉLÈVES:
- "Quelle est la capitale du Sénégal ?"
- "Calculez l'aire d'un rectangle de 5cm par 3cm"
- "Expliquez en vos propres mots ce qu'est la photosynthèse"

Réponds en JSON avec cette structure :
{
  "questions": [
    {
      "intitule": "Question textuelle claire",
      "type": "QCM|TEXT|NUMERIC",
      "choix": ["A", "B", "C", "D"] // seulement si QCM
    }
  ]
}
''';
    } else if (destinataire == 'enseignant') {
      return '''
Génère $nombre questions de type "$type"$niveauText$matiereText$destinataireText pour l'évaluation pédagogique.

CONTEXTE: Questionnaire destiné aux ENSEIGNANTS du système éducatif Camerounais du secondaire.

Les questions doivent être :
- Adaptées au niveau professionnel des enseignants
- Axées sur les pratiques pédagogiques et méthodologiques
- Évaluant les compétences d'enseignement et d'évaluation
- Pertinentes pour améliorer les méthodes d'enseignement
- Formulées de manière professionnelle
- Adaptées au contexte éducatif Camerounais du secondaire

EXEMPLES DE QUESTIONS ENSEIGNANTS:
- "Quelle méthode utilisez-vous pour évaluer les élèves en difficulté ?"
- "Comment adaptez-vous votre enseignement aux différents styles d'apprentissage ?"
- "Décrivez une situation où vous avez dû adapter votre cours à un élève en difficulté"

Réponds en JSON avec cette structure :
{
  "questions": [
    {
      "intitule": "Question professionnelle",
      "type": "QCM|TEXT|NUMERIC",
      "choix": ["A", "B", "C", "D"] // seulement si QCM
    }
  ]
}
''';
    } else {
      return '''
Génère $nombre questions de type "$type"$niveauText$matiereText pour l'évaluation pédagogique.

Les questions doivent être :
- Adaptées au contexte éducatif Camerounais du secondaire
- Variées en difficulté
- Claires et compréhensibles
- Pertinentes pour l'évaluation

Réponds en JSON avec cette structure :
{
  "questions": [
    {
      "intitule": "Question textuelle",
      "type": "QCM|TEXT|NUMERIC",
      "choix": ["A", "B", "C", "D"] // seulement si QCM
    }
  ]
}
''';
    }
  }

  static String _construirePromptAnalyse(
      String reponsesJson, String typeQuestionnaire, String? contexte) {
    final contexteText = contexte != null ? 'Contexte: $contexte\n' : '';

    return '''
Analyse les réponses suivantes du questionnaire de type "$typeQuestionnaire" et génère un rapport pédagogique détaillé.

$contexteText
Réponses à analyser:
$reponsesJson

Le rapport doit inclure :
1. Résumé des tendances principales
2. Points forts identifiés
3. Axes d'amélioration
4. Recommandations concrètes
5. Statistiques pertinentes

Structure le rapport de manière claire et professionnelle.
''';
  }

  static String _construirePromptRapport(
      String analyseReponses, String avisInspection, String? titre) {
    final titreText = titre != null ? 'Titre: $titre\n' : '';

    return '''
Génère un rapport final pédagogique en combinant l'analyse automatique et l'avis de l'inspection.

$titreText
Analyse automatique:
$analyseReponses

Avis de l'inspection:
$avisInspection

Le rapport final doit être structuré avec :
- Introduction
- Méthodologie
- Résultats principaux
- Analyse détaillée
- Recommandations
- Conclusion

Rédige un rapport professionnel et actionnable pour le Ministère.
''';
  }

  static String _construirePromptRecommandations(
      String contexte, String? niveau, String? matiere) {
    final niveauText = niveau != null ? 'niveau $niveau' : 'tous niveaux';
    final matiereText =
        matiere != null ? 'matière $matiere' : 'toutes matières';

    return '''
Génère des recommandations pédagogiques basées sur le contexte suivant :

Contexte: $contexte
Niveau: $niveauText
Matière: $matiereText

Les recommandations doivent être :
- Pratiques et réalisables
- Adaptées au contexte Camerounais du secondaire
- Basées sur les meilleures pratiques
- Mesurables et évaluables

Structure les recommandations par catégories :
1. Pédagogie
2. Évaluation
3. Ressources
4. Formation
5. Suivi
''';
  }
}
