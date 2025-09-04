import 'package:flutter/material.dart';
import '../services/decision_service.dart';
import '../modeles/decision.dart';

class DecisionsScreen extends StatefulWidget {
  const DecisionsScreen({super.key});

  @override
  State<DecisionsScreen> createState() => _DecisionsScreenState();
}

class _DecisionsScreenState extends State<DecisionsScreen> {
  final DecisionService _service = DecisionService();
  late Future<List<DecisionModele>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.lister();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Décisions publiées')),
      body: FutureBuilder<List<DecisionModele>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Aucune décision'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = items[i];
              return ListTile(
                title: Text(d.titre),
                subtitle: Text(d.contenu,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              );
            },
          );
        },
      ),
    );
  }
}
