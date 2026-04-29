import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/product.dart';

class ProductApi {
  static const _baseUrl = 'https://dummyjson.com';
  static const _timeout = Duration(seconds: 10);

  Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/products?limit=30'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar produtos: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = data['products'] as List<dynamic>;
    return rawProducts
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
