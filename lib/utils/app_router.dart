import 'package:flutter/material.dart';

class AppRouter {
  static Route<T> slideFade<T>(Widget page, {SlideDirection direction = SlideDirection.right}) {
    final offset = direction == SlideDirection.right
        ? const Offset(1.0, 0.0)
        : direction == SlideDirection.up
            ? const Offset(0.0, 1.0)
            : const Offset(-1.0, 0.0);

    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: offset, end: Offset.zero).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  static Route<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }
}

enum SlideDirection { right, left, up }
