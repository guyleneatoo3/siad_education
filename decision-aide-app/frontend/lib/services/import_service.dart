import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ImportService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> importerEleves(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/import/eleves'),
      );

      // Ajouter le token d'authentification
      final token = await _api.lireJeton();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Ajouter le fichier
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData) as Map<String, dynamic>;
      } else {
        return {
          'erreur': 'Erreur lors de l\'import: ${response.statusCode}',
          'details': responseData,
        };
      }
    } catch (e) {
      return {
        'erreur': 'Erreur de connexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> importerEnseignants(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/import/enseignants'),
      );

      // Ajouter le token d'authentification
      final token = await _api.lireJeton();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Ajouter le fichier
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData) as Map<String, dynamic>;
      } else {
        return {
          'erreur': 'Erreur lors de l\'import: ${response.statusCode}',
          'details': responseData,
        };
      }
    } catch (e) {
      return {
        'erreur': 'Erreur de connexion: $e',
      };
    }
  }
}
