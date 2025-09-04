import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/questionnaire.dart';

class QuestionnaireService {
  final ApiService _api = ApiService();

  Future<List<QuestionnaireModele>> lister() async {
    final http.Response res = await _api.get('/api/questionnaires');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => QuestionnaireModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
