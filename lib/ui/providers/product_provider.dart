import 'dart:async';
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

  int _skip = 0;
  final int _limit = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  Timer? _debounce;
  String _searchQuery = '';

  Future<void> loadProducts() async {
    _state = ViewState.loading;
    _skip = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final result = await _repository.getProducts(limit: _limit, skip: _skip);
      _products = result;
      _skip = _limit;
      _hasMore = result.length == _limit;
      _state = _products.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }

    notifyListeners();
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getProducts(limit: _limit, skip: _skip);
      _products.addAll(result);
      _skip += _limit;
      _hasMore = result.length == _limit;
    } catch (e) {
      // Keep existing products if a page fails to load
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        loadProducts();
      } else {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final result = await _repository.searchProducts(query);
      _products = result;
      _hasMore = false;
      _state = _products.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
