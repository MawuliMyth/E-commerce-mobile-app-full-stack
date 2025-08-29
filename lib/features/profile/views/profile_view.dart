import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/category_controller.dart';
import '../models/category_model.dart';

class ProfileView extends StatefulWidget {
  static const String id = 'profile_view';
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = provider.categoriesWithProducts;

          if (categories.isEmpty) {
            return const Center(
              child: Text("No categories with products found"),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 per row
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return buildCategoryCard(categories[index]);
            },
          );
        },
      ),
    );
  }

  Widget buildCategoryCard(CategoryModel category) {
    // Find the first subcategory with products
    final subCategory = category.subCategories.firstWhere(
      (sub) => sub.products.isNotEmpty,
      orElse: () => SubCategoryModel(id: '', name: '', products: []),
    );

    if (subCategory.products.isEmpty) {
      return const SizedBox.shrink(); // Skip if no products
    }

    // Collect products from the selected subcategory
    List<ProductModel> allProducts = subCategory.products;

    // Group products by brand within the subcategory
    Map<String, List<ProductModel>> productsByBrand = {};
    for (var product in allProducts) {
      final brandName = product.brand.isNotEmpty ? product.brand : 'Unknown';
      if (!productsByBrand.containsKey(brandName)) {
        productsByBrand[brandName] = [];
      }
      productsByBrand[brandName]!.add(product);
    }

    // Select images based on number of brands
    List<String> selectedImages = [];
    final random = Random();
    final brandNames = productsByBrand.keys.toList()..shuffle(random);

    if (brandNames.length == 1) {
      // Only 1 brand: collect all images from its products, shuffle, take up to 4
      List<String> allImages = [];
      for (var product in productsByBrand[brandNames.first]!) {
        allImages.addAll(product.images);
      }
      allImages.shuffle(random);
      selectedImages = allImages.take(4).toList();
    } else {
      // Multiple brands: select one image per brand, up to 4
      List<String> images = [];
      for (String brandName in brandNames) {
        if (images.length >= 4) break;
        final brandProducts = productsByBrand[brandName]!..shuffle(random);
        if (brandProducts.isNotEmpty && brandProducts.first.images.isNotEmpty) {
          final product = brandProducts.first;
          final img = product.images[random.nextInt(product.images.length)];
          images.add(img);
        }
      }

      // Fill remaining slots with unique images from the same subcategory
      if (images.length < 4) {
        List<String> remainingImages = [];
        for (var product in allProducts) {
          for (var img in product.images) {
            if (!images.contains(img)) {
              remainingImages.add(img);
            }
          }
        }
        remainingImages.shuffle(random);
        images.addAll(remainingImages.take(4 - images.length));
      }
      selectedImages = images;
    }

    // Total product count for the subcategory
    int totalProductCount = allProducts.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2×2 product image grid showing diverse brands
          Expanded(
            flex: 3, // Give more space to the image grid
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio:
                      1, // Make images square for consistent sizing
                ),
                itemCount: selectedImages.length.clamp(0, 4),
                itemBuilder: (context, index) {
                  final img = selectedImages[index].isNotEmpty
                      ? selectedImages[index]
                      : "https://via.placeholder.com/150";
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          // Fixed height container for text to prevent cutting
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${category.name} ($totalProductCount)",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (productsByBrand.length > 1)
                  Text(
                    "${productsByBrand.length} brands",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// // views/product_details_screen.dart
// class ProductDetailsScreen extends StatelessWidget {
//   // final ProductModel product;
//
//   const ProductDetailsScreen({super.key, required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           product.name,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image carousel
//             SizedBox(
//               height: 300,
//               child: PageView.builder(
//                 itemCount: product.images.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.network(
//                         product.images[index].url,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             color: Colors.grey[200],
//                             child: const Center(
//                               child: Icon(
//                                 Icons.image_not_supported,
//                                 size: 64,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             // Product details
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     product.brand.name,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     '\$${product.price.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Description',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     product.description,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[700],
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Text(
//                         'Category: ',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       Text(
//                         product.category.name,
//                         style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Text(
//                         'Sub Category: ',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       Text(
//                         product.subCategory.name,
//                         style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Text(
//                         'Available: ',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       Text(
//                         '${product.quantity} items',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: product.quantity > 0
//                               ? Colors.green
//                               : Colors.red,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: product.quantity > 0
//               ? () {
//                   // Add to cart logic
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('${product.name} added to cart'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 }
//               : null,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//             minimumSize: const Size(double.infinity, 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(
//             product.quantity > 0 ? 'Add to Cart' : 'Out of Stock',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//         ),
//       ),
//     );
//   }
// }
