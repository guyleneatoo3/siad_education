import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  Map<String, dynamic>? _stats;
  bool _afficherRapport = false;
  bool _loading = false;
  List<Map<String, dynamic>> _questionnaires = [];

  Future<void> _chargerStatsEtAnalyse({bool chargerRapport = false}) async {
    setState(() {
      _loading = true;
    });
    // Charger stats (diagramme)
    final stats = await widget.api
        .getStatsReponsesQuestionnaire(_questionnaireIdSelectionne!);
    setState(() {
      _stats = stats['stats'] ?? {};
      _loading = false;
    });
    // Charger analyse (rapport) si demandé
    if (chargerRapport) {
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
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          child: const Text('Modifier date'),
                                          onPressed: () async {
                                            DateTime? picked =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2020),
                                              lastDate: DateTime(2100),
                                            );
                                            if (picked != null) {
                                              bool ok = await widget.api
                                                  .modifierDateValiditeQuestionnaire(
                                                      q['id'], picked);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(ok
                                                        ? 'Date modifiée !'
                                                        : 'Erreur modification date')),
                                              );
                                              await _chargerQuestionnaires();
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          child: const Text('Supprimer'),
                                          onPressed: () async {
                                            bool ok = await widget.api
                                                .supprimerQuestionnaire(
                                                    q['id']);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(ok
                                                      ? 'Questionnaire supprimé !'
                                                      : 'Erreur suppression')),
                                            );
                                            await _chargerQuestionnaires();
                                          },
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          child:
                                              const Text('Voir statistiques'),
                                          onPressed: () async {
                                            setState(() {
                                              _questionnaireIdSelectionne =
                                                  q['id'];
                                            });
                                            await _chargerStatsEtAnalyse();
                                            setState(() {
                                              _afficherRapport = false;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        if (_stats != null)
                                          TextButton(
                                            child:
                                                const Text('Voir le rapport'),
                                            onPressed: () async {
                                              setState(() {
                                                _afficherRapport = true;
                                              });
                                              await _chargerStatsEtAnalyse(
                                                  chargerRapport: true);
                                            },
                                          ),
                                      ],
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
                        : _afficherRapport
                            ? _buildRapportQuestionnaire()
                            : _buildStatsQuestionnaire(),
      ),
    );
  }

  Widget _buildStatsQuestionnaire() {
    if (_stats == null || _stats!.isEmpty) {
      return const Text('Aucune statistique disponible pour ce questionnaire.');
    }
    // Pour chaque question, affiche un diagramme en bandes (barres horizontales) avec couleurs différentes
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.cyan,
      Colors.indigo,
      Colors.pink
    ];
    final List<Widget> chartWidgets = [];
    _stats!.forEach((question, occMapRaw) {
      final occMap = occMapRaw as Map<String, dynamic>;
      final repList = occMap.keys.toList();
      final barGroups = <BarChartGroupData>[];
      for (int x = 0; x < repList.length; x++) {
        final reponse = repList[x];
        final count = occMap[reponse];
        barGroups.add(BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: (count as num).toDouble(),
              color: colors[x % colors.length],
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          showingTooltipIndicators: [0],
        ));
      }
      chartWidgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(question,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final idx = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            repList.length > idx ? repList[idx] : '',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 5),
                barTouchData: BarTouchData(enabled: true),
                alignment: BarChartAlignment.spaceAround,
                maxY: (occMap.values
                        .map((e) => (e as num).toDouble())
                        .reduce((a, b) => a > b ? a : b) +
                    5),
                // Pour le diagramme en bande, on inverse l'orientation
                // Mais fl_chart ne supporte pas nativement les barres horizontales, donc on reste sur vertical mais avec couleurs
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ));
    });
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _questionnaireIdSelectionne = null;
                  _stats = null;
                  _analyse = null;
                  _afficherRapport = false;
                }),
              ),
              const Text('Statistiques des réponses',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...chartWidgets,
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              child: const Text('Voir le rapport'),
              onPressed: () async {
                setState(() {
                  _afficherRapport = true;
                });
                await _chargerStatsEtAnalyse(chargerRapport: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRapportQuestionnaire() {
    if (_analyse == null || !_analyse!.containsKey('analyse')) {
      return const Text('Aucun rapport disponible pour ce questionnaire.');
    }
    final rapport = _analyse!['analyse'];
    return SingleChildScrollView(
      child: Column(
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
              const Text('Rapport pédagogique',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(rapport ?? '', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
