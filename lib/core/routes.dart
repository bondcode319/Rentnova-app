// In lib/core/routes.dart
import 'package:flutter/material.dart';
import 'package:rentnova/lib/screens/error_screen.dart';
import 'package:rentnova/lib/screens/splash_screen.dart';
// Import your screens here

class AppRoutes {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      // Add other routes here
      default:
        return MaterialPageRoute(
          builder:
              (context) => ErrorScreen(
                error: 'Route not found',
                onRetry: () => Navigator.of(context).pushNamed('/'),
              ),
        );
    }
  }
}
