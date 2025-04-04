import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/models/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://api.ridenow.example.com/api/v1/';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
        body: json.encode(data),
      );

      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<ApiResponse> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
        body: json.encode(data),
      );

      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  ApiResponse _processResponse(http.Response response) {
    try {
      final body = json.decode(response.body);
      final bool success =
          response.statusCode >= 200 && response.statusCode < 300;

      return ApiResponse(
        success: success,
        message: body['message'] ?? (success ? 'Thành công' : 'Lỗi'),
        data: body['data'],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi xử lý dữ liệu: ${e.toString()}',
        data: null,
      );
    }
  }
}
