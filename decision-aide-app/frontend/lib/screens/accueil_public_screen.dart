import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../modeles/decision.dart';
import '../routes.dart';

class AccueilPublicScreen extends StatefulWidget {
  const AccueilPublicScreen({super.key});

  @override
  State<AccueilPublicScreen> createState() => _AccueilPublicScreenState();
}

class _AccueilPublicScreenState extends State<AccueilPublicScreen> {
  final ApiService _api = ApiService();
  late Future<List<DecisionModele>> _decisionsFuture;

  @override
  void initState() {
    super.initState();
    _decisionsFuture = _chargerDecisionsPubliees();
  }

  Future<List<DecisionModele>> _chargerDecisionsPubliees() async {
    try {
      final res = await _api.get('/api/public/decisions');
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
        return data
            .map((e) => DecisionModele.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Erreur lors du chargement des décisions: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header avec navigation
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[700],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'SIAD Décision',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[500]!,
                      Colors.indigo[400]!,
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Système d\'Aide à la Décision',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RoutesApp.connexion),
                child: const Text(
                  'Connexion',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                    context, RoutesApp.inscriptionEtablissement),
                child: const Text(
                  "Inscription",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          // Section d'introduction
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenue sur SIAD Décision',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Le Système d\'Aide à la Décision est une plateforme innovante qui facilite '
                    'la prise de décisions pédagogiques basées sur des retours d\'expérience '
                    'et des analyses approfondies.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Cartes des fonctionnalités
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          'Programmes Ministériels',
                          Icons.description,
                          Colors.green,
                          'Découvrez les programmes et orientations publiés par le Ministère de l\'Éducation.',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          'Décisions Pédagogiques',
                          Icons.analytics,
                          Colors.orange,
                          'Consultez les décisions prises suite aux retours pédagogiques.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Section des décisions publiées
                  const Text(
                    'Décisions Récentes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Liste des décisions
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: FutureBuilder<List<DecisionModele>>(
              future: _decisionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                final decisions = snapshot.data ?? [];
                if (decisions.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.description,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucune décision publiée',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final decision = decisions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[600],
                            child: const Icon(Icons.description,
                                color: Colors.white),
                          ),
                          title: Text(
                            decision.titre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                decision.contenu,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    decision.publie
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 16,
                                    color: decision.publie
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    decision.publie ? 'Publié' : 'Non publié',
                                    style: TextStyle(
                                      color: decision.publie
                                          ? Colors.green
                                          : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Naviguer vers les détails de la décision
                          },
                        ),
                      );
                    },
                    childCount: decisions.length,
                  ),
                );
              },
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Accédez à votre espace',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Connectez-vous pour accéder à votre tableau de bord '
                    'et participer aux questionnaires pédagogiques.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, RoutesApp.connexion),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, IconData icon, Color color, String description) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
