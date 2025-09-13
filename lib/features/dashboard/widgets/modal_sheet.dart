import 'package:flutter/material.dart';

import '../models/category_model.dart';

class AllSubcategoriesModal extends StatefulWidget {
  final String categoryName;
  final List<SubCategory> subCategories;
  final Function(SubCategory) onSubcategoryTap;

  const AllSubcategoriesModal({
    super.key,
    required this.categoryName,
    required this.subCategories,
    required this.onSubcategoryTap,
  });

  static void show(
    BuildContext context,
    String categoryName,
    List<SubCategory> subCategories,
    Function(SubCategory) onSubcategoryTap,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AllSubcategoriesModal(
          categoryName: categoryName,
          subCategories: subCategories,
          onSubcategoryTap: onSubcategoryTap,
        );
      },
    );
  }

  @override
  State<AllSubcategoriesModal> createState() => _AllSubcategoriesModalState();
}

class _AllSubcategoriesModalState extends State<AllSubcategoriesModal> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SubCategory> get filteredSubCategories {
    if (_searchController.text.isEmpty) return widget.subCategories;

    final searchTerm = _searchController.text.toLowerCase();
    return widget.subCategories
        .where((subCat) => subCat.name.toLowerCase().contains(searchTerm))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title with count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'All ${widget.categoryName} Subcategories',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff004CFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.subCategories.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: "Search subcategories...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results count
              if (_searchController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filteredSubCategories.length} ${filteredSubCategories.length == 1 ? 'result' : 'results'} found',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // Subcategories list
              Expanded(
                child: filteredSubCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isEmpty
                                  ? Icons.category_outlined
                                  : Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No subcategories available'
                                  : 'No subcategories match your search',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                child: const Text('Clear search'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filteredSubCategories.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.grey[200]),
                        itemBuilder: (context, index) {
                          final subCat = filteredSubCategories[index];
                          final productCount = subCat.products.length;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subCat.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (productCount > 0) ...[
                                  const SizedBox(width: 8),
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //     horizontal: 8,
                                  //     vertical: 2,
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: const Color(
                                  //       0xff004CFF,
                                  //     ),
                                  //     borderRadius: BorderRadius.circular(12),
                                  //   ),
                                  //   child: Text(
                                  //     '$productCount',
                                  //     style: const TextStyle(
                                  //       fontSize: 12,
                                  //       color: Colors.white,
                                  //       fontWeight: FontWeight.w600,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ],
                            ),
                            subtitle: productCount == 0
                                ? const Text(
                                    'No products available',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  )
                                : Text(
                                    '$productCount ${productCount == 1 ? 'product' : 'products'} available',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSubcategoryTap(subCat);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
