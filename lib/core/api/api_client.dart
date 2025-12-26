import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_constants.dart';

class ApiClient {
  final http.Client _client = http.Client();


  // Helper method for headers
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    final uri = Uri.parse(endpoint);
    try {
      final response = await _client.get(uri, headers: _getHeaders(token: token));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> postMultipart(
    String endpoint, 
    Map<String, String> fields, 
    {
      String? token, 
      File? file, 
      String? fileField,
    }
  ) async {
    final uri = Uri.parse(endpoint);
    try {
      final request = http.MultipartRequest('POST', uri);
      
      // Headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'text/plain'; // As per curl request

      // Fields
      request.fields.addAll(fields);

      // File
      if (file != null && fileField != null) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        
        // Determine Media Type
        final extension = file.path.split('.').last.toLowerCase();
        MediaType? contentType;
        
        if (extension == 'jpg' || extension == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (extension == 'png') {
          contentType = MediaType('image', 'png');
        }
        
        final multipartFile = http.MultipartFile(
          fileField,
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: contentType,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> putMultipart(
    String endpoint, 
    Map<String, String> fields, 
    {
      String? token, 
      File? file, 
      String? fileField,
    }
  ) async {
    final uri = Uri.parse(endpoint);
    try {
      final request = http.MultipartRequest('PUT', uri);
      
      // Headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'text/plain';

      // Fields
      request.fields.addAll(fields);

      // File
      if (file != null && fileField != null) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        
        // Determine Media Type
        final extension = file.path.split('.').last.toLowerCase();
        MediaType? contentType;
        
        if (extension == 'jpg' || extension == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (extension == 'png') {
          contentType = MediaType('image', 'png');
        }
        
        final multipartFile = http.MultipartFile(
          fileField,
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: contentType,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> postFormData(
    String endpoint, 
    Map<String, String> fields, 
    Map<String, File> files,
    {String? token}
  ) async {
    final uri = Uri.parse(endpoint);
    try {
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'text/plain';

      request.fields.addAll(fields);

      for (var entry in files.entries) {
        final file = entry.value;
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        
        final extension = file.path.split('.').last.toLowerCase();
        MediaType? contentType;
        if (extension == 'jpg' || extension == 'jpeg') {
          contentType = MediaType('image', 'jpeg');
        } else if (extension == 'png') {
          contentType = MediaType('image', 'png');
        }

        final multipartFile = http.MultipartFile(
          entry.key,
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: contentType,
        );
        request.files.add(multipartFile);
      }

      print("🚀 FormData Request to $uri");
      print("Fields: $fields");
      print("Files: ${files.keys.toList()}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print("📦 Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body; // Return plain text or whatever
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("❌ FormData Error: $e");
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final uri = Uri.parse(endpoint);
    print("---------------------------------------------");
    print("🚀 API REQUEST (POST)");
    print("URL: $uri");
    print("Headers: ${_getHeaders(token: token)}");
    print("Payload: ${jsonEncode(body)}");
    print("---------------------------------------------");

    try {
      final response = await _client.post(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      print("----------------------------------------------");
      print("📦 API RESPONSE");
      print("URL: $uri");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      print("----------------------------------------------");
      return _handleResponse(response);
    } catch (e) {
      print("----------------------------------------------");
      print("❌ API ERROR");
      print("URL: $uri");
      print("Error: $e");
      print("----------------------------------------------");
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final uri = Uri.parse(endpoint);
    print("---------------------------------------------------");
    print("🚀 API REQUEST (PUT)");
    print("URL: $uri");
    print("Headers: ${_getHeaders(token: token)}");
    print("Payload: ${jsonEncode(body)}");
    print("---------------------------------------------------");

    try {
      final response = await _client.put(
        uri,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );
      print("----------------------------------------------------");
      print("📦 API RESPONSE (PUT)");
      print("URL: $uri");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      print("----------------------------------------------------");
      return _handleResponse(response);
    } catch (e) {
      print("----------------------------------------------------");
      print("❌ API ERROR (PUT)");
      print("URL: $uri");
      print("Error: $e");
      print("----------------------------------------------------");
      rethrow;
    }
  }

  // Fetch Areas
  Future<List<dynamic>> fetchAreas({String? token}) async {
    try {
      final response = await get(ApiConstants.areas, token: token);
      if (response is List) {
        return response;
      } else {
        throw Exception('Invalid response format for areas');
      }
    } catch (e) {
      print('Error fetching areas: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {String? token}) async {
    final uri = Uri.parse(endpoint);
    try {
      final response = await _client.delete(uri, headers: _getHeaders(token: token));
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // If the body is empty, return null or an empty map
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        // If decoding fails (e.g. plain text response), return body as is
        return response.body;
      }
    } else {
      // Throw with body to allow ErrorHandler to parse validation errors
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
