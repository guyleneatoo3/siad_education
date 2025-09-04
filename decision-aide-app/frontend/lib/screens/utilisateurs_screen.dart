import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../modeles/utilisateur.dart';

class UtilisateursScreen extends StatefulWidget {
  const UtilisateursScreen({super.key});

  @override
  State<UtilisateursScreen> createState() => _UtilisateursScreenState();
}

class _UtilisateursScreenState extends State<UtilisateursScreen> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.profilActuel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final profil = snap.data;
          if (profil == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Erreur de chargement', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.purple[600],
                              child: const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profil['nomComplet'] ?? 'Nom inconnu',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rôle: ${profil['role'] ?? 'Non défini'}',
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
                        const SizedBox(height: 16),
                        if (profil['email'] != null) ...[
                          _buildInfoRow('Email', profil['email']),
                          const SizedBox(height: 8),
                        ],
                        if (profil['matricule'] != null) ...[
                          _buildInfoRow('Matricule', profil['matricule']),
                          const SizedBox(height: 8),
                        ],
                        _buildInfoRow('Statut', profil['actif'] == true ? 'Actif' : 'Inactif'),
                        if (profil['etablissementNom'] != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow('Établissement', profil['etablissementNom']),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Fonctionnalités de gestion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _buildActionCard(
                        'Changer le mot de passe',
                        Icons.lock,
                        Colors.blue,
                        () {
                          // TODO: Implement password change
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fonctionnalité à venir')),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        'Paramètres du compte',
                        Icons.settings,
                        Colors.orange,
                        () {
                          // TODO: Implement account settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fonctionnalité à venir')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
