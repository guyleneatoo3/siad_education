import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
import '../../services/rapport_service.dart';
import '../../modeles/rapport.dart';
import 'analyse_reponses_inspection_screen.dart';
import 'inspector_questionnaires_screen.dart';

class DashboardInspection extends StatefulWidget {
  const DashboardInspection({super.key});

  @override
  State<DashboardInspection> createState() => _DashboardInspectionState();
}

class _DashboardInspectionState extends State<DashboardInspection> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>?> _profilFuture;
  late Future<Map<String, dynamic>> _statsFuture;
  Future<List<Map<String, dynamic>>>? _commentairesFuture;

  @override
  void initState() {
    super.initState();
    _profilFuture = _api.profilActuel();
    _statsFuture = _api.getStatsDashboardInspection();
    // Les commentaires sont chargés après sélection d'un rapport
    _commentairesFuture = null;
  }

  void _chargerCommentaires(int rapportId) {
    setState(() {
      _commentairesFuture =
          RapportService().listerCommentairesEtablissements(rapportId);
    });
  }

  Future<void> _showCommentDialog(BuildContext context, int? rapportId) async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rédiger un avis à envoyer au ministère'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Votre avis'),
          maxLines: 4,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null), child: Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text('Envoyer')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty && rapportId != null) {
      final success = await RapportService()
          .envoyerCommentaireAuMinistere(rapportId, result.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Avis envoyé au ministère'
              : 'Échec de l\'envoi de l\'avis'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord - Inspection'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                Navigator.pushNamed(context, RoutesApp.utilisateurs),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, RoutesApp.connexion, (route) => false);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profilFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final profil = snap.data;
          final nomComplet = profil?['nomComplet'] ?? 'Inspecteur';

          return FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, statsSnap) {
              if (statsSnap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = statsSnap.data ?? {};
              final nbEtab = stats['etablissements']?.toString() ?? '0';
              final nbQuest = stats['questionnaires']?.toString() ?? '0';
              final nbRep = stats['reponses']?.toString() ?? '0';
              final nbRap = stats['rapports']?.toString() ?? '0';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec profil
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.teal[700],
                              child: const Icon(Icons.person,
                                  size: 40, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenue, $nomComplet',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FutureBuilder<String>(
                                    future: _api.getRoleUtilisateur(),
                                    builder: (context, roleSnap) {
                                      if (roleSnap.connectionState !=
                                          ConnectionState.done) {
                                        return const Text(
                                            'Chargement du rôle...');
                                      }
                                      final role =
                                          roleSnap.data ?? 'Inspecteur';
                                      return Text(
                                        'Rôle: $role',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section des actions principales
                    const Text(
                      'Actions d\'Inspection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grille des actions
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildActionCard(
                          'Valider établissements',
                          Icons.verified_user,
                          Colors.green,
                          () => Navigator.pushNamed(
                              context, RoutesApp.etablissements),
                        ),
                        _buildActionCard(
                          'Questionnaires',
                          Icons.assignment,
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InspectorQuestionnairesScreen(),
                            ),
                          ),
                        ),
                        // Bloc rapports d'analyse
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                const Text(
                                  'Rapports d\'analyse',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: FutureBuilder<List<RapportAnalyseModele>>(
                                    future: RapportService().lister(),
                                    builder: (context, snap) {
                                      if (snap.connectionState != ConnectionState.done) {
                                        return Center(child: CircularProgressIndicator());
                                      }
                                      final rapports = snap.data ?? [];
                                      if (rapports.isEmpty) {
                                        return Text('Aucun rapport disponible.');
                                      }
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: rapports.length,
                                        itemBuilder: (context, idx) {
                                          final rapport = rapports[idx];
                                          return Card(
                                            child: ListTile(
                                              title: Text(rapport.titre),
                                              subtitle: Text(
                                                rapport.contenu.length > 60
                                                    ? rapport.contenu.substring(0, 60) + '...'
                                                    : rapport.contenu,
                                              ),
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (ctx) => Padding(
                                                    padding: const EdgeInsets.all(24),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          rapport.titre,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        SizedBox(height: 12),
                                                        Text(rapport.contenu),
                                                        SizedBox(height: 24),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            ElevatedButton.icon(
                                                              icon: Icon(Icons.send),
                                                              label: Text('Partager au ministère'),
                                                              onPressed: () {
                                                                Navigator.pop(ctx);
                                                                _showCommentDialog(context, rapport.id);
                                                              },
                                                            ),
                                                            SizedBox(width: 24),
                                                            OutlinedButton(
                                                              child: Text('Ne pas partager'),
                                                              onPressed: () => Navigator.pop(ctx),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                                // Charger les commentaires pour ce rapport
                                                _chargerCommentaires(rapport.id);
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
                          ),
                        ),
                        _buildActionCard(
                          'Décisions publiées',
                          Icons.campaign,
                          Colors.orange,
                          () =>
                              Navigator.pushNamed(context, RoutesApp.decisions),
                        ),
                        _buildActionCard(
                          'Réponses',
                          Icons.assignment_turned_in,
                          Colors.indigo,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AnalyseReponsesInspectionScreen(api: _api),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          'Test Mistral',
                          Icons.psychology,
                          Colors.purple,
                          () => Navigator.pushNamed(
                              context, RoutesApp.mistralTest),
                        ),
                        _buildActionCard(
                          'Mon profil',
                          Icons.person,
                          Colors.grey,
                          () => Navigator.pushNamed(
                              context, RoutesApp.utilisateurs),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section des statistiques
                    const Text(
                      'Statistiques d\'Inspection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Établissements',
                            nbEtab,
                            Icons.school,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildStatCard(
                          'Questionnaires',
                          nbQuest,
                          Icons.assignment,
                          Colors.blue,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Rapports',
                            nbRap,
                            Icons.analytics,
                            Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Réponses',
                            nbRep,
                            Icons.check_circle,
                            Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Section des avis reçus des établissements
                    const Text(
                      'Avis reçus des établissements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _commentairesFuture,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final commentaires = snap.data ?? [];
                        if (commentaires.isEmpty) {
                          return const Text('Aucun avis reçu pour ce rapport.');
                        }
                        return Column(
                          children: commentaires
                              .map((c) => Card(
                                    child: ListTile(
                                      title: Text(c['commentaire'] ?? ''),
                                      subtitle: Text(
                                          'Établissement: ${c['etablissementNom'] ?? ''}'),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color,
                child: Icon(icon, size: 25, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
