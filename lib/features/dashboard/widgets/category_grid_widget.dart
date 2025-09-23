import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../category_provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../views/subcategory_products_view.dart';

class CategoriesView extends StatefulWidget {
  static const String id = 'categories_view';
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        // Show loading spinner first—const for perf
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // New: Handle errors explicitly in UI
        if (provider.errorMessage != null) {
          return Center(child: Text(provider.errorMessage!));
        }

        final categories = provider.validCategories;

        if (categories.isEmpty) {
          return const Center(child: Text("No categories with products found"));
        }

        return SingleChildScrollView(
          physics:ScrollPhysics() ,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return buildCategoryCard(categories[index]);
            },
          ),
        );
      },
    );
  }

  Widget buildCategoryCard(Category category) {
    final subCategory = category.subCategories.firstWhere(
      (sub) => sub.products.isNotEmpty,
      orElse: () => SubCategory(id: '', name: '', products: []),
    );

    if (subCategory.products.isEmpty) {
      return const SizedBox.shrink();
    }

    final allProducts = subCategory.products;

    Map<String, List<Product>> productsByBrand = {};
    for (var product in allProducts) {
      final brandName = "Brand";
      productsByBrand.putIfAbsent(brandName, () => []).add(product);
    }

    List<String> selectedImages = [];
    final random = Random();
    final brandNames = productsByBrand.keys.toList()..shuffle(random);

    if (brandNames.length == 1) {
      List<String> allImages = [];
      for (var product in productsByBrand[brandNames.first]!) {
        allImages.addAll(product.images);
      }
      allImages.shuffle(random);
      selectedImages = allImages.take(4).toList();
    } else {
      for (String brandName in brandNames) {
        if (selectedImages.length >= 4) break;
        final brandProducts = productsByBrand[brandName]!..shuffle(random);
        if (brandProducts.isNotEmpty && brandProducts.first.images.isNotEmpty) {
          final product = brandProducts.first;
          final img = product.images[random.nextInt(product.images.length)];
          selectedImages.add(img);
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate to category products view
        Navigator.pushNamed(
          context,
          subcategoryProductsView.id, // You'll need to define this route
          arguments: {
            'category': category,
            'products': _getAllProductsInCategory(category),
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: selectedImages.length.clamp(0, 4),
                  itemBuilder: (context, index) {
                    final img = selectedImages[index].isNotEmpty
                        ? selectedImages[index]
                        : "https://via.placeholder.com/150";
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(img, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xffDFE9FF),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      child: Text(
                        "${category.totalProducts}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get all products in a category
  List<Product> _getAllProductsInCategory(Category category) {
    List<Product> allProducts = [];
    for (var subCategory in category.subCategories) {
      allProducts.addAll(subCategory.products);
    }
    return allProducts;
  }
}
