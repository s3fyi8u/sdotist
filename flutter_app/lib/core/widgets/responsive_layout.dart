import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget? tabletScaffold;
  final Widget? desktopScaffold;

  const ResponsiveLayout({
    super.key,
    required this.mobileScaffold,
    this.tabletScaffold,
    this.desktopScaffold,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return mobileScaffold;
        } else if (constraints.maxWidth < 1100) {
          return tabletScaffold ?? desktopScaffold ?? mobileScaffold;
        } else {
          return desktopScaffold ?? tabletScaffold ?? mobileScaffold;
        }
      },
    );
  }

  /// A helper method to wrap any content in a constrained, centered box
  /// Useful for web and tablet views where we don't want content to stretch endlessly.
  static Widget constrainedBox(BuildContext context, Widget child, {double maxWidth = 800}) {
    if (isMobile(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
