import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const Color _primary = Color(0xFF2563EB);
  static const Color _text = Color(0xFF172033);
  static const Color _muted = Color(0xFF64748B);
  static const Color _background = Color(0xFFF8FAFC);

  static const String _lastUpdated = 'October 12, 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _text,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Terms of Use',
          style: TextStyle(
            color: _text,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              _section(
                '1. Acceptance of Terms',
                'By accessing or using Paycheck Calculator, you '
                    'agree to these Terms of Use. If you do not agree '
                    'to these terms, please discontinue using the app.',
              ),

              _section(
                '2. About the App',
                'Paycheck Calculator helps you estimate take-home '
                    'pay by applying available tax and deduction '
                    'calculations to the information you provide. '
                    'Features and supported regions may vary by '
                    'version and subscription plan.',
              ),

              _section(
                '3. Estimates and Financial Disclaimer',
                'All calculations are estimates provided for general '
                    'informational and educational purposes. Results '
                    'may differ from your actual paycheck because of '
                    'changes in tax laws, employer policies, benefits, '
                    'deductions, local regulations, or personal '
                    'circumstances.\n\n'
                    'The app does not provide professional tax, legal, '
                    'accounting, or financial advice. Do not rely '
                    'solely on its results for tax filings, payroll '
                    'decisions, or other financial obligations. '
                    'Consult a qualified professional or the relevant '
                    'tax authority when necessary.',
              ),

              _section(
                '4. Subscriptions and Payments',
                'Certain features require an active paid subscription. '
                    'Available plans, prices, billing periods, and '
                    'included features are displayed in the app '
                    'before you purchase.\n\n'
                    'Subscriptions are processed through the '
                    'applicable app store. By subscribing, you '
                    'authorize recurring charges at the displayed '
                    'price and billing interval, subject to the '
                    'applicable store terms, unless you cancel '
                    'before renewal.',
              ),

              _section(
                '5. Free Trials and Introductory Offers',
                'A free trial or introductory offer may be available '
                    'for eligible users and selected plans. Its '
                    'duration, eligibility requirements, and terms '
                    'will be displayed before you subscribe.\n\n'
                    'Unless the applicable offer states otherwise, '
                    'a subscription with automatic renewal will '
                    'begin charging the applicable subscription price '
                    'when the trial or introductory period ends. '
                    'Cancel before the trial expires if you do not '
                    'wish to continue with a paid subscription.\n\n'
                    'Trial eligibility is determined by the '
                    'applicable app store and offer conditions.',
              ),

              _section(
                '6. Cancellation and Refunds',
                'You can manage or cancel your subscription through '
                    'the app store account used to purchase it. '
                    'Deleting the app does not automatically cancel '
                    'your subscription.\n\n'
                    'Cancellation generally prevents future '
                    'renewals; access may continue until the end '
                    'of the current paid period, subject to the '
                    'applicable store terms. Refund requests are '
                    'subject to the relevant app store policies '
                    'and applicable law.',
              ),

              _section(
                '7. Your Responsibilities',
                'You are responsible for providing accurate '
                    'information when using the calculator and '
                    'reviewing your results before relying on them. '
                    'You agree not to misuse the app, interfere '
                    'with its operation, or attempt to bypass '
                    'applicable access restrictions.',
              ),

              _section(
                '8. Privacy and Your Information',
                'Your information should be handled in accordance '
                    'with our Privacy Policy. Please review that '
                    'policy to understand what information the app '
                    'collects, how it is used, and any applicable '
                    'data retention and deletion practices.',
              ),

              _section(
                '9. Availability and Changes',
                'We may update, improve, or modify the app and its '
                    'features from time to time. We will make '
                    'reasonable efforts to maintain the service, '
                    'but uninterrupted availability cannot be '
                    'guaranteed. Nothing in these terms excludes '
                    'rights that cannot lawfully be excluded.',
              ),

              _section(
                '10. Changes to These Terms',
                'These terms may be revised as the app evolves or '
                    'when required by law. The latest version and '
                    'its effective date will be displayed here. '
                    'Where required, we will provide notice of '
                    'material changes.',
              ),

              _section(
                '11. Contact Us',
                'If you have questions about these terms, your '
                    'subscription, or the app, contact us using '
                    'the developer contact email published on '
                    'our official app listing.',
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: _primary, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please review these terms alongside our '
                        'Privacy Policy.',
                        style: TextStyle(
                          color: Color(0xFF1E40AF),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.maybePop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Paycheck Calculator',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   height: 48,
          //   width: 48,
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFEFF6FF),
          //     borderRadius: BorderRadius.circular(14),
          //   ),
          //   child: const Icon(
          //     Icons.description_outlined,
          //     color: _primary,
          //     size: 26,
          //   ),
          // ),
          // const SizedBox(height: 18),
          // const Text(
          //   'Terms and Conditions',
          //   style: TextStyle(
          //     color: _text,
          //     fontSize: 23,
          //     fontWeight: FontWeight.w800,
          //     letterSpacing: -0.5,
          //   ),
          // ),
          const SizedBox(height: 8),
          const Text(
            'Please read these terms carefully to understand '
            'your rights and responsibilities when using '
            'Paycheck Calculator.',
            style: TextStyle(color: _muted, fontSize: 14, height: 1.7),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Last updated: $_lastUpdated',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                color: _muted,
                fontSize: 13.5,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
