class AppConstants {
  static const double exchangeRate = 1645.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const Duration animationDuration = Duration(milliseconds: 350);
  static const Duration splashDelay = Duration(seconds: 1);
  static const Duration loadingDelay = Duration(milliseconds: 1500);

  static Map<String, double> exchangeRates = {
    'NGN': 1.0,
    'USD': 0.000609, // Fallback: 1 NGN = 0.000609 USD (~1645 NGN/USD)
    'EUR': 0.000562,
    'GBP': 0.000480,
  };

  static String selectedCurrency = 'NGN';
}
