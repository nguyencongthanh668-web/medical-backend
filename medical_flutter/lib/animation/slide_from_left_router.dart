import 'package:flutter/material.dart';

class SlideFromLeftRoute<T> extends PageRouteBuilder<T> {
  SlideFromLeftRoute({required Widget nextPage})
      : super(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, __, ___) => nextPage,
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      );
    },
  );
}