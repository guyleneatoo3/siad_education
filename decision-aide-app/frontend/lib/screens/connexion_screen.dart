import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../routes.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantCtrl = TextEditingController();
  final _motDePasseCtrl = TextEditingController();
  bool _chargement = false;
  String? _erreur;

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    final api = ApiService();
    final res = await api.connexion(
      _identifiantCtrl.text.trim(),
      _motDePasseCtrl.text,
    );
    setState(() {
      _chargement = false;
    });
    if (res != null) {
      // Récupérer le profil pour déterminer le rôle et router
      final profil = await api.profilActuel();
      if (!mounted) return;
      if (profil != null) {
        final role = (profil['role'] as String? ?? '').toUpperCase();
        Navigator.of(context).pushReplacementNamed(
          RoutesApp.tableauBordParRole(role),
          arguments: profil,
        );
      } else {
        Navigator.of(context).pushReplacementNamed(RoutesApp.tableauBord);
      }
    } else {
      setState(() {
        _erreur = 'Identifiants invalides';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _identifiantCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email ou Matricule',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _motDePasseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                    ),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_erreur != null)
                    Text(_erreur!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _chargement ? null : _seConnecter,
                      child: _chargement
                          ? const CircularProgressIndicator()
                          : const Text('Se connecter'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
