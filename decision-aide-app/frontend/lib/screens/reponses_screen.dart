import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/reponse_service.dart';
import '../services/api_service.dart';
import '../modeles/reponse.dart';

class ReponsesScreen extends StatefulWidget {
  const ReponsesScreen({super.key});

  @override
  State<ReponsesScreen> createState() => _ReponsesScreenState();
}

class _ReponsesScreenState extends State<ReponsesScreen> {
  final ReponseService _service = ReponseService();
  Future<List<ReponseQuestionnaireModele>>? _future;
  String? _nomEnseignant;

  @override
  void initState() {
    super.initState();
    _loadUserAndResponses();
  }

  void _loadUserAndResponses() async {
    final user = await ApiService().profilActuel();
    setState(() {
      _nomEnseignant = user?['nomComplet'];
      _future = _service.lister();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réponses'),
      ),
      body: _future == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<ReponseQuestionnaireModele>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                final items = snapshot.data
                        ?.where((r) => r.utilisateurNom == _nomEnseignant)
                        .toList() ??
                    [];
                if (items.isEmpty) {
                  return const Center(child: Text('Aucune réponse trouvée.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final reponse = items[i];
                    return Opacity(
                      opacity: 0.6,
                      child: Card(
                        color: Colors.grey[200],
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo[600],
                            child: const Icon(Icons.assignment_turned_in,
                                color: Colors.white),
                          ),
                          title: Text(
                            reponse.questionnaireTitre != null &&
                                    reponse.questionnaireTitre!.isNotEmpty
                                ? reponse.questionnaireTitre!
                                : 'Questionnaire #${reponse.questionnaireId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reponse.dateSoumission != null)
                                Text(
                                  'Soumis le: '
                                  '${reponse.dateSoumission!.day.toString().padLeft(2, '0')}/'
                                  '${reponse.dateSoumission!.month.toString().padLeft(2, '0')}/'
                                  '${reponse.dateSoumission!.year} à '
                                  '${reponse.dateSoumission!.hour.toString().padLeft(2, '0')}:'
                                  '${reponse.dateSoumission!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Réponses choisies :',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              ..._buildReponsesList(reponse.reponsesJson),
                            ],
                          ),
                          trailing: const Icon(Icons.visibility_off,
                              color: Colors.grey),
                          enabled: false,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Affiche les réponses sous forme de liste lisible
  List<Widget> _buildReponsesList(String reponsesJson) {
    try {
      final decoded = reponsesJson.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(reponsesJson))
          : {};
      if (decoded.isEmpty) return [const Text('Aucune réponse.')];
      return decoded.entries
          .map((e) => Text('Q${e.key} : ${e.value}'))
          .toList();
    } catch (_) {
      return [Text(reponsesJson)];
    }
  }
}
