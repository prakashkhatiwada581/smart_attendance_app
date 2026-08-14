import 'package:flutter/material.dart';

/// A wrapper widget that animates its child with a staggered fade + slide effect.
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delayPerItem;
  final Offset beginOffset;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 500),
    this.delayPerItem = const Duration(milliseconds: 80),
    this.beginOffset = const Offset(0, 0.15),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('animated_item_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + (delayPerItem * index),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              beginOffset.dx * (1 - value) * 50,
              beginOffset.dy * (1 - value) * 50,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
