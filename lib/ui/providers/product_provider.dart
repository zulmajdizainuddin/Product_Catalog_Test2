import 'package:flutter/foundation.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

enum ViewState { loading, error, empty, success }

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider(this._repository);

  ViewState _state = ViewState.loading;
  ViewState get state => _state;

  List<Product> _products = [];
  List<Product> get products => _products;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final result = await _repository.getProducts(limit: 20, skip: 0);
      _products = result;
      _state = _products.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }

    notifyListeners();
  }
}
