/// Optional annualized amounts layered onto the base tax calculation.
/// All values are annual figures; `null` extras leave engine behavior unchanged.
class CalculationExtras {
  final double additionalAnnualGross;
  final double preTaxDeductionsAnnual;
  final double postTaxDeductionsAnnual;

  const CalculationExtras({
    this.additionalAnnualGross = 0,
    this.preTaxDeductionsAnnual = 0,
    this.postTaxDeductionsAnnual = 0,
  });

  bool get isZero =>
      additionalAnnualGross == 0 &&
      preTaxDeductionsAnnual == 0 &&
      postTaxDeductionsAnnual == 0;
}
