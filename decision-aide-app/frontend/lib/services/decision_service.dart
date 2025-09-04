import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../modeles/decision.dart';

class DecisionService {
  final ApiService _api = ApiService();

  Future<List<DecisionModele>> lister() async {
    final http.Response res = await _api.get('/api/decisions');
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => DecisionModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<DecisionModele>> listerPubliques() async {
    final url = Uri.parse('${ApiService.baseUrl}/api/public/decisions');
    final res =
        await http.get(url, headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => DecisionModele.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
