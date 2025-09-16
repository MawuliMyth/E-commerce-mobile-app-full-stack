import 'dart:convert';

import 'package:ecommerce_firebase/features/dashboard/views/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/category_controller.dart';
import '../models/category_model.dart';
import '../widgets/modal_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> categories = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final CategoryController _categoryController = CategoryController();
  int? _lastFetchTime; // State variable to store the last fetch time

  // Cache duration - set to 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

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

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_categories');
      final cachedTime = prefs.getInt('last_fetch_time');

      // Check if we have cached data and it's still valid
      if (!forceRefresh &&
          cachedData != null &&
          cachedTime != null &&
          DateTime.now().difference(
                DateTime.fromMillisecondsSinceEpoch(cachedTime),
              ) <
              _cacheDuration) {
        final List<dynamic> decodedData = jsonDecode(cachedData);
        setState(() {
          categories = decodedData
              .map((json) => Category.fromJson(json))
              .toList();
          isLoading = false;
          _lastFetchTime = cachedTime; // Update last fetch time from cache
        });
        return;
      }

      // Fetch fresh data
      final fetchedCategories = await _categoryController.fetchCategories();

      setState(() {
        categories = fetchedCategories;
        isLoading = false;
        _lastFetchTime =
            DateTime.now().millisecondsSinceEpoch; // Update last fetch time
      });

      // Update cache
      await prefs.setString(
        'cached_categories',
        jsonEncode(fetchedCategories.map((cat) => cat.toJson()).toList()),
      );
      await prefs.setInt('last_fetch_time', _lastFetchTime!);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching categories: $e");

      // Show error message to user
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

      // Check category name
      if (categoryName.contains(searchTerm)) return true;

      // Check subcategories
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
        ),
      ),
    );
  }

  Future<void> _refreshCategories() async {
    setState(() {
      isLoading = true;
    });
    await _loadCategories(forceRefresh: true);
  }

  // Method to clear cache (useful for logout or data invalidation)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_categories');
    await prefs.remove('last_fetch_time');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCategories,
          ),
        ],
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
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    // Cache indicator (shows when using cached data)
                    if (_lastFetchTime != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        color: Colors.blue.shade50,
                        child: Row(
                          children: [
                            Icon(
                              Icons.cached,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Last updated: ${DateTime.fromMillisecondsSinceEpoch(_lastFetchTime!).difference(DateTime.now()).inMinutes.abs() < 1 ? 'Just now' : '${DateTime.fromMillisecondsSinceEpoch(_lastFetchTime!).difference(DateTime.now()).inMinutes.abs()}m ago'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _refreshCategories,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Refresh',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

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
                            hintText: "Search for Subcategories",
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
                        final subCategoriesToShow = category.subCategories
                            .take(5)
                            .toList();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Header
                              Container(
                                width: double.infinity,
                                color: Colors.grey[200],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            category.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
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
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Subcategories List
                                    ...subCategoriesToShow.map((subCat) {
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
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              if (subCat.products.isNotEmpty)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xff004CFF,
                                                    ).withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${subCat.products.length}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xff004CFF),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          onTap: () {
                                            _navigateToProducts(
                                              context,
                                              subCat,
                                              category.name,
                                            );
                                          },
                                        ),
                                      );
                                    }),

                                    // See More Button
                                    if (category.subCategories.length > 5)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                          vertical: 8,
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            AllSubcategoriesModal.show(
                                              context,
                                              category.name,
                                              category.subCategories,
                                              (subCategory) =>
                                                  _navigateToProducts(
                                                    context,
                                                    subCategory,
                                                    category.name,
                                                  ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            "See More",
                                            style: TextStyle(
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
