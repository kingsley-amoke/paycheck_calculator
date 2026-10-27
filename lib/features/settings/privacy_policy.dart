import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color _primary = Color(0xFF2563EB);
  static const Color _text = Color(0xFF172033);
  static const Color _muted = Color(0xFF64748B);
  static const Color _background = Color(0xFFF8FAFC);

  static const String _lastUpdated = 'October 12, 2026';

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Introduction',
      'content':
          'Paycheck Calculator ("the app", "we", "our", or "us") '
          'helps users estimate take-home pay based on the '
          'information they provide. This Privacy Policy explains '
          'how information may be collected, processed, stored, '
          'and shared when you use the app.\n\n'
          'By using the app, you acknowledge this policy. '
          'Where applicable law requires consent for particular '
          'processing activities, we will obtain that consent.',
    },
    {
      'title': '2. Information You Provide',
      'content':
          'The app may process information you enter into the '
          'calculator, such as salary, pay frequency, tax-related '
          'details, deductions, benefits, and other inputs needed '
          'to estimate your paycheck.\n\n'
          'These details are used to calculate and display your '
          'results. The app does not require you to create an '
          'account to use its core calculation features.\n\n'
          'Do not enter sensitive personal information that is '
          'unnecessary for calculating your paycheck.',
    },
    {
      'title': '3. How Your Calculation Data Is Handled',
      'content':
          'Paycheck calculations are intended to be performed '
          'on your device. We do not intentionally transmit your '
          'salary or individual calculation inputs to our servers '
          'unless a feature explicitly requires it.\n\n'
          'Calculation history or preferences may be stored '
          'locally if supported by your app version. Data stored '
          'locally may remain on your device until you delete it, '
          'clear the app data, or uninstall the app, subject to '
          'your device and operating system.\n\n'
          'Please verify these statements against the actual '
          'implementation before publication.',
    },
    {
      'title': '4. Purchases and Subscriptions',
      'content':
          'Paid subscriptions and eligible introductory offers '
          'are managed through the applicable app store and '
          'RevenueCat, our subscription management provider.\n\n'
          'Purchase processing may involve information such as '
          'transaction identifiers, subscription status, product '
          'and entitlement information, purchase history, and '
          'app user identifiers. The app store processes payment '
          'details under its own privacy policy; we do not '
          'directly receive your full payment card details '
          'through RevenueCat.\n\n'
          'We use subscription information to provide access '
          'to paid features, restore purchases, and manage '
          'subscription entitlements.',
    },
    {
      'title': '5. Firebase and Remote Configuration',
      'content':
          'The app uses Firebase Remote Config to retrieve '
          'configuration values that may control app behavior '
          'and feature availability.\n\n'
          'Firebase may process technical information and '
          'installation-related identifiers as part of providing '
          'its services. The information processed depends on '
          'your Firebase configuration and the SDKs enabled '
          'in the app.\n\n'
          'Remote Config is not intended to collect your salary '
          'or individual paycheck calculation inputs.',
    },
    {
      'title': '6. Diagnostics and Technical Information',
      'content':
          'Depending on the services and SDKs enabled in your '
          'app version, technical information may be processed '
          'to maintain reliability, troubleshoot errors, and '
          'improve performance. This may include app version, '
          'device and operating system information, diagnostic '
          'events, crash reports, and installation identifiers.\n\n'
          'We do not claim to collect analytics or crash reports '
          'unless the corresponding services are enabled. '
          'The exact information processed depends on your '
          'configuration.',
    },
    {
      'title': '7. How We Use Information',
      'content':
          'Information processed through the app may be used to:\n\n'
          '• Calculate and display estimated take-home pay.\n'
          '• Provide and maintain subscription access.\n'
          '• Restore eligible purchases.\n'
          '• Deliver app configuration and supported features.\n'
          '• Diagnose technical problems and improve reliability, '
          'where diagnostic services are enabled.\n'
          '• Meet applicable legal obligations and protect '
          'the security of the service.',
    },
    {
      'title': '8. Sharing of Information',
      'content':
          'We do not sell your personal information.\n\n'
          'Information may be processed by service providers '
          'that help operate the app, including Google Play, '
          'Firebase, and RevenueCat, where applicable. These '
          'providers process information according to their '
          'respective roles, agreements, and privacy policies.\n\n'
          'Information may also be disclosed when required by '
          'law, to protect legal rights, or in connection with '
          'a business transfer, subject to applicable law.',
    },
    {
      'title': '9. Data Retention and Deletion',
      'content':
          'Locally stored calculation information may remain '
          'on your device until you delete it or remove the '
          'app, subject to your device settings and backups.\n\n'
          'Information processed by third-party providers may '
          'be retained according to their retention practices, '
          'our applicable agreements, and legal requirements.\n\n'
          'Where applicable law grants you a right to request '
          'access to, correction of, or deletion of personal '
          'information, you may contact us using the details '
          'provided below.',
    },
    {
      'title': '10. Data Security',
      'content':
          'We take reasonable measures to protect information '
          'processed through the app. However, no method of '
          'electronic storage or transmission is completely '
          'secure, and absolute security cannot be guaranteed.\n\n'
          'You should keep your device secure and use its '
          'available security features.',
    },
    {
      'title': '11. Your Privacy Rights',
      'content':
          'Depending on where you live, you may have rights to '
          'access, correct, delete, or obtain a copy of certain '
          'personal information, object to or restrict certain '
          'processing, or withdraw consent where processing '
          'is based on consent.\n\n'
          'To exercise an applicable right, contact us using '
          'the developer email published on our official '
          'app listing. We may need to verify your request '
          'before responding.',
    },
    {
      'title': '12. International Data Processing',
      'content':
          'Our service providers may process information in '
          'countries other than your own. Where required, '
          'appropriate safeguards will be applied to '
          'international transfers of personal information.',
    },
    {
      'title': '13. Children’s Privacy',
      'content':
          'The app is not intended to knowingly collect '
          'personal information from children in violation '
          'of applicable law. If you believe a child has '
          'provided personal information inappropriately, '
          'please contact us so that we can investigate '
          'and take appropriate action.',
    },
    {
      'title': '14. Third-Party Services',
      'content':
          'Third-party services used by the app are governed '
          'by their own privacy policies and terms. Their '
          'processing practices are outside our direct control.\n\n'
          'You can review the privacy information provided by '
          'Google, Firebase, and RevenueCat on their official '
          'websites.',
    },
    {
      'title': '15. Changes to This Policy',
      'content':
          'We may update this Privacy Policy when our app, '
          'service providers, or legal obligations change. '
          'The latest version and its effective date will be '
          'published here. Where required by law, we will '
          'notify users of material changes.',
    },
    {
      'title': '16. Contact Us',
      'content':
          'For privacy questions, requests, or concerns, '
          'contact us using the developer email published '
          'on the official Paycheck Calculator app listing.\n\n'
          'Please replace this contact arrangement with a '
          'working privacy contact email before publishing.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _text,
            size: 20,
          ),
        ),
        title: const Text(
          'Privacy Policy',
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
              const SizedBox(height: 22),

              ..._sections.map(
                (section) =>
                    _buildSection(section['title']!, section['content']!),
              ),

              const SizedBox(height: 8),

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
                    Icon(
                      Icons.verified_user_outlined,
                      color: _primary,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your privacy matters. We aim to handle '
                        'information responsibly and provide '
                        'clear information about how the app works.',
                        style: TextStyle(
                          color: Color(0xFF1E40AF),
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
          //   width: 48,
          //   height: 48,
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFEFF6FF),
          //     borderRadius: BorderRadius.circular(14),
          //   ),
          //   child: const Icon(
          //     Icons.privacy_tip_outlined,
          //     color: _primary,
          //     size: 26,
          //   ),
          // ),
          // const SizedBox(height: 18),
          // const Text(
          //   'Your Privacy Matters',
          //   style: TextStyle(
          //     color: _text,
          //     fontSize: 23,
          //     fontWeight: FontWeight.w800,
          //     letterSpacing: -0.5,
          //   ),
          // ),
          const SizedBox(height: 8),
          const Text(
            'Learn how Paycheck Calculator handles '
            'your information, subscriptions, and '
            'device-related data.',
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
