import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum ScreenSize { mobile, tablet, desktop }

ScreenSize screenSizeOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < AppConstants.mobileBreakpoint) return ScreenSize.mobile;
  if (w < AppConstants.tabletBreakpoint) return ScreenSize.tablet;
  return ScreenSize.desktop;
}

extension ResponsiveX on BuildContext {
  ScreenSize get screenSize => screenSizeOf(this);
  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  double get pagePadding =>
      isMobile ? AppConstants.padMobile : AppConstants.padTablet;

  int get posterColumns => switch (screenSize) {
        ScreenSize.mobile => 2,
        ScreenSize.tablet => 4,
        ScreenSize.desktop => 6,
      };

  double get maxContentWidth => switch (screenSize) {
        ScreenSize.mobile => double.infinity,
        ScreenSize.tablet => 860,
        ScreenSize.desktop => 1200,
      };

  /// Skala font adaptif: hormati textScaler sistem tapi jaga batas baca.
  double fs(double base) {
    final scaler = MediaQuery.textScalerOf(this).scale(base);
    return scaler.clamp(base * .85, base * 1.35);
  }
}

class MaxWidth extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  const MaxWidth({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final cap = maxWidth ?? context.maxContentWidth;
    if (cap == double.infinity) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: child,
      ),
    );
  }
}
