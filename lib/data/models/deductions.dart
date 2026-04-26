class Deductions {
  final double employeeAllowance;
  final double investorAllowance;
  final double? socialSecurityAllowance;
  final double childAllowance;
  final double lumpSumSpecialExpense;
  final double alimonyMaxDeductible;
  final double educationExpenseLimit;
  final double childEducationExpense;
  final double remoteWorkPerDay;
  final double remoteWorkMax;
  final double unemploymentInsuranceMaxDeductible;
  final double pensionSchemeMaxDeductible;

  Deductions({
    required this.employeeAllowance,
    required this.investorAllowance,
    this.socialSecurityAllowance,
    required this.childAllowance,
    required this.lumpSumSpecialExpense,
    required this.alimonyMaxDeductible,
    required this.educationExpenseLimit,
    required this.childEducationExpense,
    required this.remoteWorkPerDay,
    required this.remoteWorkMax,
    required this.unemploymentInsuranceMaxDeductible,
    required this.pensionSchemeMaxDeductible,
  });

  /// Factory constructor to create an instance from JSON
  factory Deductions.fromJson(Map<String, dynamic> json) {
    return Deductions(
      employeeAllowance: (json['employeeAllowance'] ?? 0).toDouble(),
      investorAllowance: (json['investorAllowance'] ?? 0).toDouble(),
      socialSecurityAllowance: json['socialSecurityAllowance'] != null
          ? (json['socialSecurityAllowance']).toDouble()
          : null,
      childAllowance: (json['childAllowance'] ?? 0).toDouble(),
      lumpSumSpecialExpense: (json['lumpSumSpecialExpense'] ?? 0).toDouble(),
      alimonyMaxDeductible: (json['alimonyMaxDeductible'] ?? 0).toDouble(),
      educationExpenseLimit: (json['educationExpenseLimit'] ?? 0).toDouble(),
      childEducationExpense: (json['childEducationExpense'] ?? 0).toDouble(),
      remoteWorkPerDay: (json['remoteWorkPerDay'] ?? 0).toDouble(),
      remoteWorkMax: (json['remoteWorkMax'] ?? 0).toDouble(),
      unemploymentInsuranceMaxDeductible:
          (json['unemploymentInsuranceMaxDeductible'] ?? 0).toDouble(),
      pensionSchemeMaxDeductible: (json['pensionSchemeMaxDeductible'] ?? 0)
          .toDouble(),
    );
  }

  /// Convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      'employeeAllowance': employeeAllowance,
      'investorAllowance': investorAllowance,
      'socialSecurityAllowance': socialSecurityAllowance,
      'childAllowance': childAllowance,
      'lumpSumSpecialExpense': lumpSumSpecialExpense,
      'alimonyMaxDeductible': alimonyMaxDeductible,
      'educationExpenseLimit': educationExpenseLimit,
      'childEducationExpense': childEducationExpense,
      'remoteWorkPerDay': remoteWorkPerDay,
      'remoteWorkMax': remoteWorkMax,
      'unemploymentInsuranceMaxDeductible': unemploymentInsuranceMaxDeductible,
      'pensionSchemeMaxDeductible': pensionSchemeMaxDeductible,
    };
  }
}
