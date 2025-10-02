import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
import '../../services/etablissement_service.dart';
import '../../services/rapport_service.dart';
import '../../modeles/utilisateur.dart';
import '../../modeles/rapport.dart';

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
  Future<List<Map<String, dynamic>>>? _avisEnvoyesFuture;

  @override
  void initState() {
    super.initState();
    _profilFuture = _api.profilActuel();
    // Initialisation de la liste des avis envoyés (par défaut null, sera chargé après récupération du profil)
    _avisEnvoyesFuture = null;
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
          // Charger les avis envoyés si pas déjà fait
          if (_avisEnvoyesFuture == null && etabId != null) {
            _avisEnvoyesFuture =
                RapportService().listerAvis(etabId, "ETAB_TO_INSPECTION");
          }

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
                    _buildActionCard(
                      'Envoyer un commentaire à l\'inspection',
                      Icons.send,
                      Colors.red,
                      () => _showCommentDialog(context, etabId),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  'Avis envoyés à l\'inspection',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _avisEnvoyesFuture,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final avis = snap.data ?? [];
                    if (avis.isEmpty) {
                      return Text('Aucun avis envoyé pour ce rapport.');
                    }
                    return Column(
                      children: [
                        for (final a in avis)
                          Card(
                            child: ListTile(
                              title: Text(a['contenu'] ?? ''),
                              subtitle: Text('Auteur: ${a['auteurNom'] ?? ''}'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // ...existing code for rest of dashboard...
                SizedBox(height: 24),
                Text(
                  'Rapports d\'analyse',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                FutureBuilder<List<RapportAnalyseModele>>(
                  future: RapportService().lister(),
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final rapports = snap.data ?? [];
                    if (rapports.isEmpty) {
                      return Text('Aucun rapport d\'analyse disponible.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: rapports.length,
                      itemBuilder: (context, idx) {
                        final rapport = rapports[idx];
                        return Card(
                          child: ListTile(
                            title: Text(rapport.titre),
                            subtitle: Text(rapport.contenu.length > 60
                                ? rapport.contenu.substring(0, 60) + '...'
                                : rapport.contenu),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (ctx) => Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton.icon(
                                            icon: Icon(Icons.send),
                                            label: Text(
                                                'Partager à l\'inspection'),
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              _showCommentDialog(
                                                  context, rapport.id);
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
                            },
                          ),
                        );
                      },
                    );
                  },
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
          title: Text('Erreur'),
          content: Text(
              "Impossible d'ouvrir la gestion : identifiant établissement manquant dans le profil."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
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

  Future<void> _showCommentDialog(BuildContext context, int? etabId) async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Envoyer un commentaire à l\'inspection'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Votre commentaire'),
          maxLines: 4,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text('Envoyer')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      // TODO: Appeler le service pour envoyer le commentaire à l'inspection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commentaire envoyé à l\'inspection')),
      );
    }
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
                label: Text('Ajouter'),
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
                return Center(child: Text('Aucun utilisateur trouvé.'));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Nom complet')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Matricule')),
                    DataColumn(label: Text('Actif')),
                    DataColumn(label: Text('Actions')),
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
                title: Text('Actif'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Annuler'),
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
                    child: Text('Enregistrer'),
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
