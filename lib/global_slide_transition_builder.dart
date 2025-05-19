import 'package:flutter/material.dart';

class GlobalSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    const Offset begin = Offset(1.0, 0.0);
    const Offset end = Offset.zero;
    const Curve curve = Curves.easeInOutCubic; // smoother

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}