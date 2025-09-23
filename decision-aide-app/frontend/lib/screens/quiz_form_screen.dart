import 'dart:convert';
import 'package:flutter/material.dart';
import '../modeles/questionnaire.dart';
import '../modeles/reponse.dart';
import '../services/reponse_service.dart';

class QuizFormScreen extends StatefulWidget {
  final QuestionnaireModele questionnaire;
  final bool isEditMode;
  const QuizFormScreen(
      {super.key, required this.questionnaire, this.isEditMode = false});

  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  late List<dynamic> questions;
  final Map<int, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    final jsonMap = jsonDecode(widget.questionnaire.contenuJson);
    questions = jsonMap['questions'] as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionnaire.titre),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, i) {
          final q = questions[i];
          final type = q['type']?.toUpperCase();
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q['intitule'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (type == 'QCM' &&
                      q['choix'] != null &&
                      q['choix'].isNotEmpty)
                    Column(
                      children: List.generate(q['choix'].length, (j) {
                        return RadioListTile(
                          title: Text(q['choix'][j]),
                          value: q['choix'][j],
                          groupValue: _answers[i],
                          onChanged: (val) {
                            setState(() {
                              _answers[i] = val;
                            });
                          },
                        );
                      }),
                    )
                  else if (type == 'NUMERIC')
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'Votre réponse'),
                      onChanged: (val) => _answers[i] = val,
                    )
                  else
                    TextField(
                      decoration:
                          const InputDecoration(hintText: 'Votre réponse'),
                      onChanged: (val) => _answers[i] = val,
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Vérifie que toutes les questions ont une réponse non vide
          bool allAnswered = _answers.length == questions.length &&
              !_answers.values
                  .any((v) => v == null || (v is String && v.trim().isEmpty));
          if (!allAnswered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Veuillez répondre à toutes les questions avant de valider.')),
            );
            return;
          }
          final reponseService = ReponseService();
          final answersStringKey =
              _answers.map((k, v) => MapEntry(k.toString(), v));
          final reponse = ReponseQuestionnaireModele(
            id: 0,
            questionnaireId: widget.questionnaire.id,
            reponsesJson: jsonEncode(answersStringKey),
          );
          final success = await reponseService.enregistrer(reponse);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Réponses enregistrées avec succès !')),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Erreur lors de l\'enregistrement.')),
            );
          }
        },
        label: const Text('Valider'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
