import 'package:flutter/material.dart';
import '../services/questionnaire_service.dart';
import '../modeles/questionnaire.dart';
import 'quiz_form_screen.dart';
import '../services/reponse_service.dart';

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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(q.titre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date de validité: ' +
                          (q.dateFinPartage?.toString() ?? 'Non définie')),
                      Text('Destinataire: ' + q.destinataire),
                    ],
                  ),
                  onTap: () async {
                    // Vérifie si l'utilisateur a déjà répondu à ce questionnaire
                    final reponseService = ReponseService();
                    final reponses = await reponseService.lister();
                    final utilisateur =
                        await QuestionnaireService().profilActuel();
                    final dejaRepondu = reponses.any((r) =>
                        r.questionnaireId == q.id &&
                        r.utilisateurNom == utilisateur?.nomComplet);
                    if (dejaRepondu) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Vous avez déjà répondu à ce questionnaire.')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizFormScreen(questionnaire: q),
                      ),
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'modifier_date') {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: q.dateFinPartage ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (newDate != null) {
                          // Call backend to update date
                          final success = await QuestionnaireService()
                              .partager(q.id, newDate);
                          if (success) {
                            setState(() {
                              q.dateFinPartage = newDate;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Date de validité modifiée')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Erreur lors de la modification')),
                            );
                          }
                        }
                      } else if (value == 'supprimer') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Supprimer'),
                            content: Text(
                                'Voulez-vous vraiment supprimer ce questionnaire ?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Annuler')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Supprimer')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final success =
                              await QuestionnaireService().supprimer(q.id);
                          if (success) {
                            setState(() {
                              items.removeAt(i);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Questionnaire supprimé')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Erreur lors de la suppression')),
                            );
                          }
                        }
                      } else if (value == 'partager_rapport') {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (ctx) {
                            TextEditingController controller =
                                TextEditingController();
                            return AlertDialog(
                              title:
                                  Text('Ajouter un commentaire avant partage'),
                              content: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                    hintText: 'Votre commentaire'),
                                maxLines: 3,
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, null),
                                    child: Text('Annuler')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, controller.text),
                                    child: Text('Partager')),
                              ],
                            );
                          },
                        );
                        if (result != null && result.trim().isNotEmpty) {
                          // TODO: Send comment with report sharing (API integration needed)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Commentaire ajouté et rapport partagé')),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          value: 'modifier_date',
                          child: Text('Modifier date de validité')),
                      PopupMenuItem(
                          value: 'supprimer', child: Text('Supprimer')),
                      PopupMenuItem(
                          value: 'partager_rapport',
                          child: Text('Partager rapport (avec avis)')),
                    ],
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
