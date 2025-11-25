import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../theme/theme_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_provider.dart';
import '../../wishlist/controllers/wishlist_provider.dart';
import '../models/product_model.dart';
import '../views/product_details_view.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool showCarousel;
  final double? width;
  final double? scaleFactor;
  final bool showFlashSale;

  const ProductCard({
    super.key,
    required this.product,
    this.showCarousel = true,
    this.width,
    this.scaleFactor = 1.0,
    this.showFlashSale = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final PageController _pageController = PageController();
  bool _isAddingToCart = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    if (_isAddingToCart) return;

    final authController = AuthController();
    final token = await authController.getAccessToken();

    setState(() {
      _isAddingToCart = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final success = await cartProvider.addToCart(
      productId: widget.product.id,
      quantity: 1,
    );

    setState(() {
      _isAddingToCart = false;
    });

    if (mounted) {
      final snackBar = SnackBar(
        content: Text(
          success
              ? 'Item added to cart successfully!'
              : cartProvider.errorMessage ?? 'Failed to add item to cart',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (!success) {
        cartProvider.clearError();
      }
    }
  }

  void _handleToggleWishlist() {
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    wishlistProvider.toggleWishlist(widget.product);

    final isInWishlist = wishlistProvider.isInWishlist(widget.product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isInWishlist ? 'Added to wishlist!' : 'Removed from wishlist',
        ),
        backgroundColor: isInWishlist ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final scaleFactor = widget.scaleFactor ?? 1.0;
    final imageUrls = widget.product.images.isNotEmpty
        ? widget.product.images
        : [''];

    final isInWishlist = wishlistProvider.isInWishlist(widget.product.id);

    return GestureDetector(
      onTap: () {
        // Add product to recently viewed before navigating
        wishlistProvider.addToRecentlyViewed(widget.product);
        Navigator.pushNamed(
          context,
          ProductDetailsScreen.id,
          arguments: widget.product,
        );
      },
      child: Container(
        width: widget.width ?? double.infinity,
        child: Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scaleFactor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Section
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12 * scaleFactor),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: widget.showCarousel && imageUrls.length > 1
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: imageUrls.length,
                              itemBuilder: (context, pageIndex) {
                                final imageUrl = imageUrls[pageIndex];
                                return ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12 * scaleFactor),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 1.5 * scaleFactor,
                                              color: const Color(0xff004CFF),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 24 * scaleFactor,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12 * scaleFactor),
                              ),
                              child: Image.network(
                                imageUrls[0],
                                fit: BoxFit.cover,
                                width: double.infinity,
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
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 1.5 * scaleFactor,
                                          color: const Color(0xff004CFF),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 24 * scaleFactor,
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),

                    // FAVORITE ICON - NEW
                    Positioned(
                      top: 8 * scaleFactor,
                      left: 8 * scaleFactor,
                      child: GestureDetector(
                        onTap: _handleToggleWishlist,
                        child: Container(
                          padding: EdgeInsets.all(8 * scaleFactor),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isInWishlist ? Colors.red : Colors.grey,
                            size: 20 * scaleFactor,
                          ),
                        ),
                      ),
                    ),

                    if (widget.showCarousel && imageUrls.length > 1)
                      Positioned(
                        bottom: 4 * scaleFactor,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: imageUrls.length,
                            effect: WormEffect(
                              dotHeight: 6 * scaleFactor,
                              dotWidth: 6 * scaleFactor,
                              activeDotColor: const Color(0xff004CFF),
                              dotColor: Colors.grey,
                              spacing: 3 * scaleFactor,
                            ),
                          ),
                        ),
                      ),
                    if (widget.showCarousel && imageUrls.length > 1)
                      Positioned(
                        top: 4 * scaleFactor,
                        right: 4 * scaleFactor,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6 * scaleFactor,
                            vertical: 2 * scaleFactor,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(
                              10 * scaleFactor,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.collections,
                                color: Colors.white,
                                size: 10 * scaleFactor,
                              ),
                              SizedBox(width: 3 * scaleFactor),
                              Text(
                                '${imageUrls.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8 * scaleFactor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Details
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(5 * scaleFactor),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              widget.product.name,
                              maxLines: 1,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15 * scaleFactor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            AutoSizeText(
                              "\$${widget.product.price.toStringAsFixed(2)}",
                              maxLines: 1,
                              minFontSize: 8,
                              style: TextStyle(
                                fontSize: 17 * scaleFactor,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff004CFF),
                              ),
                            ),
                            if (widget.showFlashSale &&
                                widget.product.flashSale != null)
                              AutoSizeText(
                                "\$${widget.product.price.toStringAsFixed(2)}",
                                maxLines: 1,
                                minFontSize: 8,
                                style: TextStyle(
                                  fontSize: 14 * scaleFactor,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * scaleFactor),
                      GestureDetector(
                        onTap: _isAddingToCart ? null : _handleAddToCart,
                        child: Container(
                          padding: EdgeInsets.all(8 * scaleFactor),
                          decoration: BoxDecoration(
                            color: _isAddingToCart
                                ? Colors.grey
                                : const Color(0xff004CFF),
                            borderRadius: BorderRadius.circular(
                              8 * scaleFactor,
                            ),
                          ),
                          child: _isAddingToCart
                              ? SizedBox(
                                  width: 20 * scaleFactor,
                                  height: 20 * scaleFactor,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.white,
                                  size: 20 * scaleFactor,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
