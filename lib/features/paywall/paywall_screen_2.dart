// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:paycheck_calculator/features/paywall/widgets/hero_placeholder.dart';

// // ─────────────────────────────────────────────
// // Data model
// // ─────────────────────────────────────────────
// class PurchaseProductDetails {
//   final String price;
//   final String productId;
//   final String duration;
//   final String durationPlanName;
//   final bool hasTrial;

//   const PurchaseProductDetails({
//     required this.price,
//     required this.productId,
//     required this.duration,
//     required this.durationPlanName,
//     required this.hasTrial,
//   });
// }

// // ─────────────────────────────────────────────
// // Simulated purchase model (replace with your
// // real StoreKit / RevenueCat / in_app_purchase
// // implementation)
// // ─────────────────────────────────────────────
// class PurchaseModel extends ChangeNotifier {
//   bool isFetchingProducts = true;
//   bool isPurchasing = false;
//   bool isSubscribed = false;

//   List<PurchaseProductDetails> productDetails = [];

//   PurchaseModel() {
//     _loadProducts();
//   }

//   Future<void> _loadProducts() async {
//     await Future.delayed(const Duration(seconds: 1));
//     productDetails = const [
//       PurchaseProductDetails(
//         price: '\$4.99',
//         productId: 'com.app.weekly',
//         duration: 'week',
//         durationPlanName: 'Weekly Plan',
//         hasTrial: true,
//       ),
//       PurchaseProductDetails(
//         price: '\$39.99',
//         productId: 'com.app.yearly',
//         duration: 'year',
//         durationPlanName: 'Yearly Plan',
//         hasTrial: false,
//       ),
//     ];
//     isFetchingProducts = false;
//     notifyListeners();
//   }

//   Future<void> purchaseSubscription(String productId) async {
//     isPurchasing = true;
//     notifyListeners();
//     await Future.delayed(const Duration(seconds: 2));
//     isSubscribed = true;
//     isPurchasing = false;
//     notifyListeners();
//   }

//   Future<void> restorePurchases() async {
//     await Future.delayed(const Duration(seconds: 1));
//     notifyListeners();
//   }

//   String get lastProductId =>
//       productDetails.isNotEmpty ? productDetails.last.productId : '';
// }

// // ─────────────────────────────────────────────
// // PurchaseView
// // ─────────────────────────────────────────────
// class PurchaseView extends StatefulWidget {
//   final VoidCallback onDismiss;
//   final bool hasCooldown;

//   const PurchaseView({
//     super.key,
//     required this.onDismiss,
//     this.hasCooldown = true,
//   });

//   @override
//   State<PurchaseView> createState() => _PurchaseViewState();
// }

// class _PurchaseViewState extends State<PurchaseView>
//     with TickerProviderStateMixin {
//   late final PurchaseModel _model;

//   late final AnimationController _lockController;
//   late final Animation<double> _lockAnim;

//   // ── close button cooldown ──
//   static const double _allowCloseAfter = 5.0; // seconds
//   bool _showCloseButton = false;
//   late final AnimationController _progressController;

//   // ── hero shake ──
//   late final AnimationController _shakeController;
//   late final Animation<double> _shakeAngle;
//   late final AnimationController _zoomController;
//   late final Animation<double> _zoomAnim;

//   // ── selection ──
//   String _selectedProductId = '';

//   // ── placeholder products shown while loading ──
//   static const List<PurchaseProductDetails> _placeholders = [
//     PurchaseProductDetails(
//       price: '—',
//       productId: 'demo1',
//       duration: 'week',
//       durationPlanName: 'Weekly Plan',
//       hasTrial: false,
//     ),
//     PurchaseProductDetails(
//       price: '—',
//       productId: 'demo2',
//       duration: 'year',
//       durationPlanName: 'Yearly Plan',
//       hasTrial: false,
//     ),
//   ];

//   static const Color _accent = Color(0xFF2563EB); // blue

//   @override
//   void initState() {
//     super.initState();

//     _lockController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _lockAnim = CurvedAnimation(
//       parent: _lockController,
//       curve: Curves.easeInOut,
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _lockController.forward();
//     });

//     _model = PurchaseModel()..addListener(_onModelChange);

//     // Cooldown timer
//     _progressController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: (_allowCloseAfter * 1000).toInt()),
//     );

//     // Shake angle
//     _shakeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _shakeAngle =
//         TweenSequence<double>([
//           TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
//           TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
//           TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
//           TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 1),
//           TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
//         ]).animate(
//           CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
//         );

//     // Zoom pulse
//     _zoomController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _zoomAnim =
//         TweenSequence<double>([
//           TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.95), weight: 1),
//           TweenSequenceItem(tween: Tween(begin: 0.95, end: 0.9), weight: 1),
//         ]).animate(
//           CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
//         );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Start cooldown
//       Future.delayed(const Duration(milliseconds: 600), () {
//         if (!mounted) return;
//         _progressController.forward();
//         Future.delayed(
//           Duration(milliseconds: (_allowCloseAfter * 1000).toInt()),
//           () {
//             if (!mounted) return;
//             setState(() => _showCloseButton = true);
//           },
//         );
//       });

