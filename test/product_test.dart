import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('creates a Product from valid JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'price': 9.99,
        'thumbnail': 'https://example.com/thumb.jpg',
        'description': 'A test description',
        'rating': 4.5,
        'images': ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.price, 9.99);
      expect(product.rating, 4.5);
      expect(product.images.length, 2);
    });

    test('handles missing images with an empty list', () {
      final json = {
        'id': 2,
        'title': 'No Images Product',
        'price': 5,
        'thumbnail': 'https://example.com/thumb.jpg',
        'description': 'No images here',
        'rating': 3,
      };

      final product = Product.fromJson(json);

      expect(product.images, isEmpty);
      expect(product.price, 5.0);
    });
  });
}
