import 'package:flutter/material.dart';
import 'package:lucra/screens/balances.dart';
import 'package:lucra/screens/new_balance.dart';
import 'package:lucra/screens/onboarding.dart';
import 'package:lucra/screens/other_apps.dart';
import 'package:lucra/screens/resume.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final dynamic data = settings.arguments;
    switch (settings.name) {
      case '/slides':
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
      case '/resume':
        return MaterialPageRoute(
          builder: (_) => ResumeScreen(balance: data),
        );
      case '/balances':
        return MaterialPageRoute(
          builder: (_) => BalancesScreen(
              navigationBalancesKey: data,
              incomeCardKey: data,
              expenseCardKey: data),
        );
      case '/other-apps':
        return MaterialPageRoute(
          builder: (_) => OtherAppsScreen(),
        );
      case '/new-balance':
        return MaterialPageRoute(
          builder: (_) => NewBalanceScreen(balance: data),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('This page does not exist'),
        ),
      );
    });
  }
}
