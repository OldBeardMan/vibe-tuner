import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibe_tuner/constants/app_paths.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._private();

  static final ApiClient instance = ApiClient._private();

  String baseUrl = AppPaths.baseURL;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _defaultHeaders({Map<String, String>? headers}) {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    if (headers != null) {
      h.addAll(headers);
    }
    return h;
  }

  Uri _uri(String path) {
    if (path.startsWith('http')) return Uri.parse(path);
    return Uri.parse(baseUrl + path);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final uri = _uri(path);
    final res = await http.post(uri, headers: _defaultHeaders(headers: headers), body: body == null ? null : jsonEncode(body));
    return _processResponse(res);
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? headers}) async {
    final uri = _uri(path);
    final res = await http.get(uri, headers: _defaultHeaders(headers: headers));
    return _processResponse(res);
  }

  Map<String, dynamic> _processResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      try {
        final j = jsonDecode(res.body);
        if (j is Map<String, dynamic>) return j;
        return {'_data': j};
      } catch (e) {
        return {'_raw': res.body};
      }
    } else {
      String message = 'HTTP ${res.statusCode}';
      try {
        final j = jsonDecode(res.body);
        if (j is Map && j['message'] != null) message = j['message'].toString();
      } catch (_) {}
      throw ApiException(message, res.statusCode);
    }
  }
}
