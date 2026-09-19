import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<ProductProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      provider.loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          switch (provider.state) {
            case ViewState.loading:
              return const Center(child: CircularProgressIndicator());

            case ViewState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );

            case ViewState.empty:
              return const Center(child: Text('No products found.'));

            case ViewState.success:
              return ListView.builder(
                controller: _scrollController,
                itemCount: provider.products.length + 1,
                itemBuilder: (context, index) {
                  if (index == provider.products.length) {
                    return provider.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }

                  final product = provider.products[index];
                  return ListTile(
                    leading: Image.network(
                      product.thumbnail,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.title),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              );
          }
        },
      ),
    );
  }
}
