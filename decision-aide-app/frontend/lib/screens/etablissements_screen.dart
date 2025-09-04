import 'package:flutter/material.dart';
import '../services/etablissement_service.dart';
import '../modeles/etablissement.dart';

class EtablissementsScreen extends StatefulWidget {
  const EtablissementsScreen({super.key});

  @override
  State<EtablissementsScreen> createState() => _EtablissementsScreenState();
}

class _EtablissementsScreenState extends State<EtablissementsScreen> {
  final EtablissementService _service = EtablissementService();
  late Future<List<EtablissementModele>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.lister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Établissements'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<EtablissementModele>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun établissement', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final etab = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: etab.actif ? Colors.green : Colors.orange,
                    child: Icon(
                      etab.actif ? Icons.check : Icons.pending,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    etab.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(etab.email),
                      Text('${etab.ville}, ${etab.region}'),
                      Text(
                        etab.actif ? 'Actif' : 'En attente d\'activation',
                        style: TextStyle(
                          color: etab.actif ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: Switch(
                    value: etab.actif,
                    onChanged: (value) async {
                      final success = await _service.activer(etab.id, value);
                      if (success) {
                        setState(() {
                          _future = _service.lister();
                        });
                      }
                    },
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
