// lib/services/currency_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

class CurrencyService {
  final String apiUrl = 'https://economia.awesomeapi.com.br/json/all';
  
  Future<List<Currency>> getCurrencies() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Currency> currencies = [];
        
        // Process each currency in the response
        data.forEach((key, value) {
          // Skip USDT (Tether) and BTC (Bitcoin) - focusing on forex currencies
          if (key != 'USDT' && key != 'BTC') {
            try {
              currencies.add(
                Currency(
                  code: key,
                  name: value['name'],
                  value: double.parse(value['bid']),
                  variation: double.parse(value['pctChange']),
                  lastUpdate: DateTime.fromMillisecondsSinceEpoch(
                    int.parse(value['timestamp']) * 1000,
                  ),
                ),
              );
            } catch (e) {
              // Skip this currency if there's a parsing error
              print('Error parsing currency $key: $e');
            }
          }
        });
        
        // Sort currencies by code
        currencies.sort((a, b) => a.code.compareTo(b.code));
        
        return currencies;
      } else {
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load currencies: $e');
    }
  }
  
  // Get currency conversion rate
  Future<double> getConversionRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) {
      return 1.0;
    }
    
    try {
      final response = await http.get(
        Uri.parse('https://economia.awesomeapi.com.br/json/last/$fromCurrency-$toCurrency'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String key = '$fromCurrency$toCurrency';
        
        if (data.containsKey(key)) {
          return double.parse(data[key]['bid']);
        } else {
          throw Exception('Currency conversion not available');
        }
      } else {
        throw Exception('Failed to get conversion rate');
      }
    } catch (e) {
      throw Exception('Failed to get conversion rate: $e');
    }
  }
}