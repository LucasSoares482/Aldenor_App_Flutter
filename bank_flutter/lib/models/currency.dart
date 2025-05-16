// lib/models/currency.dart
class Currency {
  final String code;
  final String name;
  final double value;
  final double variation;
  final DateTime lastUpdate;

  Currency({
    required this.code,
    required this.name,
    required this.value,
    required this.variation,
    required this.lastUpdate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      name: json['name'] as String,
      value: json['value'] as double,
      variation: json['variation'] as double,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'value': value,
      'variation': variation,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}