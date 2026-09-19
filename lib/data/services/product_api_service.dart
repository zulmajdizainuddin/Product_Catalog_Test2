import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  // Fetches a page of products using limit + skip for pagination
  Future<List<Product>> fetchProducts({int limit = 20, int skip = 0}) async {
    final url = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> productsJson = data['products'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load products (status ${response.statusCode})');
    }
  }
}
