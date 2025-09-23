import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
import '../../services/questionnaire_service.dart';
import '../../modeles/questionnaire.dart';

class DashboardEnseignant extends StatefulWidget {
  const DashboardEnseignant({super.key});

  @override
  State<DashboardEnseignant> createState() => _DashboardEnseignantState();
}

class _DashboardEnseignantState extends State<DashboardEnseignant> {
  // ...existing code...
  // Vérifie s'il y a un questionnaire à remplir pour l'enseignant
  Future<QuestionnaireModele?> _checkNotification() async {
    final list = await QuestionnaireService().listerFiltresParRole();
    if (list.isNotEmpty) {
      // TODO: filtrer ceux déjà répondus par l'enseignant si besoin
      return list.first;
    }
    return null;
  }

  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>?> _profilFuture;
  Future<QuestionnaireModele?> _notifQuestionnaireFuture = Future.value(null);

  @override
  void initState() {
    super.initState();
    _profilFuture = _api.profilActuel();
    _notifQuestionnaireFuture = _checkNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord - Enseignant'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<QuestionnaireModele?>(
            future: _notifQuestionnaireFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }
              final q = snap.data;
              if (q != null) {
                return IconButton(
                  icon:
                      const Icon(Icons.notifications_active, color: Colors.red),
                  tooltip: 'Nouveau questionnaire à remplir',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Nouveau questionnaire : ${q.titre}')),
                    );
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.notifications_none),
                  tooltip: 'Aucune nouvelle notification',
                  onPressed: () {},
                );
              }
            },
          ),
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
          final nomComplet = profil?['nomComplet'] ?? 'Enseignant';

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
                          backgroundColor: Colors.indigo[600],
                          child: const Icon(Icons.person,
                              size: 30, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour, $nomComplet',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Enseignant',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
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
                  'Mes Actions',
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
                      'Questionnaires',
                      Icons.assignment,
                      Colors.blue,
                      () => Navigator.pushNamed(
                          context, RoutesApp.questionnaires),
                    ),
                    _buildActionCard(
                      'Décisions publiées',
                      Icons.campaign,
                      Colors.orange,
                      () => Navigator.pushNamed(context, RoutesApp.decisions),
                    ),
                    // Affiche les réponses soumises par l'enseignant connecté
                    _buildActionCard(
                      'Mes réponses',
                      Icons.assignment_turned_in,
                      Colors.green,
                      () => Navigator.pushNamed(context, RoutesApp.reponses),
                    ),
                    _buildActionCard(
                      'Mon profil',
                      Icons.person,
                      Colors.purple,
                      () =>
                          Navigator.pushNamed(context, RoutesApp.utilisateurs),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section des statistiques
                const Text(
                  'Mes Statistiques',
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
                        'Questionnaires',
                        '0',
                        Icons.assignment,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Réponses',
                        '0',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
