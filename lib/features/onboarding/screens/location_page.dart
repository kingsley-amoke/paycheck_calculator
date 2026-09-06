import 'package:flutter/material.dart';
import 'package:paycheck_calculator/core/constants/app_colors.dart';
import 'package:paycheck_calculator/core/constants/enums.dart';
import 'package:paycheck_calculator/core/widgets/country_label.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/styled_dropdown.dart';
import 'package:paycheck_calculator/features/calculator/presentation/widgets/styled_region_dropdown.dart';
import 'package:paycheck_calculator/features/calculator/provider/calculator_provider.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/fade_up_animation.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/subtitle_text.dart';
import 'package:paycheck_calculator/features/onboarding/widgets/title_text.dart';
import 'package:provider/provider.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({
    super.key,
    required this.fadeAnims,
    required this.slideAnims,
  });

  final List<Animation<double>> fadeAnims;
  final List<Animation<Offset>> slideAnims;

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final regions = provider.taxConfig?.regions?.items ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeUpAnimation(
            fades: widget.fadeAnims,
            slides: widget.slideAnims,
            index: 1,
            child: const Icon(
              Icons.public_rounded,
              size: 100,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 32),

          FadeUpAnimation(
            fades: widget.fadeAnims,
            slides: widget.slideAnims,
            index: 2,
            child: const TitleText(text: 'Where Do You ', styledText: 'Work?'),
          ),

          const SizedBox(height: 16),

          FadeUpAnimation(
            fades: widget.fadeAnims,
            slides: widget.slideAnims,
            index: 3,
            child: const SubtitleText(
              text:
                  'We use your location to calculate accurate taxes and deductions.',
            ),
          ),

          const SizedBox(height: 32),

          StyledDropdown<Country>(
            label: 'Country',
            value: provider.country,
            items: Country.values,
            itemLabel: (c) => countryLabel(c),
            onChanged: (c) {
              provider.setCountry(c);
            },
          ),
          const SizedBox(height: 16),
          StyledRegionDropdown(
            label: 'State / Region',
            value: provider.regionA,
            regions: regions,
            excludeValue: provider.regionB,
            onChanged: (val) {
              provider.setRegionA(val);
            },
          ),
        ],
      ),
    );
  }
}
