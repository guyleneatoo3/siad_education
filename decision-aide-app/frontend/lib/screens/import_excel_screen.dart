import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/import_service.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  final ImportService _importService = ImportService();
  bool _isLoading = false;
  String? _selectedFilePath;
  String _importType = 'eleves'; // 'eleves' ou 'enseignants'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Excel'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection du type d'import
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type d\'import',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Élèves'),
                            value: 'eleves',
                            groupValue: _importType,
                            onChanged: (value) {
                              setState(() {
                                _importType = value!;
                                _selectedFilePath = null;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Enseignants'),
                            value: 'enseignants',
                            groupValue: _importType,
                            onChanged: (value) {
                              setState(() {
                                _importType = value!;
                                _selectedFilePath = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_importType == 'eleves') ...[
                      const Text(
                        'Format du fichier Excel pour les élèves:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Colonne A: Matricule'),
                      const Text('• Colonne B: Classe'),
                      const Text(
                          '• Colonne C: Filière (à partir de la seconde)'),
                    ] else ...[
                      const Text(
                        'Format du fichier Excel pour les enseignants:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Colonne A: Email'),
                      const Text('• Colonne B: Matière'),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Note: La première ligne doit contenir les en-têtes.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sélection de fichier
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sélectionner un fichier',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _selectFile,
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Choisir un fichier Excel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                (_selectedFilePath != null && !_isLoading)
                                    ? _importerFichier
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Importer'),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedFilePath != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Fichier sélectionné: ${_selectedFilePath!.split('/').last}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFilePath = result.files.first.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection du fichier: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importerFichier() async {
    if (_selectedFilePath == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      File file = File(_selectedFilePath!);
      Map<String, dynamic> resultat;

      if (_importType == 'eleves') {
        resultat = await _importService.importerEleves(file);
      } else {
        resultat = await _importService.importerEnseignants(file);
      }

      setState(() {
        _isLoading = false;
      });

      if (resultat.containsKey('erreur')) {
        _afficherErreur(resultat['erreur']);
      } else {
        _afficherSucces(resultat);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _afficherErreur('Erreur lors de l\'import: $e');
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _afficherSucces(Map<String, dynamic> resultat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import réussi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total importé: ${resultat['totalImportes']}'),
            const SizedBox(height: 16),
            if (resultat['succes'] != null) ...[
              const Text('Succès:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(resultat['succes'] as List).take(5).map((s) => Text('• $s')),
              if ((resultat['succes'] as List).length > 5)
                Text(
                    '... et ${(resultat['succes'] as List).length - 5} autres'),
            ],
            if (resultat['erreurs'] != null &&
                (resultat['erreurs'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Erreurs:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              ...(resultat['erreurs'] as List).take(3).map((e) =>
                  Text('• $e', style: const TextStyle(color: Colors.red))),
              if ((resultat['erreurs'] as List).length > 3)
                Text(
                    '... et ${(resultat['erreurs'] as List).length - 3} autres erreurs',
                    style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedFilePath = null;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