//       // Start shake loop
//       Future.delayed(const Duration(seconds: 1), _startShakeLoop);
//     });
//   }

//   void _startShakeLoop() {
//     if (!mounted) return;
//     _shakeController.forward(from: 0);
//     _zoomController.forward(from: 0);
//     Future.delayed(const Duration(milliseconds: 700 + 1300), _startShakeLoop);
//   }

//   void _onModelChange() {
//     if (!mounted) return;
//     setState(() {
//       if (_selectedProductId.isEmpty && _model.productDetails.isNotEmpty) {
//         _selectedProductId = _model.lastProductId;
//       }
//     });
//     if (_model.isSubscribed) {
//       Future.delayed(const Duration(milliseconds: 100), widget.onDismiss);
//     }
//   }

//   @override
//   void dispose() {
//     _model
//       ..removeListener(_onModelChange)
//       ..dispose();
//     _progressController.dispose();
//     _shakeController.dispose();
//     _zoomController.dispose();
//     _lockController.dispose();
//     super.dispose();
//   }

//   // ── helpers ──────────────────────────────────

//   double? get _weeklyPriceDouble {
//     final s = _model.productDetails
//         .where((p) => p.duration == 'week')
//         .map((p) => _parsePrice(p.price))
//         .whereType<double>()
//         .firstOrNull;
//     return s;
//   }

//   double? get _fullAnnualFromWeekly {
//     final w = _weeklyPriceDouble;
//     return w != null ? w * 52 : null;
//   }

//   int get _percentageSaved {
//     final full = _fullAnnualFromWeekly;
//     if (full == null) return 90;
//     final yearlyStr = _model.productDetails
//         .where((p) => p.duration == 'year')
//         .map((p) => p.price)
//         .firstOrNull;
//     if (yearlyStr == null) return 90;
//     final yearly = _parsePrice(yearlyStr);
//     if (yearly == null || full <= 0) return 90;
//     final saved = (100 - (yearly / full * 100)).round();
//     return saved > 0 ? saved : 90;
//   }

//   double? _parsePrice(String price) {
//     final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
//     return double.tryParse(cleaned);
//   }

//   String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

//   String get _callToActionText {
//     final selected = _model.productDetails
//         .where((p) => p.productId == _selectedProductId)
//         .firstOrNull;
//     if (selected?.hasTrial == true) return 'Start Free Trial';
//     return 'Unlock Now';
//   }

//   // ── build ─────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             children: [
//               const SizedBox(height: 32),
//               _buildTopBar(),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 8),
//                       _buildHero(),
//                       const SizedBox(height: 20),
//                       _buildHeadline(),
//                       const SizedBox(height: 16),
//                       _buildFeatures(),
//                       const SizedBox(height: 32),
//                       _buildProductCards(),
//                       const SizedBox(height: 20),
//                       _buildCTAButton(),
//                       const SizedBox(height: 24),
//                       _buildFooter(),
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── top bar ───────────────────────────────────

//   Widget _buildTopBar() {
//     return SizedBox(
//       height: 44,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           if (widget.hasCooldown && !_showCloseButton)
//             AnimatedBuilder(
//               animation: _progressController,
//               builder: (_, _) => SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CustomPaint(
//                   painter: _ArcPainter(
//                     progress: _progressController.value,
//                     color: Colors.black.withOpacity(0.2),
//                   ),
//                 ),
//               ),
//             )
//           else
//             GestureDetector(
//               onTap: widget.onDismiss,
//               child: const Icon(Icons.close, size: 22, color: Colors.black38),
//             ),
//         ],
//       ),
//     );
//   }

//   // ── hero ──────────────────────────────────────

//   Widget _buildHero() {
//     return AnimatedBuilder(
//       animation: Listenable.merge([_shakeController, _zoomController]),
//       builder: (_, _) => Transform.rotate(
//         angle: _shakeAngle.value * pi / 180,
//         child: Transform.scale(
//           scale: _zoomAnim.value,
//           child: Container(
//             height: 150,
//             alignment: Alignment.center,
//             child: HeroPlaceholder(color: _accent, animation: _lockAnim),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── headline ──────────────────────────────────

//   Widget _buildHeadline() {
//     return Column(
//       children: const [
//         Text(
//           'Start a 3-Day Free Trial',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.w700,
//             color: Colors.black87,
//             height: 1.2,
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           'Cancel anytime before your trial ends',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//             color: Colors.black54,
//             height: 1.3,
//           ),
//         ),
//       ],
//     );
//   }
//   // ── features ──────────────────────────────────

