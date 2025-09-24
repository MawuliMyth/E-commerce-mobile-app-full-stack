import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/dashboard/controllers/category_controller.dart';
import '../features/dashboard/models/category_model.dart';
import '../features/dashboard/views/category_products_view.dart';
import '../features/dashboard/views/products_view.dart';
import '../theme/theme_controller.dart';

class CategoriesScreen extends StatefulWidget {
  static const String id = 'categories_screen';

  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> categories = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final CategoryController _categoryController = CategoryController();
  // Track expanded categories by their index in filteredCategories
  final Set<int> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await _categoryController.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching categories: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Category> get filteredCategories {
    if (_searchController.text.isEmpty) return categories;
    return categories.where((category) {
      final categoryName = category.name.toLowerCase();
      final searchTerm = _searchController.text.toLowerCase();
      if (categoryName.contains(searchTerm)) return true;
      return category.subCategories.any(
            (subCat) => subCat.name.toLowerCase().contains(searchTerm),
      );
    }).toList();
  }

  void _navigateToProducts(
      BuildContext context,
      SubCategory subCategory,
      String categoryName,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsScreen(
          subcategoryId: subCategory.id,
          subcategoryName: subCategory.name,
          categoryName: categoryName,
          products: subCategory.products,
        ),
      ),
    );
  }

  // Refreshes categories
  Future<void> _refreshCategories() async {
    setState(() {
      isLoading = true;
      _expandedCategories.clear(); // Reset expanded state on refresh
    });
    await _loadCategories();
  }

  // Toggles the expanded state of a category
  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedCategories.contains(index)) {
        _expandedCategories.remove(index);
      } else {
        _expandedCategories.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor:Theme.of(context).appBarTheme.foregroundColor ,
        title: const Text(
          "Categories",

        ),
        centerTitle: true,
        elevation: 1,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No categories found",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _refreshCategories,
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _refreshCategories,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Search Bar
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
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
                      hintText: "Search for Categories",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
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
              // Categories List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  final isExpanded = _expandedCategories.contains(index);
                  final subCategoriesToShow = isExpanded
                      ? category.subCategories
                      : category.subCategories.take(5).toList();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
                        Container(
                          width: double.infinity,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryProductsScreen(
                                            categoryId: category.id,
                                            categoryName: category.name,
                                          ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (category.subCategories.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${category.subCategories.length}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Subcategories List with Animation
                              AnimatedCrossFade(
                                firstChild: Column(
                                  children: subCategoriesToShow.map((subCat) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 2,
                                          vertical: 4,
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                subCat.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onTap: () => _navigateToProducts(
                                          context,
                                          subCat,
                                          category.name,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                secondChild: Container(),
                                crossFadeState: isExpanded || subCategoriesToShow.isNotEmpty
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 300),
                              ),
                              // See More/See Less Button
                              if (category.subCategories.length > 5)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 8,
                                  ),
                                  child: TextButton(
                                    onPressed: () => _toggleExpanded(index),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      isExpanded ? "See Less" : "See More",
                                      style: const TextStyle(
                                        color: Color(0xff004CFF),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}