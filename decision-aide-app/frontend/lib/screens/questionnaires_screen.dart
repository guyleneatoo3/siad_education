import 'package:flutter/material.dart';
import '../services/questionnaire_service.dart';
import '../modeles/questionnaire.dart';
import 'quiz_form_screen.dart';

class QuestionnairesScreen extends StatefulWidget {
  const QuestionnairesScreen({super.key});

  @override
  State<QuestionnairesScreen> createState() => _QuestionnairesScreenState();
}

class _QuestionnairesScreenState extends State<QuestionnairesScreen> {
  final QuestionnaireService _service = QuestionnaireService();
  late Future<List<QuestionnaireModele>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listerFiltresParRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questionnaires')),
      body: FutureBuilder<List<QuestionnaireModele>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Aucun questionnaire'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final q = items[i];
              return ListTile(
                title: Text(q.titre),
                subtitle: Text(q.dateFinPartage.toString(),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizFormScreen(questionnaire: q),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
