import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DummyJsonApi {
  DummyJsonApi({http.Client? client}) : _client = client ?? http.Client();
  static const _baseUrl = 'https://dummyjson.com';
  final http.Client _client;

  Future<ProductPage> getProducts({required int skip, required int limit, String query = ''}) async {
    final path = query.isEmpty ? '/products' : '/products/search';
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: {
      'limit': '$limit', 'skip': '$skip', if (query.isNotEmpty) 'q': query,
    });
    return ProductPage.fromJson(await _get(uri));
  }

  Future<Product> getProduct(int id) async => Product.fromJson(await _get(Uri.parse('$_baseUrl/products/$id')));

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) throw ApiException('The server returned ${response.statusCode}.');
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Could not load products. Check your connection.');
    }
  }
}
