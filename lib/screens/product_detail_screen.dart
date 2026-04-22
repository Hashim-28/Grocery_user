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
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    widget.appState.addToCart(widget.product, quantity: _qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: AppTheme.neonShadow,
          ),
          child: Text(
            '${widget.product.name} added to cart',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
    setState(() {
      _qty = 1;
    });
  }

  void _showAddReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _AddReviewSheet(product: widget.product, appState: widget.appState),
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
            top: 200.h,
            left: -100.w,
            child: _buildBackgroundGlow(
                AppTheme.primary.withOpacity(AppTheme.isDarkMode ? 0.08 : 0.02),
                300.r),
          ),
          Positioned(
            bottom: 300.h,
            right: -150.w,
            child: _buildBackgroundGlow(
                AppTheme.accent.withOpacity(AppTheme.isDarkMode ? 0.06 : 0.02),
                400.r),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 400.h,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: AppTheme.textHeading,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
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
                        color: AppTheme.primary, size: 24.sp),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.6),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(2.r)),
                    border: Border.all(color: AppTheme.glassBorder, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(2.r)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 150.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40.w,
                                height: 4.h,
                                margin: EdgeInsets.only(bottom: 24.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.textMuted.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2.r),
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
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.textHeading,
                                          height: 1.1,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 12.w,
                                        runSpacing: 8.h,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              border: Border.all(
                                                  color: AppTheme.primary
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              widget.product.category
                                                  .toUpperCase(),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.primary,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            widget.product.weight,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          AnimatedBuilder(
                                            animation: widget.appState,
                                            builder: (context, child) {
                                              if (widget.appState.reviews
                                                  .isNotEmpty) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.star_rounded,
                                                        color: Colors.amber,
                                                        size: 16.sp),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      widget.appState
                                                          .averageRating
                                                          .toStringAsFixed(1),
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppTheme
                                                            .textHeading,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      '(${widget.appState.reviews.length})',
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            AppTheme.textMuted,
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
                                SizedBox(width: 16.w),
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
                                            fontSize: 30.sp,
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
                                              fontSize: 14.sp,
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
                            SizedBox(height: 32.h),
                            Divider(color: AppTheme.glassBorder),
                            SizedBox(height: 32.h),
                            Text(
                              'DESCRIPTION',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMuted,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              widget.product.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.sp,
                                height: 1.8,
                                color: AppTheme.textBody,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Divider(color: AppTheme.glassBorder),
                            SizedBox(height: 32.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'REVIEWS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textMuted,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showAddReviewSheet(context),
                                  icon: Icon(Icons.edit_rounded,
                                      size: 16.sp, color: AppTheme.primary),
                                  label: Text(
                                    'Write a Review',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            AnimatedBuilder(
                              animation: widget.appState,
                              builder: (context, child) {
                                if (widget.appState.isReviewsLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (widget.appState.reviews.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 24.h),
                                      child: Text(
                                        'No reviews yet. Be the first to review!',
                                        style: GoogleFonts.plusJakartaSans(
                                            color: AppTheme.textMuted,
                                            fontSize: 14.sp),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: widget.appState.reviews.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 16.h),
                                  itemBuilder: (context, index) {
                                    final review =
                                        widget.appState.reviews[index];
                                    return Container(
                                      padding: EdgeInsets.all(16.r),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceVariant
                                            .withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        border: Border.all(
                                            color: AppTheme.glassBorder),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                review.userName,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppTheme
                                                            .textHeading,
                                                        fontSize: 14.sp),
                                              ),
                                              Row(
                                                children: List.generate(5,
                                                    (starIndex) {
                                                  return Icon(
                                                    starIndex < review.rating
                                                        ? Icons.star_rounded
                                                        : Icons
                                                            .star_border_rounded,
                                                    color: Colors.amber,
                                                    size: 14.sp,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                          if (review.comment != null &&
                                              review.comment!.isNotEmpty) ...[
                                            SizedBox(height: 8.h),
                                            Text(
                                              review.comment!,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 14.sp,
                                                color: AppTheme.textBody,
                                              ),
                                            ),
                                          ],
                                          if (review.imageUrl != null &&
                                              review.imageUrl!.isNotEmpty) ...[
                                            SizedBox(height: 12.h),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              child: AppImage(
                                                url: review.imageUrl!,
                                                width: 100.w,
                                                height: 100.w,
                                                fit: BoxFit.cover,
                                                fallbackEmoji: '📷',
                                              ),
                                            ),
                                          ],
                                          if (review.reply != null &&
                                              review.reply!.isNotEmpty) ...[
                                            SizedBox(height: 12.h),
                                            Container(
                                              padding: EdgeInsets.all(12.r),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                border: Border.all(
                                                    color: AppTheme.primary
                                                        .withOpacity(0.2)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .storefront_rounded,
                                                          size: 14.sp,
                                                          color:
                                                              AppTheme.primary),
                                                      SizedBox(width: 6.w),
                                                      Text(
                                                        'Seller Reply',
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              AppTheme.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Text(
                                                    review.reply!,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 13.sp,
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
            left: 20.w,
            right: 20.w,
            bottom: 120.h,
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

          // Bottom Action Bar
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 24.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppTheme.glassBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20.r,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _remove,
                              icon: Icon(Icons.remove_rounded,
                                  color: AppTheme.textMuted, size: 24.sp),
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                            Text(
                              '$_qty',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textHeading,
                              ),
                            ),
                            IconButton(
                              onPressed: _add,
                              icon: Icon(Icons.add_rounded,
                                  color: AppTheme.primary, size: 24.sp),
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: _addToCart,
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: AppTheme.neonShadow,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_basket_rounded,
                                      color: Colors.white, size: 20.sp),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'ADD TO CART',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.sp,
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
        Positioned(
          top: -50.h,
          right: -50.w,
          child: _buildBackgroundGlow(AppTheme.accent.withOpacity(0.1), 300.r),
        ),
        if (hasMultipleImages) ...[
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(40.r),
                child: AppImage(
                  url: images[index],
                  fit: BoxFit.contain,
                  fallbackEmoji: widget.product.emoji,
                ),
              );
            },
          ),
          Positioned(
            bottom: 16.h,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: images.length,
              effect: WormEffect(
                dotHeight: 8.h,
                dotWidth: 8.w,
                activeDotColor: AppTheme.primary,
                dotColor: AppTheme.textMuted.withOpacity(0.3),
                spacing: 6.w,
              ),
            ),
          ),
        ] else ...[
          Container(
            width: 300.r,
            height: 300.r,
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
              padding: EdgeInsets.all(40.r),
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
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppTheme.scaffold,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.textHeading,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
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
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() => _selectedImage = File(pickedFile.path));
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppTheme.scaffold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Add Review',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.textHeading,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 40.sp,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),
            AppTextField(
              controller: _commentController,
              label: 'Comment (Optional)',
              hint: 'How was the product?',
              maxLines: 4,
              prefixIcon: Icons.comment,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: _selectedImage != null
                    ? Column(
                        children: [
                          Image.file(_selectedImage!,
                              height: 150.h, fit: BoxFit.cover),
                          TextButton(
                            onPressed: () =>
                                setState(() => _selectedImage = null),
                            child: Text('Remove Image',
                                style: TextStyle(
                                    color: AppTheme.error, fontSize: 13.sp)),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              color: AppTheme.textMuted, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Add Product Photo',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 14.sp)),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 32.h),
            AppButton(
              label: 'Submit Review',
              isLoading: _isSubmitting,
              onPressed: _rating == 0 || _isSubmitting
                  ? null
                  : () async {
                      setState(() => _isSubmitting = true);
                      try {
                        await widget.appState.addReview(
                          productId: widget.product.id,
                          rating: _rating,
                          comment: _commentController.text,
                          localImagePath: _selectedImage?.path ?? "",
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Review submitted successfully!',
                                  style: TextStyle(fontSize: 14.sp))),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to submit review: $e',
                                  style: TextStyle(fontSize: 14.sp))),
                        );
                      } finally {
                        setState(() => _isSubmitting = false);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