//   Widget _buildFeatures() {
//     const features = [
//       (icon: Icons.lock_open_rounded, label: 'Unlock full app functionality'),
//       (
//         icon: Icons.insights_rounded,
//         label: 'Advanced financial scenario tools',
//       ),
//       (
//         icon: Icons.auto_graph_rounded,
//         label: 'Always-updated tax intelligence',
//       ),
//       (icon: Icons.remove_red_eye_rounded, label: 'Ad-free premium experience'),
//     ];
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: features
//           .map(
//             (f) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 5),
//               child: Row(
//                 children: [
//                   Icon(f.icon, color: _accent, size: 26),
//                   const SizedBox(width: 12),
//                   Text(
//                     f.label,
//                     style: const TextStyle(fontSize: 16, color: Colors.black87),
//                   ),
//                 ],
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }

//   // ── product cards ─────────────────────────────

//   Widget _buildProductCards() {
//     if (_model.isFetchingProducts) {
//       return const SizedBox(
//         height: 120,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final products = _model.productDetails;
//     final full = _fullAnnualFromWeekly;

//     return Column(
//       children: products.map((p) {
//         final isSelected = _selectedProductId == p.productId;

//         Widget subtitleWidget;
//         if (p.hasTrial) {
//           subtitleWidget = Text(
//             'then ${p.price} per ${p.duration}',
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.black.withOpacity(0.6),
//             ),
//           );
//         } else {
//           subtitleWidget = Row(
//             children: [
//               if (full != null && full > 0) ...[
//                 Text(
//                   '${_formatCurrency(full)} ',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.black.withOpacity(0.4),
//                     decoration: TextDecoration.lineThrough,
//                   ),
//                 ),
//               ],
//               Text(
//                 '${p.price} per ${p.duration}',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.black.withOpacity(0.6),
//                 ),
//               ),
//             ],
//           );
//         }

//         Widget? trailingBadge;
//         if (!p.hasTrial) {
//           trailingBadge = Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//             decoration: BoxDecoration(
//               color: Colors.red,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               'SAVE $_percentageSaved%',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           );
//         }

//         return GestureDetector(
//           onTap: () => setState(() => _selectedProductId = p.productId),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             margin: const EdgeInsets.only(bottom: 10),
//             decoration: BoxDecoration(
//               color: isSelected ? _accent.withOpacity(0.05) : Colors.white,
//               border: Border.all(
//                 color: isSelected ? _accent : Colors.black12,
//                 width: isSelected ? 1.5 : 1,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         p.durationPlanName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 15,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       subtitleWidget,
//                     ],
//                   ),
//                 ),
//                 if (trailingBadge != null) ...[
//                   trailingBadge,
//                   const SizedBox(width: 10),
//                 ],
//                 // Radio circle
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   width: 22,
//                   height: 22,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isSelected ? _accent : Colors.transparent,
//                     border: Border.all(
//                       color: isSelected ? _accent : Colors.black26,
//                       width: 1.5,
//                     ),
//                   ),
//                   child: isSelected
//                       ? const Icon(Icons.check, size: 14, color: Colors.white)
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ── CTA button ────────────────────────────────

//   Widget _buildCTAButton() {
//     if (_model.isFetchingProducts) return const SizedBox.shrink();

//     final isLoading = _model.isPurchasing;

//     return SizedBox(
//       width: double.infinity,
//       height: 54,
//       child: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 200),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : ElevatedButton(
//                 onPressed: _selectedProductId.isEmpty
//                     ? null
//                     : () {
//                         if (!_model.isPurchasing) {
//                           _model.purchaseSubscription(_selectedProductId);
//                         }
//                       },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _accent,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: _accent.withOpacity(0.4),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       _callToActionText,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     const Icon(Icons.arrow_forward_ios, size: 14),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   // ── footer ────────────────────────────────────

//   Widget _buildFooter() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _FooterLink(
//           label: 'Restore',
//           onTap: () async {
//             await _model.restorePurchases();
//             if (!mounted) return;
//             if (!_model.isSubscribed) {
//               showDialog(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text('Restore Purchases'),
//                   content: const Text('No purchases restored'),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('OK'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         ),
//         const SizedBox(width: 16),
//         _FooterLink(
//           label: 'Terms & Privacy',
//           onTap: () => _showTermsSheet(context),
//         ),
//       ],
//     );
//   }

//   void _showTermsSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(height: 8),
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.black12,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Terms & Conditions',
//               style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             ListTile(
//               leading: const Icon(Icons.description_outlined),
//               title: const Text('Terms of Use'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // launch URL
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.privacy_tip_outlined),
//               title: const Text('Privacy Policy'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // launch URL
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.close),
//               title: const Text('Cancel'),
//               onTap: () => Navigator.pop(context),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // Supporting widgets
// // ─────────────────────────────────────────────

// class _FooterLink extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;

//   const _FooterLink({required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 13,
//           color: Colors.grey,
//           decoration: TextDecoration.underline,
//           decorationColor: Colors.grey,
//         ),
//       ),
//     );
//   }
// }

// /// Circular arc progress indicator for the close button cooldown.
// class _ArcPainter extends CustomPainter {
//   final double progress;
//   final Color color;

//   const _ArcPainter({required this.progress, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = 2.5
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     canvas.drawArc(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       -pi / 2,
//       2 * pi * progress,
//       false,
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(_ArcPainter old) =>
//       old.progress != progress || old.color != color;
// }
