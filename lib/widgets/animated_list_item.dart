import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(duration: 500.ms, delay: (100 * index).ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}
