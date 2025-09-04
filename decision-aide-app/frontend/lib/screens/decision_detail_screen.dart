import 'package:flutter/material.dart';

class DecisionDetailScreen extends StatelessWidget {
  const DecisionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Décision'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Détails de la décision', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Fonctionnalité à venir', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
