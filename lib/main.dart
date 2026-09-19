import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/product_api_service.dart';
import 'data/repositories/product_repository.dart';
import 'ui/providers/product_provider.dart';
import 'ui/screens/product_list_screen.dart';

void main() {
  final apiService = ProductApiService();
  final repository = ProductRepository(apiService);
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ProductRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(repository)..loadProducts(),
      child: MaterialApp(
        title: 'Product Catalog',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF7043),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF8F5),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const ProductListScreen(),
      ),
    );
  }
}
