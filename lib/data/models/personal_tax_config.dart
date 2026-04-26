class PersonalAllowanceConfig {
  final double amount;
  final double? phaseOutStart;
  final double? phaseOutEnd;

  PersonalAllowanceConfig({
    required this.amount,
    this.phaseOutStart,
    this.phaseOutEnd,
  });

  factory PersonalAllowanceConfig.fromJson(Map<String, dynamic> json) {
    return PersonalAllowanceConfig(
      amount: json['amount'].toDouble(),
      phaseOutStart: json['phaseOut']?['start']?.toDouble(),
      phaseOutEnd: json['phaseOut']?['end']?.toDouble(),
    );
  }
}
