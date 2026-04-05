import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart' as import_cached;
import 'dart:ui';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _isFocused ? AppTheme.primary : AppTheme.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              boxShadow: _isFocused ? AppTheme.neonShadow : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onSubmitted,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: AppTheme.textHeading,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(
                  widget.prefixIcon, 
                  size: 20, 
                  color: _isFocused ? AppTheme.primary : AppTheme.textMuted,
                ),
                suffixIcon: widget.suffix,
                filled: true,
                fillColor: _isFocused ? AppTheme.surfaceVariant : AppTheme.surface.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final Color? color;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.color,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    
    Widget content = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5, 
              color: Colors.black,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );

    if (outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: color ?? AppTheme.primary, 
              width: 2,
            ),
            foregroundColor: color ?? AppTheme.primary,
          ),
          child: content,
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        gradient: isDisabled ? null : AppTheme.primaryGradient,
        color: isDisabled ? AppTheme.surfaceVariant : null,
        boxShadow: isDisabled ? [] : AppTheme.neonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Center(
            child: DefaultTextStyle(
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class AppImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String fallbackEmoji;
  final double borderRadius;

  const AppImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackEmoji = '📦',
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    
    if (url == null || url!.isEmpty) {
      imageWidget = _buildFallback();
    } else if (url!.startsWith('assets/')) {
      imageWidget = Image.asset(
        url!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    } else {
      imageWidget = import_cached.CachedNetworkImage(
        imageUrl: url!,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => Container(
          color: AppTheme.surfaceVariant,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2, 
              color: AppTheme.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageWidget,
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.surfaceVariant,
      child: Center(
        child: Text(
          fallbackEmoji,
          style: TextStyle(fontSize: (width ?? 40) * 0.4),
        ),
      ),
    );
  }
}

