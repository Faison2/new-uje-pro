import 'package:flutter/material.dart';

import 'dimensions.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget largeScreen;
  final Widget mediumScreen;

  ResponsiveLayout({
    required this.largeScreen,
    required this.mediumScreen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mediumWidth ) {
          return mediumScreen;
        } else {
          return largeScreen;
        }
      },
    );
  }
}
