import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_state.dart';
import '../../utils/app_router.dart';
import '../../models/models.dart';
import '../../widgets/core/app_widgets.dart';
import '../../widgets/cart_bar.dart';
import 'main_navigation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final AppState appState;

  const ProductDetailScreen(
      {super.key, required this.product, required this.appState});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final cartQty = widget.appState.getCartQuantity(widget.product.id);
    if (cartQty > 0) _qty = cartQty;
    widget.appState.fetchReviews(widget.product.id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _add() => setState(() => _qty++);
  void _remove() {
    if (_qty > 1) setState(() => _qty--);
  }

  void _addToCart() {
    final currentInCart = widget.appState.getCartQuantity(widget.product.id);
    if (currentInCart == 0) {
      for (int i = 0; i < _qty; i++) {
        widget.appState.addToCart(widget.product);
      }
    } else {
      widget.appState.removeFromCart(widget.product.id);
      for (int i = 0; i < _qty; i++) {
        widget.appState.addToCart(widget.product);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.neonShadow,
          ),
          child: Text(
            '${widget.product.name} added to cart',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  void _showAddReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddReviewSheet(product: widget.product, appState: widget.appState),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 200,
            left: -100,
            child: _buildBackgroundGlow(
                AppTheme.primary.withOpacity(AppTheme.isDarkMode ? 0.08 : 0.02),
                300),
          ),
          Positioned(
            bottom: 300,
            right: -150,
            child: _buildBackgroundGlow(
                AppTheme.accent.withOpacity(AppTheme.isDarkMode ? 0.06 : 0.02),
                400),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                stretch: true,
                backgroundColor: Colors
                    .transparent, // Fix: Use transparent to see the rich background
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: AppTheme.textHeading,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: _buildImageCarousel(),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.favorite_border_rounded,
                        color: AppTheme.primary),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(
                        0.6), // Fix: More solid "full colored" look
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(2)),
                    border: Border.all(color: AppTheme.glassBorder, width: 1.5),
                  ),
                  transform: Matrix4.translationValues(0, 0, 0),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(2)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28,
                            150), // Fix: Sweeter padding (24 instead of 36)
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add a small handler to make the sheet look intentional
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: AppTheme.textMuted.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.textHeading,
                                          height: 1.1,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppTheme.primary
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              widget.product.category
                                                  .toUpperCase(),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.primary,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            widget.product.weight,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          AnimatedBuilder(
                                            animation: widget.appState,
                                            builder: (context, child) {
                                              if (widget.appState.reviews.isNotEmpty) {
                                                return Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      widget.appState.averageRating.toStringAsFixed(1),
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppTheme.textHeading,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '(${widget.appState.reviews.length})',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: AppTheme.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₨${widget.product.price.toInt()}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primary,
                                            letterSpacing: -1.0,
                                          ),
                                        ),
                                      ),
                                      if (widget.product.hasDiscount)
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '₨${widget.product.originalPrice!.toInt()}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              color: AppTheme.textMuted,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Divider(color: AppTheme.glassBorder),
                            const SizedBox(height: 32),
                            Text(
                              'DESCRIPTION',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMuted,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.product.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                height: 1.8,
                                color: AppTheme.textBody,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Divider(color: AppTheme.glassBorder),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'REVIEWS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textMuted,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showAddReviewSheet(context),
                                  icon: Icon(Icons.edit_rounded, size: 16, color: AppTheme.primary),
                                  label: Text(
                                    'Write a Review',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AnimatedBuilder(
                              animation: widget.appState,
                              builder: (context, child) {
                                if (widget.appState.isReviewsLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                
                                if (widget.appState.reviews.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24),
                                      child: Text(
                                        'No reviews yet. Be the first to review!',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: widget.appState.reviews.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final review = widget.appState.reviews[index];
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceVariant.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppTheme.glassBorder),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                review.userName,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textHeading,
                                                ),
                                              ),
                                              Row(
                                                children: List.generate(5, (starIndex) {
                                                  return Icon(
                                                    starIndex < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                                                    color: Colors.amber,
                                                    size: 14,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                          if (review.comment != null && review.comment!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              review.comment!,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                color: AppTheme.textBody,
                                              ),
                                            ),
                                          ],
                                          if (review.imageUrl != null && review.imageUrl!.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: AppImage(
                                                url: review.imageUrl!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                fallbackEmoji: '📷',
                                              ),
                                            ),
                                          ],
                                          if (review.reply != null && review.reply!.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.storefront_rounded, size: 14, color: AppTheme.primary),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        'Seller Reply',
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w700,
                                                          color: AppTheme.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    review.reply!,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      color: AppTheme.textBody,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: CartBar(
              appState: widget.appState,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                AppRouter.fade(
                    MainNavigation(appState: widget.appState, initialIndex: 2)),
                (r) => false,
              ),
            ),
          ),

          // Bottom Action Bar - Floating Glassmorphic
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.glassBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _remove,
                              icon: Icon(Icons.remove_rounded,
                                  color: AppTheme.textMuted),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            Text(
                              '$_qty',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textHeading,
                              ),
                            ),
                            IconButton(
                              onPressed: _add,
                              icon: Icon(Icons.add_rounded,
                                  color: AppTheme.primary),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _addToCart,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: AppTheme.neonShadow,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_basket_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'ADD TO CART',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.product.imageUrls;
    final hasMultipleImages = images.length > 1;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withOpacity(0.15),
                AppTheme.scaffold,
              ],
            ),
          ),
        ),
        // Ambient Glow
        Positioned(
          top: -50,
          right: -50,
          child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.1), 300),
        ),

        if (hasMultipleImages) ...[
          // Multi-image carousel
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: AppImage(
                  url: images[index],
                  fit: BoxFit.contain,
                  fallbackEmoji: widget.product.emoji,
                ),
              );
            },
          ),
          // Dot Indicator
          Positioned(
            bottom: 16,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: images.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppTheme.primary,
                dotColor: AppTheme.textMuted.withOpacity(0.3),
                spacing: 6,
              ),
            ),
          ),
        ] else ...[
          // Single image or emoji fallback
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.12),
                  Colors.transparent,
                ],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
          Hero(
            tag: 'product-${widget.product.id}',
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: AppImage(
                url: widget.product.imageUrl,
                fit: BoxFit.contain,
                fallbackEmoji: widget.product.emoji,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBackgroundGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }
}

class _AddReviewSheet extends StatefulWidget {
  final Product product;
  final AppState appState;

  const _AddReviewSheet({required this.product, required this.appState});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  File? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.scaffold,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textHeading,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setState(() => _selectedImage = File(pickedFile.path));
                    }
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() => _selectedImage = File(pickedFile.path));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating from 1 to 5 stars.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await widget.appState.addReview(
      productId: widget.product.id,
      rating: _rating,
      comment: _commentController.text.trim(),
      localImagePath: _selectedImage?.path,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review. Try again later.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.scaffold,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write a Review',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textHeading,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    icon: Icon(
                      index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this product...',
                  hintStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: const Text('Add a Photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Submit Review',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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
