import 'package:flutter/material.dart';
import '../../modeles/questionnaire.dart';
import '../../services/questionnaire_service.dart';
import '../quiz_form_screen.dart';

class InspectorQuestionnairesScreen extends StatefulWidget {
  const InspectorQuestionnairesScreen({super.key});

  @override
  State<InspectorQuestionnairesScreen> createState() =>
      _InspectorQuestionnairesScreenState();
}

class _InspectorQuestionnairesScreenState
    extends State<InspectorQuestionnairesScreen> {
  final QuestionnaireService _service = QuestionnaireService();
  String _selectedType = 'ENSEIGNANT';
  late Future<List<QuestionnaireModele>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _service.listerParCreateurEtDestinataire(_selectedType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes questionnaires générés'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Voir pour :',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Enseignants'),
                  selected: _selectedType == 'ENSEIGNANT',
                  onSelected: (v) {
                    setState(() {
                      _selectedType = 'ENSEIGNANT';
                      _load();
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Élèves'),
                  selected: _selectedType == 'ELEVE',
                  onSelected: (v) {
                    setState(() {
                      _selectedType = 'ELEVE';
                      _load();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<QuestionnaireModele>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                      child: Text('Aucun questionnaire généré.'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final q = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        title: Text(q.titre,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Destinataire : ${q.destinataire}'),
                            if (q.dateFinPartage != null)
                              Text('Partagé jusqu\'au : ${q.dateFinPartage}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizFormScreen(
                                      questionnaire: q, isEditMode: true),
                                ),
                              ).then((_) => _load());
                            } else if (value == 'update') {
                              // TODO: implement update logic (e.g. update title, date, etc.)
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Modifier')),
                            const PopupMenuItem(
                                value: 'update', child: Text('Mettre à jour')),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizFormScreen(
                                  questionnaire: q, isEditMode: false),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
