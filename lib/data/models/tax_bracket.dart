class TaxBracket {
  final double min;
  final double? max;
  final double rate;

  TaxBracket({required this.min, this.max, required this.rate});

  factory TaxBracket.fromJson(Map<String, dynamic> json) {
    return TaxBracket(
      min: (json['min'] as num).toDouble(),
      max: json['max'] != null ? (json['max'] as num).toDouble() : null,
      rate: (json['rate'] as num).toDouble(),
    );
  }
}