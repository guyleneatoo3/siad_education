import 'package:flutter/material.dart';
import '../services/decision_service.dart';
import '../modeles/decision.dart';

class DecisionsScreen extends StatefulWidget {
  const DecisionsScreen({super.key});

  @override
  State<DecisionsScreen> createState() => _DecisionsScreenState();
}

class _DecisionsScreenState extends State<DecisionsScreen> {
  final DecisionService _service = DecisionService();
  late Future<List<DecisionModele>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.lister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Décisions publiées')),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.edit),
        label: Text('Rédiger une décision'),
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, '/rediger-decision');
          if (result == true) {
            setState(() {
              _future = _service.lister();
            });
          }
        },
      ),
      body: FutureBuilder<List<DecisionModele>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Aucune décision'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = items[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(d.titre),
                  subtitle: Text(d.contenu,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'modifier') {
                        final titreController =
                            TextEditingController(text: d.titre);
                        final contenuController =
                            TextEditingController(text: d.contenu);
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Modifier la décision'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: titreController,
                                  decoration:
                                      InputDecoration(labelText: 'Titre'),
                                ),
                                SizedBox(height: 8),
                                TextField(
                                  controller: contenuController,
                                  decoration:
                                      InputDecoration(labelText: 'Contenu'),
                                  maxLines: 6,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Annuler')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Enregistrer')),
                            ],
                          ),
                        );
                        if (result == true) {
                          final success =
                              await DecisionService().modifierDecision(
                            d.id,
                            titreController.text.trim(),
                            contenuController.text.trim(),
                            d.publie,
                          );
                          if (success) {
                            setState(() {
                              _future = _service.lister();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Décision modifiée')),
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
                            title: Text('Supprimer la décision'),
                            content: Text(
                                'Voulez-vous vraiment supprimer cette décision ?'),
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
                              await DecisionService().supprimerDecision(d.id);
                          if (success) {
                            setState(() {
                              _future = _service.lister();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Décision supprimée')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Erreur lors de la suppression')),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'modifier', child: Text('Modifier')),
                      PopupMenuItem(
                          value: 'supprimer', child: Text('Supprimer')),
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
