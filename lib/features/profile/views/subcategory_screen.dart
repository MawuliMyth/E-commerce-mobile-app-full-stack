// import 'package:ecommerce_firebase/features/profile/views/profile_view.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../controllers/category_controller.dart';
// import '../models/category_model.dart';
//
// class SubCategoryScreen extends StatelessWidget {
//   final String categoryId;
//   final String categoryName;
//
//   const SubCategoryScreen({
//     super.key,
//     required this.categoryId,
//     required this.categoryName,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final products = context
//         .read<ProductController>()
//         .products
//         .where((p) => p.category.id == categoryId)
//         .toList();
//
//     // Group by subcategory
//     final Map<String, List<ProductModel>> productsBySubCategory = {};
//     for (var product in products) {
//       productsBySubCategory.putIfAbsent(product.subCategory.id, () => []);
//       productsBySubCategory[product.subCategory.id]!.add(product);
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(categoryName),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: productsBySubCategory.length,
//         itemBuilder: (context, index) {
//           final subCatId = productsBySubCategory.keys.elementAt(index);
//           final subCatProducts = productsBySubCategory[subCatId]!;
//           final subCatName = subCatProducts.first.subCategory.name;
//
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 subCatName,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 0.85,
//                 ),
//                 itemCount: subCatProducts.length,
//                 itemBuilder: (context, i) {
//                   final product = subCatProducts[i];
//                   return ProductCategoryCard(
//                     product: product,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               ProductDetailsScreen(product: product),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
