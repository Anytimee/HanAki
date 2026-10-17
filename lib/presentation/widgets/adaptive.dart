import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

/// Scaffold adaptif: padding 16 mobile / 24 tablet+, max-width content,
/// SafeArea iOS, textScaler-aware.
class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool centerTitle;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: TextStyle(fontSize: context.fs(18))),
          centerTitle: centerTitle,
          actions: actions,
        ),
        body: MaxWidth(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: body,
          ),
        ),
        bottomNavigationBar: SafeArea(child: bottomNavigationBar ?? const SizedBox()),
      ),
    );
  }
}

/// Grid poster responsif: 2 mobile | 4 tablet | 6 desktop.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  const ResponsiveGrid({super.key, required this.children, this.spacing = 12});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final cols = context.posterColumns;
        final w = (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final ch in children) SizedBox(width: w, child: ch)],
        );
      },
    );
  }
}

/// Section header dengan aksen negara: pink KR / magenta JP.
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 34, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: context.fs(17), fontWeight: FontWeight.w700)),
              Text(subtitle, style: TextStyle(fontSize: context.fs(12), color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ],
    );
  }
}
