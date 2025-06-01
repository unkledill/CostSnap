import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const String _apiUrl = 'https://open.er-api.com/v6/latest/NGN';
  static const Map<String, double> _fallbackRates = {
    'NGN': 1.0,
    'USD': 0.000609, // 1 NGN = 0.000609 USD (~1645 NGN/USD)
    'EUR': 0.000562,
    'GBP': 0.000480,
  };

  Future<Map<String, double>> fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          return {
            'NGN': 1.0,
            'USD': data['rates']['USD'].toDouble(),
            'EUR': data['rates']['EUR'].toDouble(),
            'GBP': data['rates']['GBP'].toDouble(),
          };
        }
      }
      return _fallbackRates;
    } catch (e) {
      return _fallbackRates;
    }
  }
}
