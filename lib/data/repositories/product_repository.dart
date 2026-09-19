import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductRepository {
  final ProductApiService _apiService;

  ProductRepository(this._apiService);

  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) {
    return _apiService.fetchProducts(limit: limit, skip: skip);
  }
}
