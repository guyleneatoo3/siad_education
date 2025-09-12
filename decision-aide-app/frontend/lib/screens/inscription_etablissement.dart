import 'package:flutter/material.dart';
import '../../services/etablissement_service.dart';
import '../../modeles/etablissement.dart';

class InscriptionEtablissementPage extends StatefulWidget {
  const InscriptionEtablissementPage({super.key});

  @override
  State<InscriptionEtablissementPage> createState() =>
      _InscriptionEtablissementPageState();
}

class _InscriptionEtablissementPageState
    extends State<InscriptionEtablissementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _villeController = TextEditingController();
  final _regionController = TextEditingController();
  final _arrondissementController = TextEditingController();
  final _departementController = TextEditingController();
  final _motDePasseController = TextEditingController();
  bool _enCours = false;
  String? _message;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _villeController.dispose();
    _regionController.dispose();
    _arrondissementController.dispose();
    _departementController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _inscrire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _message = null;
    });
    try {
      final etab = EtablissementModele(
        id: 0,
        nom: _nomController.text,
        email: _emailController.text,
        ville: _villeController.text,
        arrondissement: _arrondissementController.text,
        departement: _departementController.text,
        region: _regionController.text,
        actif: false, // sera activé par l'inspection
      );
      final service = EtablissementService();
      final reponse =
          await service.inscrireEtablissement(etab, _motDePasseController.text);
      if (reponse) {
        setState(() {
          _message =
              "Inscription réussie ! Votre compte sera activé par l'inspection.";
        });
      } else {
        setState(() {
          _message = "Erreur lors de l'inscription. Veuillez réessayer.";
        });
      }
    } catch (e) {
      setState(() {
        // Affiche le message d'erreur du backend si disponible
        _message = e is Exception
            ? (e.toString().replaceFirst('Exception: ', ''))
            : "Erreur : $e";
      });
    } finally {
      setState(() {
        _enCours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription Établissement")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                      labelText: 'Nom de l\'établissement'),
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
                  controller: _villeController,
                  decoration: const InputDecoration(labelText: 'Ville'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _regionController,
                  decoration: const InputDecoration(labelText: 'Région'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _arrondissementController,
                  decoration:
                      const InputDecoration(labelText: 'Arrondissement'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _departementController,
                  decoration: const InputDecoration(labelText: 'Département'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motDePasseController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? '6 caractères minimum' : null,
                ),
                const SizedBox(height: 24),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_message!,
                        style: TextStyle(
                            color: _message!.contains('réussie')
                                ? Colors.green
                                : Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: _enCours ? null : _inscrire,
                  child: _enCours
                      ? const CircularProgressIndicator()
                      : const Text('S\'inscrire'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
