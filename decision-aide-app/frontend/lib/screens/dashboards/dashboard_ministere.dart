  import 'package:decision_aide_frontend/services/rapport_service.dart';
import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../services/api_service.dart';

  Future<List<Map<String, dynamic>>>? _commentairesInspectionFuture;

  void _chargerCommentairesInspection(int rapportId) {
    setState(() {
      _commentairesInspectionFuture = RapportService().listerCommentairesInspection(rapportId);
    });
  }
  
  void setState(Null Function() param0) {
  }

class DashboardMinistere extends StatefulWidget {
  const DashboardMinistere({super.key});

  @override
  State<DashboardMinistere> createState() => _DashboardMinistereState();
}

class _DashboardMinistereState extends State<DashboardMinistere> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>?> _profilFuture;

  @override
  void initState() {
    super.initState();
    _profilFuture = _api.profilActuel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord - Ministère'),
        backgroundColor: Colors.deepPurple[700],
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
          final nomComplet = profil?['nomComplet'] ?? 'Ministère';

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
                          backgroundColor: Colors.deepPurple[600],
                          child: const Icon(Icons.account_balance,
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
                                'Ministère de l\'Éducation',
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
                  // Section des avis de l'inspection
                  const Text(
                    'Avis de l\'inspection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _commentairesInspectionFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final commentaires = snap.data ?? [];
                      if (commentaires.isEmpty) {
                        return const Text('Aucun avis de l\'inspection pour ce rapport.');
                      }
                      return Column(
                        children: commentaires.map((c) => Card(
                          child: ListTile(
                            title: Text(c['commentaire'] ?? ''),
                            subtitle: Text('Inspection: ${c['inspectionNom'] ?? ''}'),
                          ),
                        )).toList(),
                      );
                    },
                  ),

                // Section des actions principales
                const Text(
                  'Gestion Ministérielle',
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
                      'Décisions et rapports',
                      Icons.description,
                      Colors.blue,
                      () => Navigator.pushNamed(context, RoutesApp.decisions),
                    ),
                    _buildActionCard(
                      'Rapports d\'analyse',
                      Icons.analytics,
                      Colors.teal,
                      () => Navigator.pushNamed(context, RoutesApp.rapports),
                    ),
                    _buildActionCard(
                      'Modifier mon profil',
                      Icons.edit,
                      Colors.purple,
                      () =>
                          Navigator.pushNamed(context, RoutesApp.utilisateurs),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section des statistiques
                const Text(
                  'Statistiques Ministérielles',
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
                        'Décisions',
                        '0',
                        Icons.description,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Rapports',
                        '0',
                        Icons.analytics,
                        Colors.teal,
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
