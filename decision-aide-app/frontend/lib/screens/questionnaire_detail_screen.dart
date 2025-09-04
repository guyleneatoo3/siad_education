import 'package:flutter/material.dart';

class QuestionnaireDetailScreen extends StatelessWidget {
  const QuestionnaireDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Questionnaire'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Détails du questionnaire', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Fonctionnalité à venir', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
