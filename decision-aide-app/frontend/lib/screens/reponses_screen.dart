import 'package:flutter/material.dart';
import '../services/reponse_service.dart';
import '../modeles/reponse.dart';

class ReponsesScreen extends StatefulWidget {
  const ReponsesScreen({super.key});

  @override
  State<ReponsesScreen> createState() => _ReponsesScreenState();
}

class _ReponsesScreenState extends State<ReponsesScreen> {
  final ReponseService _service = ReponseService();
  late Future<List<ReponseQuestionnaireModele>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.lister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réponses aux Questionnaires'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ReponseQuestionnaireModele>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune réponse', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final reponse = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo[600],
                    child: const Icon(Icons.assignment_turned_in, color: Colors.white),
                  ),
                  title: Text(
                    'Questionnaire #${reponse.questionnaireId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reponse.utilisateurNom != null)
                        Text('Par: ${reponse.utilisateurNom}'),
                      if (reponse.dateSoumission != null)
                        Text(
                          'Soumis le: ${reponse.dateSoumission!.toLocal().toString().split('.')[0]}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Réponses: ${reponse.reponsesJson.length} caractères',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Détails des réponses'),
                          content: SingleChildScrollView(
                            child: Text(reponse.reponsesJson),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fermer'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
