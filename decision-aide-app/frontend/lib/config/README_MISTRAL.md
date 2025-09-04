# Configuration de l'API Mistral

## 🚀 Vue d'ensemble

L'application SIAD Décision intègre l'API Mistral directement dans le frontend Flutter pour générer des questions pédagogiques, analyser les réponses et créer des rapports automatiquement.

## 📋 Fonctionnalités disponibles

### 1. Génération de Questions
- Création automatique de questions QCM, textuelles ou numériques
- Adaptation au niveau scolaire et à la matière
- Contexte éducatif sénégalais

### 2. Analyse de Réponses
- Analyse automatique des réponses aux questionnaires
- Identification des tendances et points d'amélioration
- Génération d'insights pédagogiques

### 3. Création de Rapports
- Combinaison de l'analyse automatique et de l'avis de l'inspection
- Rapports structurés et professionnels
- Recommandations actionnables

### 4. Recommandations Pédagogiques
- Suggestions basées sur le contexte
- Recommandations pratiques et réalisables
- Adaptation au système éducatif sénégalais

## ⚙️ Configuration

### Étape 1: Obtenir une clé API Mistral

1. Créez un compte sur [Mistral AI](https://console.mistral.ai/)
2. Générez une clé API dans votre dashboard
3. Notez votre clé API (elle commence par `mist-`)

### Étape 2: Configurer la clé API

1. Ouvrez le fichier `lib/config/mistral_config.dart`
2. Remplacez `YOUR_MISTRAL_API_KEY` par votre vraie clé API :

```dart
class MistralConfig {
  static const String apiKey = 'mist-votre-vraie-cle-api-ici';
  // ... reste de la configuration
}
```

### Étape 3: Vérifier la configuration

L'application vérifie automatiquement si la clé API est configurée. Si ce n'est pas le cas, vous verrez un message d'erreur explicite.

## 🎯 Utilisation

### Interface de Test

1. Connectez-vous en tant qu'Inspection
2. Accédez au tableau de bord
3. Cliquez sur "Test Mistral"
4. Sélectionnez la fonction à tester
5. Remplissez les paramètres
6. Cliquez sur "Exécuter"

### Intégration dans l'Application

Les fonctionnalités Mistral sont intégrées dans :
- **Dashboard Inspection** : Test direct de l'API
- **Génération de questionnaires** : Questions automatiques
- **Analyse de réponses** : Insights automatiques
- **Création de rapports** : Rapports structurés

## 🔧 Modèles disponibles

- `mistral-large-latest` : Modèle le plus avancé (par défaut)
- `mistral-medium-latest` : Équilibré performance/coût
- `mistral-small-latest` : Rapide et économique

## 📊 Paramètres configurables

### Temperature
- `0.0` : Réponses très cohérentes
- `0.7` : Équilibré (par défaut)
- `1.0` : Réponses très créatives

### Max Tokens
- `1000` : Réponses courtes
- `2000` : Équilibré (par défaut)
- `4000` : Réponses détaillées

## 🛡️ Sécurité

### Bonnes pratiques
1. **Ne jamais commiter** votre clé API dans Git
2. **Utilisez des variables d'environnement** en production
3. **Limitez l'accès** à la clé API
4. **Surveillez l'utilisation** via le dashboard Mistral

### Variables d'environnement (recommandé)

Pour une configuration plus sécurisée, utilisez des variables d'environnement :

```dart
// Dans mistral_config.dart
static const String apiKey = String.fromEnvironment('MISTRAL_API_KEY', defaultValue: 'YOUR_MISTRAL_API_KEY');
```

Puis lancez l'application avec :
```bash
flutter run --dart-define=MISTRAL_API_KEY=votre-cle-api
```

## 🐛 Dépannage

### Erreurs courantes

1. **"Clé API non configurée"**
   - Vérifiez que vous avez remplacé `YOUR_MISTRAL_API_KEY`
   - Redémarrez l'application

2. **"Clé API invalide"**
   - Vérifiez que votre clé API est correcte
   - Vérifiez que votre compte Mistral est actif

3. **"Limite de taux dépassée"**
   - Attendez quelques minutes
   - Vérifiez votre quota dans le dashboard Mistral

4. **"Erreur de connexion"**
   - Vérifiez votre connexion internet
   - Vérifiez que l'API Mistral est accessible

### Logs de débogage

Activez les logs pour diagnostiquer les problèmes :

```dart
// Dans mistral_service.dart, ajoutez :
print('Mistral API Response: ${response.body}');
```

## 💰 Coûts

### Tarification Mistral
- **Large** : ~$0.14/1M tokens
- **Medium** : ~$0.07/1M tokens  
- **Small** : ~$0.02/1M tokens

### Estimation des coûts
- Génération de 10 questions : ~$0.001
- Analyse de 100 réponses : ~$0.005
- Rapport complet : ~$0.01

## 📚 Exemples d'utilisation

### Génération de questions QCM

```dart
final resultat = await MistralService.genererQuestions(
  nombre: 5,
  type: 'QCM',
  niveau: 'Seconde',
  matiere: 'Mathématiques',
);
```

### Analyse de réponses

```dart
final resultat = await MistralService.analyserReponses(
  reponsesJson: jsonReponses,
  typeQuestionnaire: 'Évaluation pédagogique',
  contexte: 'Élèves de seconde en mathématiques',
);
```

### Création de rapport

```dart
final resultat = await MistralService.genererRapportFinal(
  analyseReponses: analyseAutomatique,
  avisInspection: avisPersonnel,
  titre: 'Rapport d\'évaluation Q1 2024',
);
```

## 🔄 Mise à jour

Pour mettre à jour la configuration :

1. Modifiez `mistral_config.dart`
2. Redémarrez l'application
3. Testez via l'interface "Test Mistral"

## 📞 Support

Pour toute question ou problème :
1. Consultez la [documentation Mistral](https://docs.mistral.ai/)
2. Vérifiez les logs de l'application
3. Testez avec l'interface de test intégrée
