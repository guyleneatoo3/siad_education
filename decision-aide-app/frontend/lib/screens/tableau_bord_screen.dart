import 'package:flutter/material.dart';
import '../routes.dart';

class TableauBordScreen extends StatelessWidget {
  const TableauBordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Voir décisions publiées'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, RoutesApp.decisions),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Liste des questionnaires'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, RoutesApp.questionnaires),
          ),
        ],
      ),
    );
  }
}
