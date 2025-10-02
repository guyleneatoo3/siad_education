import 'package:flutter/material.dart';
import '../services/decision_service.dart';

class RedigerDecisionScreen extends StatefulWidget {
  const RedigerDecisionScreen({super.key});

  @override
  State<RedigerDecisionScreen> createState() => _RedigerDecisionScreenState();
}

class _RedigerDecisionScreenState extends State<RedigerDecisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _contenuController = TextEditingController();
  bool _publie = true;
  bool _isLoading = false;

  Future<void> _submitDecision() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final titre = _titreController.text.trim();
    final contenu = _contenuController.text.trim();
    final success =
        await DecisionService().creerDecision(titre, contenu, _publie);
    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Décision publiée avec succès')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la publication')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rédiger une décision')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titreController,
                decoration: InputDecoration(
                  labelText: 'Titre de la décision',
                  hintText: 'Ex: Décision N° ... du ...',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contenuController,
                decoration: InputDecoration(
                  labelText: 'Contenu',
                  hintText:
                      'Rédigez la décision selon le style officiel (preambule, articles, signature...)',
                ),
                maxLines: 12,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Contenu requis' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon:
                    _isLoading ? CircularProgressIndicator() : Icon(Icons.send),
                label: Text('Publier la décision'),
                onPressed: _isLoading ? null : _submitDecision,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
