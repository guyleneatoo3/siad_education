import 'package:decision_aide_frontend/modeles/questionnaire.dart';
import 'package:decision_aide_frontend/services/questionnaire_service.dart';
import 'package:flutter/material.dart';
import '../services/mistral_service.dart';
import '../utils/mistral_test.dart';

class MistralTestScreen extends StatefulWidget {
  const MistralTestScreen({super.key});

  @override
  State<MistralTestScreen> createState() => _MistralTestScreenState();
}

class _MistralTestScreenState extends State<MistralTestScreen> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _utilisateurIdController =
      TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _niveauController = TextEditingController();
  final TextEditingController _matiereController = TextEditingController();
  final TextEditingController _reponsesController = TextEditingController();
  final TextEditingController _avisController = TextEditingController();
  final TextEditingController _contexteController = TextEditingController();
  final TextEditingController _destinataireController = TextEditingController();

  String _selectedFunction = 'questions';
  bool _isLoading = false;
  String? _resultat;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombreController.text = '5';
    _typeController.text = 'QCM';
    _niveauController.text = 'Seconde';
    _matiereController.text = 'Mathématiques';
    _destinataireController.text = 'eleve';
    _titreController.text = 'Questionnaire généré';
    _utilisateurIdController.text = '1';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _typeController.dispose();
    _niveauController.dispose();
    _matiereController.dispose();
    _reponsesController.dispose();
    _avisController.dispose();
    _contexteController.dispose();
    _destinataireController.dispose();
    _titreController.dispose();
    _utilisateurIdController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerQuestionnaire() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // On suppose que la génération de questions a déjà été faite et stockée dans _resultat
      if (_resultat == null) {
        setState(() {
          _isLoading = false;
          _error = 'Veuillez d’abord générer les questions.';
        });
        return;
      }
      // Récupérer l'utilisateur courant via le service (profilActuel)
      final utilisateur = await QuestionnaireService().profilActuel();
      final questionnaire = QuestionnaireModele(
        id: 0,
        titre: _titreController.text,
        contenuJson: _resultat!,
        creePar: utilisateur,
      );
      await QuestionnaireService().creer(questionnaire);
      setState(() {
        _isLoading = false;
        _resultat = 'Questionnaire enregistré avec succès !';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur lors de l’enregistrement : $e';
      });
    }
  }

  Future<void> _partagerQuestionnaire() async {
    setState(() {
      _isLoading = true;
      _resultat = null;
      _error = null;
    });
    try {
      // On suppose que la génération de questions a déjà été faite et stockée dans _resultat
      if (_resultat == null) {
        setState(() {
          _isLoading = false;
          _error = 'Veuillez d’abord générer les questions.';
        });
        return;
      }
      // TODO: implémenter la logique d’envoi/partage selon le destinataire (enseignant/élève)
      setState(() {
        _isLoading = false;
        _resultat = 'Questionnaire partagé avec succès !';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur lors du partage : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API Mistral'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champs supplémentaires pour titre et utilisateur
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titreController,
                      decoration: const InputDecoration(
                        labelText: 'Titre du questionnaire',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sélection de fonction
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fonction à tester',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedFunction,
                      decoration: const InputDecoration(
                        labelText: 'Fonction',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'questions',
                          child: Text('Générer des questions'),
                        ),
                        DropdownMenuItem(
                          value: 'analyse',
                          child: Text('Analyser des réponses'),
                        ),
                        DropdownMenuItem(
                          value: 'rapport',
                          child: Text('Générer un rapport'),
                        ),
                        DropdownMenuItem(
                          value: 'recommandations',
                          child: Text('Générer des recommandations'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFunction = value!;
                          _resultat = null;
                          _error = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Paramètres selon la fonction
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paramètres',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildParametres(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _executerFonction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Exécuter',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _diagnostic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Diagnostic',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enregistrerQuestionnaire,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _partagerQuestionnaire,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Partager',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Affichage du résultat
            if (_error != null) ...[
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Erreur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_resultat != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Résultat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              // TODO: Implémenter la copie
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Copié dans le presse-papiers')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: SelectableText(
                          _resultat!,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParametres() {
    switch (_selectedFunction) {
      case 'questions':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de questions',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type (QCM, TEXT, NUMERIC)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _niveauController,
                    decoration: const InputDecoration(
                      labelText: 'Niveau (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _matiereController,
                    decoration: const InputDecoration(
                      labelText: 'Matière (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _destinataireController,
                    decoration: const InputDecoration(
                      labelText: 'Destinataire (eleve/enseignant)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(), // Espace vide pour l'alignement
                ),
              ],
            ),
          ],
        );

      case 'analyse':
        return Column(
          children: [
            TextField(
              controller: _reponsesController,
              decoration: const InputDecoration(
                labelText: 'Réponses JSON à analyser',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type de questionnaire',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contexteController,
              decoration: const InputDecoration(
                labelText: 'Contexte (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );

      case 'rapport':
        return Column(
          children: [
            TextField(
              controller: _reponsesController,
              decoration: const InputDecoration(
                labelText: 'Analyse des réponses',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _avisController,
              decoration: const InputDecoration(
                labelText: 'Avis de l\'inspection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contexteController,
              decoration: const InputDecoration(
                labelText: 'Titre du rapport (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );

      case 'recommandations':
        return Column(
          children: [
            TextField(
              controller: _contexteController,
              decoration: const InputDecoration(
                labelText: 'Contexte',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _niveauController,
                    decoration: const InputDecoration(
                      labelText: 'Niveau (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _matiereController,
                    decoration: const InputDecoration(
                      labelText: 'Matière (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      default:
        return const Text('Fonction non reconnue');
    }
  }

  Future<void> _executerFonction() async {
    setState(() {
      _isLoading = true;
      _resultat = null;
      _error = null;
    });

    try {
      Map<String, dynamic> resultat;

      switch (_selectedFunction) {
        case 'questions':
          resultat = await MistralService.genererQuestions(
            nombre: int.tryParse(_nombreController.text) ?? 5,
            type: _typeController.text,
            niveau: _niveauController.text.isNotEmpty
                ? _niveauController.text
                : null,
            matiere: _matiereController.text.isNotEmpty
                ? _matiereController.text
                : null,
            destinataire: _destinataireController.text.isNotEmpty
                ? _destinataireController.text
                : null,
          );
          break;

        case 'analyse':
          resultat = await MistralService.analyserReponses(
            reponsesJson: _reponsesController.text,
            typeQuestionnaire: _typeController.text,
            contexte: _contexteController.text.isNotEmpty
                ? _contexteController.text
                : null,
          );
          break;

        case 'rapport':
          resultat = await MistralService.genererRapportFinal(
            analyseReponses: _reponsesController.text,
            avisInspection: _avisController.text,
            titre: _contexteController.text.isNotEmpty
                ? _contexteController.text
                : null,
          );
          break;

        case 'recommandations':
          resultat = await MistralService.genererRecommandations(
            contexte: _contexteController.text,
            niveau: _niveauController.text.isNotEmpty
                ? _niveauController.text
                : null,
            matiere: _matiereController.text.isNotEmpty
                ? _matiereController.text
                : null,
          );
          break;

        default:
          throw Exception('Fonction non reconnue');
      }

      setState(() {
        _isLoading = false;
        if (resultat['success'] == true) {
          _resultat = resultat[_getResultKey()];
        } else {
          _error = resultat['error'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur: $e';
      });
    }
  }

  String _getResultKey() {
    switch (_selectedFunction) {
      case 'questions':
        return 'questions';
      case 'analyse':
        return 'analyse';
      case 'rapport':
        return 'rapport';
      case 'recommandations':
        return 'recommandations';
      default:
        return 'resultat';
    }
  }

  Future<void> _diagnostic() async {
    setState(() {
      _isLoading = true;
      _resultat = null;
      _error = null;
    });

    try {
      final diagnostic = await MistralTest.diagnostic401();

      setState(() {
        _isLoading = false;
        if (diagnostic['success'] == true) {
          _resultat = 'Diagnostic réussi ! Configuration valide.';
        } else {
          _error = 'Diagnostic échoué. Vérifiez la configuration.';
          _resultat = 'Détails du diagnostic:\n${diagnostic['diagnostics']}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur lors du diagnostic: $e';
      });
    }
  }
}
