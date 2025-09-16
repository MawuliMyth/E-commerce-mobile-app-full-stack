import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../models/product_model.dart';
import '../widgets/product_card_widget.dart';

class ProductsScreen extends StatefulWidget {
  final String subcategoryId;
  final String subcategoryName;
  final String categoryName;

  const ProductsScreen({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.categoryName,
    required List<Product> products,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  static final Map<String, List<Product>> _cache = {}; // In-memory cache
  final CategoryController _categoryController = CategoryController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    if (_cache.containsKey(widget.subcategoryId)) {
      setState(() {
        products = _cache[widget.subcategoryId]!;
        isLoading = false;
      });
      return;
    }

    try {
      final categories = await _categoryController.fetchCategories();
      List<Product> foundProducts = [];

      // Find products for this subcategory
      for (var category in categories) {
        final subCategories = category.subCategories;
        for (var subCat in subCategories) {
          if (subCat.id == widget.subcategoryId) {
            foundProducts = subCat.products;
            break;
          }
        }
      }

      setState(() {
        products = foundProducts;
        isLoading = false;
        _cache[widget.subcategoryId] = foundProducts; // Cache the result
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching products: $e");
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

  // Filters products based on search input
  List<Product> get filteredProducts {
    if (_searchController.text.isEmpty) return products;

    return products.where((product) {
      final productName = product.name.toLowerCase();
      final searchTerm = _searchController.text.toLowerCase();
      return productName.contains(searchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: Text(widget.subcategoryName),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),

        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xff004CFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "Search for Products",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Breadcrumb
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "${widget.categoryName} > ${widget.subcategoryName}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                const Spacer(),
                Text(
                  "${filteredProducts.length} ${filteredProducts.length == 1 ? 'product' : 'products'}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No products found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try adjusting your search",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return ProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
