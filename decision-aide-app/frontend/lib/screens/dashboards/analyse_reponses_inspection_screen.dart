import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dart:convert';

class AnalyseReponsesInspectionScreen extends StatefulWidget {
  final ApiService api;
  const AnalyseReponsesInspectionScreen({super.key, required this.api});

  @override
  State<AnalyseReponsesInspectionScreen> createState() =>
      _AnalyseReponsesInspectionScreenState();
}

class _AnalyseReponsesInspectionScreenState
    extends State<AnalyseReponsesInspectionScreen> {
  String? _typeUtilisateur; // 'ELEVE' ou 'ENSEIGNANT'
  int? _questionnaireIdSelectionne;
  Map<String, dynamic>? _analyse;
  bool _loading = false;
  List<Map<String, dynamic>> _questionnaires = [];

  Future<void> _chargerAnalyse() async {
    setState(() {
      _loading = true;
    });
    final analyse = await widget.api.getAnalyseReponsesInspection(
      _questionnaireIdSelectionne!,
      _typeUtilisateur!,
    );
    setState(() {
      _analyse = analyse;
      _loading = false;
    });
  }

  Future<void> _chargerQuestionnaires() async {
    setState(() {
      _loading = true;
    });
    final res = await widget.api.get('/api/questionnaires');
    if (res.statusCode == 200) {
      final List data = (jsonDecode(res.body) as List);
      setState(() {
        _questionnaires = data
            .cast<Map<String, dynamic>>()
            .where((q) =>
                _typeUtilisateur == null ||
                q['destinataire'] == _typeUtilisateur)
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyse des réponses')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _typeUtilisateur == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Choisissez le type d\'utilisateur à analyser :',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _typeUtilisateur = 'ELEVE';
                      });
                      _chargerQuestionnaires();
                    },
                    child: const Text('ÉLÈVE'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _typeUtilisateur = 'ENSEIGNANT';
                      });
                      _chargerQuestionnaires();
                    },
                    child: const Text('ENSEIGNANT'),
                  ),
                ],
              )
            : _loading
                ? const Center(child: CircularProgressIndicator())
                : _questionnaireIdSelectionne == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Type sélectionné : ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(_typeUtilisateur ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal)),
                              const Spacer(),
                              TextButton(
                                onPressed: () => setState(() {
                                  _typeUtilisateur = null;
                                  _questionnaires = [];
                                }),
                                child: const Text('Changer'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Sélectionnez un questionnaire :',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _questionnaires.length,
                              itemBuilder: (context, i) {
                                final q = _questionnaires[i];
                                return Card(
                                  child: ListTile(
                                    title: Text(q['titre'] ??
                                        'Questionnaire #${q['id']}'),
                                    subtitle: Text(
                                        'Destinataire : ${q['destinataire']}'),
                                    trailing: TextButton(
                                      child:
                                          const Text('Voir les statistiques'),
                                      onPressed: () async {
                                        setState(() {
                                          _questionnaireIdSelectionne = q['id'];
                                        });
                                        await _chargerAnalyse();
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildStatsQuestionnaire(),
      ),
    );
  }

  Widget _buildStatsQuestionnaire() {
    if (_analyse == null ||
        !_analyse!.containsKey(_questionnaireIdSelectionne.toString())) {
      return const Text('Aucune statistique disponible pour ce questionnaire.');
    }
    final questions = _analyse![_questionnaireIdSelectionne.toString()]
        as Map<String, dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() {
                _questionnaireIdSelectionne = null;
              }),
            ),
            const Text('Statistiques du questionnaire',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        ...questions.entries.map((questEntry) {
          final question = questEntry.key;
          final stats = questEntry.value as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...stats.entries
                      .map((stat) => Text('${stat.key} : ${stat.value}')),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
