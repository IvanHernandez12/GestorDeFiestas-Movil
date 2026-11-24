/*
 * @empresa Bigbitbyte
 * @autor Ivan Hernandez Hinojosa
 * @creado 24/noviembre/2026
 * @modificado 24/noviembre/2026
 * @descripción Consulta el endpoint público de invitaciones mediante el token QR.
 */

import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'http://192.168.1.14:8000/api';

  final http.Client _client;

  Future<Map<String, dynamic>> getGuestByQrToken(String qrToken) async {
    final token = qrToken.trim();
    if (token.isEmpty) {
      throw const ApiException('Ingresa el token de tu invitación.');
    }

    final encodedToken = Uri.encodeComponent(token);
    final response = await _client.get(
      Uri.parse('$_baseUrl/public/guest/$encodedToken'),
      headers: const {'Accept': 'application/json'},
    );

    Object? decodedBody;
    try {
      decodedBody = jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('El servidor devolvió una respuesta inválida.');
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decodedBody is Map<String, dynamic>) {
      return decodedBody;
    }

    final message = decodedBody is Map<String, dynamic>
        ? decodedBody['message'] as String?
        : null;
    throw ApiException(message ?? 'Invitación no encontrada.');
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
