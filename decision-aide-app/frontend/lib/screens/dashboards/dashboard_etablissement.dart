import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../services/api_service.dart';

import '../../services/etablissement_service.dart';
import '../../modeles/utilisateur.dart';

class DashboardEtablissement extends StatefulWidget {
  const DashboardEtablissement({super.key});

  @override
  State<DashboardEtablissement> createState() => _DashboardEtablissementState();
}

class _DashboardEtablissementState extends State<DashboardEtablissement> {
  // ... existing methods ...

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
        title: const Text('Tableau de bord - Établissement'),
        backgroundColor: Colors.blue[700],
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
          final nomComplet = profil?['nomComplet'] ?? 'Établissement';
          final etablissementNom =
              profil?['etablissementNom'] ?? 'Établissement';
          final etabId = profil?['etablissementId'];

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
                          backgroundColor: Colors.blue[600],
                          child: const Icon(Icons.school,
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
                                etablissementNom,
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
                  'Gestion de l\'Établissement',
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
                      'Gérer les élèves',
                      Icons.school,
                      Colors.green,
                      () => _showCrudDialog(context, 'eleve', etabId),
                    ),
                    _buildActionCard(
                      'Gérer les enseignants',
                      Icons.person,
                      Colors.indigo,
                      () => _showCrudDialog(context, 'enseignant', etabId),
                    ),
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
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCrudDialog(BuildContext context, String type, int? etabId) {
    if (etabId == null) {
      // Affiche une erreur si l'id établissement est absent
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text(
              "Impossible d'ouvrir la gestion : identifiant établissement manquant dans le profil."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // Log pour debug
    // ignore: avoid_print
    print('Ouverture CRUD $type pour etabId=$etabId');
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 700,
          child: _CrudTable(type: type, etabId: etabId),
        ),
      ),
    );
  }
}

class _CrudTable extends StatefulWidget {
  final String type; // 'eleve' ou 'enseignant'
  final int etabId;
  const _CrudTable({required this.type, required this.etabId});

  @override
  State<_CrudTable> createState() => _CrudTableState();
}

class _CrudTableState extends State<_CrudTable> {
  late Future<List<UtilisateurModele>> _futureList;
  final _service = EtablissementService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futureList = widget.type == 'eleve'
          ? _service.listerEleves(widget.etabId)
          : _service.listerEnseignants(widget.etabId);
    });
  }

  void _editUser(BuildContext context, [UtilisateurModele? user]) async {
    final isEleve = widget.type == 'eleve';
    final result = await showDialog<UtilisateurModele>(
      context: context,
      builder: (context) => _UserEditDialog(user: user, isEleve: isEleve),
    );
    if (result != null) {
      if (user == null) {
        // Ajout
        if (isEleve) {
          await _service.ajouterEleve(widget.etabId, result);
        } else {
          await _service.ajouterEnseignant(widget.etabId, result);
        }
      } else {
        // Edition
        if (isEleve) {
          await _service.modifierEleve(widget.etabId, result);
        } else {
          await _service.modifierEnseignant(widget.etabId, result);
        }
      }
      _load();
    }
  }

  void _deleteUser(int id) async {
    final isEleve = widget.type == 'eleve';
    if (isEleve) {
      await _service.supprimerEleve(widget.etabId, id);
    } else {
      await _service.supprimerEnseignant(widget.etabId, id);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isEleve = widget.type == 'eleve';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEleve ? 'Gestion des élèves' : 'Gestion des enseignants',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _editUser(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<UtilisateurModele>>(
            future: _futureList,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final users = snap.data!;
              if (users.isEmpty) {
                return const Center(child: Text('Aucun utilisateur trouvé.'));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Nom complet')),
                    const DataColumn(label: Text('Email')),
                    const DataColumn(label: Text('Matricule')),
                    const DataColumn(label: Text('Actif')),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: users
                      .map((u) => DataRow(cells: [
                            DataCell(Text(u.nomComplet)),
                            DataCell(Text(u.email ?? '')),
                            DataCell(Text(u.matricule ?? '')),
                            DataCell(Icon(u.actif ? Icons.check : Icons.close,
                                color: u.actif ? Colors.green : Colors.red)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Modifier',
                                  onPressed: () => _editUser(context, u),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Supprimer',
                                  onPressed: () => _deleteUser(u.id),
                                ),
                              ],
                            )),
                          ]))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UserEditDialog extends StatefulWidget {
  final UtilisateurModele? user;
  final bool isEleve;
  const _UserEditDialog({this.user, required this.isEleve});

  @override
  State<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<_UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _matriculeController;
  bool _actif = true;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.user?.nomComplet ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _matriculeController =
        TextEditingController(text: widget.user?.matricule ?? '');
    _actif = widget.user?.actif ?? true;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.user == null
                    ? (widget.isEleve
                        ? 'Ajouter un élève'
                        : 'Ajouter un enseignant')
                    : (widget.isEleve
                        ? 'Modifier un élève'
                        : 'Modifier un enseignant'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _matriculeController,
                decoration: const InputDecoration(labelText: 'Matricule'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _actif,
                onChanged: (v) => setState(() => _actif = v),
                title: const Text('Actif'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(
                          context,
                          UtilisateurModele(
                            id: widget.user?.id ?? 0,
                            nomComplet: _nomController.text,
                            email: _emailController.text,
                            matricule: _matriculeController.text,
                            role: widget.isEleve ? 'ELEVE' : 'ENSEIGNANT',
                            actif: _actif,
                            etablissementNom: null,
                          ),
                        );
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
