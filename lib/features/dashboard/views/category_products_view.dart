import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import 'product_details_view.dart';

// View for displaying all products in a category
class CategoryProductsScreen extends StatefulWidget {
  static const String id = 'category_products_screen';
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;
  final ProductController _productController = ProductController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Loads products for the category
  Future<void> _loadProducts() async {
    try {
      final fetchedProducts = await _productController.fetchProductsByCategory(widget.categoryId);
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        backgroundColor:Theme.of(context).appBarTheme.backgroundColor ,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? Center(
        child: Text(
          "No products found in ${widget.categoryName}",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: product.images.isNotEmpty
                  ? Image.network(
                product.images[0],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image_not_supported),
              title: Text(product.name),
              subtitle: Text(
                product.flashSale != null
                    ? 'Flash Sale: \$${product.flashSale!.flashSalePrice}'
                    : '\$${product.price}',
                style: TextStyle(
                  color: product.flashSale != null ? Colors.red : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(product: product),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}