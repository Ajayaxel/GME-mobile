import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;

  static double horizontalPadding(BuildContext context) =>
      isTablet(context) ? 60.0 : 24.0;

  static double fontSizeMultiplier(BuildContext context) =>
      isTablet(context) ? 1.25 : 1.0;

  static double iconSize(BuildContext context, {double base = 22.0}) =>
      isTablet(context) ? (base * 1.3) : base;

  static double profileAvatarRadius(BuildContext context) =>
      isTablet(context) ? 24.0 : 18.0;

  static double drawerWidth(BuildContext context) =>
      isTablet(context) ? 350.0 : 280.0;
}
