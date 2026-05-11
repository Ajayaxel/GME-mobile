import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;

        // Create a scaled theme for tablets
        ThemeData theme = Theme.of(context);
        if (isTablet) {
          theme = theme.copyWith(
            textTheme: theme.textTheme.apply(fontSizeFactor: 1.25),
            iconTheme: theme.iconTheme.copyWith(
              size: 28, // Increase icon size for tablets
            ),
            primaryIconTheme: theme.primaryIconTheme.copyWith(size: 28),
          );
        }

        return Theme(
          data: theme,
          child: Container(
            color: AppTheme.bgColor, // Match app background color
            child: child,
          ),
        );
      },
    );
  }
}
