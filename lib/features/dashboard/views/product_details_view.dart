import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_firebase/features/dashboard/widgets/add%20to%20cart_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../widgets/circle_icon_button.dart';
import '../controllers/category_controller.dart';
import '../controllers/product_controller.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../widgets/full_zoom_page.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String id = 'product_details_screen';
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;
  final CategoryController _categoryController = CategoryController();
  final ProductController _productController = ProductController();

  @override
  void dispose() {
    _carouselController.stopAutoPlay();
    super.dispose();
  }

  void _showFullScreenImage(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // Fetch related products using CategoryController with fallback to ProductController
  Future<List<Product>> _fetchRelatedProducts() async {
    if (widget.product.categoryId == null) {
      // Fallback to ProductController if categoryId is null
      try {
        final products = await _productController.fetchProductsByCategory(
          '68a8e6df2c329726a64222de',
          // Default to "Clothing" category as a fallback
          limit: 10,
        );
        final filteredProducts = products.where((product) {
          final isDifferent = product.id != widget.product.id;
          return isDifferent;
        }).toList();
        return filteredProducts;
      } catch (e) {
        return [];
      }
    }
    try {
      // Try CategoryController first
      final categories = await _categoryController.fetchCategories();
      final matchingCategory = categories.firstWhere(
        (category) => category.id == widget.product.categoryId,
        orElse: () => Category(id: '', name: '', image: '', subCategories: []),
      );
      if (matchingCategory.id.isNotEmpty) {
        final allProducts = matchingCategory.subCategories
            .expand((subCategory) => subCategory.products)
            .toList();
        final filteredProducts = allProducts.where((product) {
          final isDifferent = product.id != widget.product.id;
          return isDifferent;
        }).toList();
        if (filteredProducts.isNotEmpty) {
          return filteredProducts;
        }
      }
      // Fallback to ProductController if Category API returns no products
      final products = await _productController.fetchProductsByCategory(
        widget.product.categoryId!,
        limit: 10,
      );
      final filteredProducts = products.where((product) {
        final isDifferent = product.id != widget.product.id;
        return isDifferent;
      }).toList();
      return filteredProducts;
    } catch (e) {
      return [];
    }
  }

  // Widget to display a single related product card
  Widget _buildRelatedProductCard(Product product, double scaleFactor) {
    return GestureDetector(
      onTap: () {
        // Navigate to ProductDetailsScreen for the selected product
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 150 * scaleFactor,
        margin: EdgeInsets.only(right: 12 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 120 * scaleFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8 * scaleFactor),
                color: Colors.grey[200],
              ),
              child: product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                      child: Image.network(
                        product.images[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 60 * scaleFactor,
                          color: const Color(0xff004CFF),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                  : null,
                              strokeWidth: 4 * scaleFactor,
                              color: const Color(0xff004CFF),
                            ),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.image_not_supported,
                      size: 60 * scaleFactor,
                      color: const Color(0xff004CFF),
                    ),
            ),
            SizedBox(height: 8 * scaleFactor),
            // Product Name
            AutoSizeText(
              product.name,
              style: TextStyle(
                fontSize: 14 * scaleFactor,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 2,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
            ),
            // Product Price (show flash sale price if available)
            AutoSizeText(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12 * scaleFactor,
                color: const Color(0xff004CFF),
              ),
              maxLines: 1,
              minFontSize: 8,
            ),
            // Show original price with strikethrough if on flash sale
            if (product.flashSale != null)
              AutoSizeText(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 10 * scaleFactor,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
                maxLines: 1,
                minFontSize: 8,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenWidth / 375.0;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 600 ? 600 : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel
              widget.product.images.isNotEmpty
                  ? Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _showFullScreenImage(
                            context,
                            widget.product.images,
                            _currentIndex,
                          ),
                          child: CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: (screenHeight * 0.35).clamp(200, 300),
                              viewportFraction: 1.0,
                              enableInfiniteScroll:
                                  widget.product.images.length > 1,
                              onPageChanged: widget.product.images.length > 1
                                  ? (index, reason) {
                                      setState(() {
                                        _currentIndex = index;
                                      });
                                    }
                                  : null,
                            ),
                            items: widget.product.images.map((url) {
                              return Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 60 * scaleFactor,
                                    color: const Color(0xff004CFF),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                              : null,
                                          strokeWidth: 4 * scaleFactor,
                                          color: const Color(0xff004CFF),
                                        ),
                                      );
                                    },
                              );
                            }).toList(),
                          ),
                        ),
                        Positioned(
                          top: 30 * scaleFactor,
                          left: 8 * scaleFactor,
                          child: CircleIconButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        if (widget.product.images.length > 1)
                          Positioned(
                            bottom: 8 * scaleFactor,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: PageController(
                                  initialPage: _currentIndex,
                                ),
                                count: widget.product.images.length,
                                effect: WormEffect(
                                  dotHeight: 8 * scaleFactor,
                                  dotWidth: 8 * scaleFactor,
                                  activeDotColor: const Color(0xff004CFF),
                                  dotColor: Colors.white70,
                                ),
                                onDotClicked: (index) {
                                  _carouselController.animateToPage(index);
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                            ),
                          ),
                        if (widget.product.images.length > 1)
                          Positioned(
                            bottom: 12 * scaleFactor,
                            right: 12 * scaleFactor,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8 * scaleFactor,
                                vertical: 4 * scaleFactor,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(
                                  8 * scaleFactor,
                                ),
                              ),
                              child: AutoSizeText(
                                '${_currentIndex + 1} / ${widget.product.images.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12 * scaleFactor,
                                ),
                                maxLines: 1,
                                minFontSize: 8,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      height: (screenHeight * 0.35).clamp(200, 300),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 60 * scaleFactor,
                            color: const Color(0xff004CFF),
                          ),
                          SizedBox(height: 8 * scaleFactor),
                          AutoSizeText(
                            'No images available',
                            style: TextStyle(
                              fontSize: 16 * scaleFactor,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: (screenHeight * 0.03).clamp(12, 20)),

              // Product Name and Price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 24 * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AutoSizeText(
                      'Qty: ${widget.product.quantity}',
                      style: TextStyle(
                        fontSize: 14 * scaleFactor,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                  ],
                ),
              ),
              if (widget.product.brandName != null)

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Brand:",
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            color: Colors.grey,
                          ),
                        ),

                        TextSpan(
                          text: " ${widget.product.brandName}",
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            color: const Color(0xff004CFF),

                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AutoSizeText(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16 * scaleFactor,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff004CFF),
                  ),
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.product.flashSale != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AutoSizeText(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14 * scaleFactor,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                    maxLines: 1,
                    minFontSize: 10,
                  ),
                ),
              SizedBox(height: (screenHeight * 0.02).clamp(10, 14)),

              // Product Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      'Product Details:',
                      style: TextStyle(
                        fontSize: 15 * scaleFactor,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      minFontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AutoSizeText(
                      widget.product.description,
                      style: TextStyle(
                        fontSize: 16 * scaleFactor,
                        color: Colors.black87,
                      ),
                      maxLines: 5,
                      minFontSize: 12,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: (screenHeight * 0.02).clamp(10, 14)),
                  ActionButtons(onAddToCartPressed: (){}, onFavoritePressed: (){}),

                    SizedBox(height: (screenHeight * 0.02).clamp(8, 12)),
                    AutoSizeText(
                      'Other Products',
                      style: TextStyle(
                        fontSize: 18 * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: (screenHeight * 0.01).clamp(8, 12)),
                    // Related Products Section
                    SizedBox(
                      height: 200 * scaleFactor,
                      child: FutureBuilder<List<Product>>(
                        future: _fetchRelatedProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xff004CFF),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: AutoSizeText(
                                'Failed to load related products',
                                style: TextStyle(
                                  fontSize: 14 * scaleFactor,
                                  color: Colors.red,
                                ),
                              ),
                            );
                          }
                          final relatedProducts = snapshot.data ?? [];
                          if (relatedProducts.isEmpty) {
                            return Center(
                              child: AutoSizeText(
                                'No related products found',
                                style: TextStyle(
                                  fontSize: 14 * scaleFactor,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: relatedProducts.length,
                            itemBuilder: (context, index) {
                              return _buildRelatedProductCard(
                                relatedProducts[index],
                                scaleFactor,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
