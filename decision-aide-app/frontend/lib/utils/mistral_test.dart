import '../services/mistral_service.dart';
import '../config/mistral_config.dart';

class MistralTest {
  /// Test de la configuration de l'API
  static Future<Map<String, dynamic>> testConfiguration() async {
    print('🔧 Test de configuration Mistral...');

    // Vérifier la configuration
    if (!MistralConfig.isConfigured) {
      return {
        'success': false,
        'error': 'Configuration non valide',
        'details': 'Clé API non configurée ou invalide',
      };
    }

    print('✅ Configuration valide');
    print('🔑 Clé API: ${MistralConfig.apiKey.substring(0, 10)}...');
    print('🤖 Modèle: ${MistralConfig.defaultModel}');

    return {
      'success': true,
      'message': 'Configuration valide',
      'model': MistralConfig.defaultModel,
    };
  }

  /// Test simple de l'API avec une question basique
  static Future<Map<String, dynamic>> testSimpleQuestion() async {
    print('🧪 Test de génération de question simple...');

    try {
      final resultat = await MistralService.genererQuestions(
        nombre: 1,
        type: 'QCM',
        niveau: 'Test',
        matiere: 'Test',
        destinataire: 'eleve',
      );

      if (resultat['success'] == true) {
        print('✅ Test réussi');
        print('📝 Question générée: ${resultat['questions']}');
      } else {
        print('❌ Test échoué: ${resultat['error']}');
      }

      return resultat;
    } catch (e) {
      print('❌ Erreur lors du test: $e');
      return {
        'success': false,
        'error': 'Erreur de test: $e',
      };
    }
  }

  /// Test complet de toutes les fonctionnalités
  static Future<Map<String, dynamic>> testComplet() async {
    print('🚀 Test complet de l\'API Mistral...');

    final resultats = <String, dynamic>{};

    // Test 1: Configuration
    resultats['configuration'] = await testConfiguration();

    if (resultats['configuration']['success'] == false) {
      return {
        'success': false,
        'error': 'Échec de la configuration',
        'details': resultats,
      };
    }

    // Test 2: Question simple
    resultats['question_simple'] = await testSimpleQuestion();

    // Test 3: Question pour élève
    print('👨‍🎓 Test question élève...');
    resultats['question_eleve'] = await MistralService.genererQuestions(
      nombre: 2,
      type: 'QCM',
      niveau: 'Seconde',
      matiere: 'Mathématiques',
      destinataire: 'eleve',
    );

    // Test 4: Question pour enseignant
    print('👨‍🏫 Test question enseignant...');
    resultats['question_enseignant'] = await MistralService.genererQuestions(
      nombre: 2,
      type: 'TEXT',
      niveau: 'Tous niveaux',
      matiere: 'Pédagogie',
      destinataire: 'enseignant',
    );

    // Test 5: Analyse de réponses
    print('📊 Test analyse de réponses...');
    resultats['analyse'] = await MistralService.analyserReponses(
      reponsesJson: '''
      {
        "reponses": [
          {"question": "Quelle est la capitale du Sénégal?", "reponse": "Dakar", "correcte": true},
          {"question": "Calculez 2+2", "reponse": "4", "correcte": true},
          {"question": "Quelle est la capitale du Mali?", "reponse": "Bamako", "correcte": true}
        ]
      }
      ''',
      typeQuestionnaire: 'Évaluation géographie',
      contexte: 'Élèves de seconde',
    );

    // Test 6: Recommandations
    print('💡 Test recommandations...');
    resultats['recommandations'] = await MistralService.genererRecommandations(
      contexte: 'Amélioration des résultats en mathématiques',
      niveau: 'Seconde',
      matiere: 'Mathématiques',
    );

    // Résumé des tests
    final succes = resultats.values.where((r) => r['success'] == true).length;
    final total = resultats.length;

    print('📈 Résumé des tests: $succes/$total réussis');

    return {
      'success': succes == total,
      'message': 'Test complet terminé',
      'statistiques': {
        'total': total,
        'reussis': succes,
        'echecs': total - succes,
      },
      'details': resultats,
    };
  }

  /// Test de diagnostic pour l'erreur 401
  static Future<Map<String, dynamic>> diagnostic401() async {
    print('🔍 Diagnostic de l\'erreur 401...');

    final diagnostics = <String, dynamic>{};

    // Vérifier la clé API
    diagnostics['cle_api'] = {
      'configuree': MistralConfig.isConfigured,
      'longueur': MistralConfig.apiKey.length,
      'prefixe': MistralConfig.apiKey.startsWith('mist-'),
      'valeur': MistralConfig.apiKey.substring(0, 10) + '...',
    };

    // Vérifier les headers
    diagnostics['headers'] = MistralConfig.defaultHeaders;

    // Test de connexion simple
    try {
      final resultat = await MistralService.genererQuestions(
        nombre: 1,
        type: 'QCM',
        destinataire: 'eleve',
      );

      diagnostics['test_connexion'] = {
        'success': resultat['success'],
        'error': resultat['error'] ?? 'Aucune erreur',
      };
    } catch (e) {
      diagnostics['test_connexion'] = {
        'success': false,
        'error': 'Exception: $e',
      };
    }

    return {
      'success': diagnostics['test_connexion']['success'],
      'diagnostics': diagnostics,
    };
  }
}
