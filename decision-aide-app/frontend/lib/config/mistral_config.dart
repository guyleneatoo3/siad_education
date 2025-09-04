class MistralConfig {
  // Configuration de l'API Mistral
  static const String apiKey =
      'w0hMXfxmRC29Tzpupok8k0bpGMUEm4ze'; // Clé API configurée

  // Modèles disponibles
  static const String modelLarge = 'mistral-large-latest';
  static const String modelMedium = 'mistral-medium-latest';
  static const String modelSmall = 'mistral-small-latest';
  static const String modelTiny = 'mistral-tiny'; // Modèle fonctionnel

  // Configuration par défaut
  static const String defaultModel = modelTiny; // Utiliser mistral-tiny par défaut
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 2000;

  // Endpoints
  static const String baseUrl = 'https://api.mistral.ai/v1';
  static const String chatEndpoint = '/chat/completions';

  // Headers par défaut
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

  // Validation de la configuration
  static bool get isConfigured =>
      apiKey == 'w0hMXfxmRC29Tzpupok8k0bpGMUEm4ze' && apiKey.isNotEmpty;

  // Messages d'erreur
  static const String errorNotConfigured =
      'Clé API Mistral non configurée. Veuillez configurer votre clé API dans mistral_config.dart';
  static const String errorInvalidKey = 'Clé API Mistral invalide';
  static const String errorRateLimit =
      'Limite de taux dépassée. Veuillez réessayer plus tard';
  static const String errorServer = 'Erreur du serveur Mistral';
}
