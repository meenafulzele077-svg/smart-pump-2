import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmering placeholder block, used while cards/charts are loading so the
/// layout doesn't jump once real data arrives.
class LoadingShimmer extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const LoadingShimmer({
    super.key,
    this.height = 20,
    this.width,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surfaceContainerHighest.withOpacity(0.4);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A full card-shaped shimmer skeleton for dashboard cards.
class CardShimmer extends StatelessWidget {
  final double height;
  const CardShimmer({super.key, this.height = 140});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(height: height, radius: 20);
  }
}
