# Projection rebuild + correctness fixes — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (native, as established last session) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Annual Projection feature fully functional on a live working calculation, and fix the 12 audit-confirmed wrong-logic findings.

**Architecture:** The projection screen renders from `CalculatorProvider.result` (the engine's annual result for the current working inputs) — no second tax engine. Chart is a value-compared CustomPainter. All fixes are either config data (JSON), shared-engine corrections (`task_calculator.dart`), or provider/UI wiring.

**Tech Stack:** Flutter/Dart, Provider, Hive (nothing new).

**Spec:** `docs/superpowers/specs/2026-10-29-projection-rebuild-and-fixes.md`

## Global Constraints

- Premium gating only via `FeatureAccess`; saved data never hidden on lapse.
- No tax values hard-coded in Dart — SS cap value lives in `us.json` only.
- `dart format`, `flutter analyze` ≤ baseline (18 issues), `flutter test` all green, each task committed.
- Widget-test pattern: `testWidgets` + in-memory `FakeBox` + `tester.runAsync` drains (as established).
- `PaycheckResult` values are annual; `netIncome = gross − totalTax − preTax − postTax` stays true.

## Review Focus

- High income ($200k+) after SS cap: expect SS tax stops at $11,439/yr while Medicare keeps 1.45% on all wages → pinned in Task 2.
- Flat-tax state with standard deduction (Arizona): state tax = 2.5% of (income − 8350), and federal taxable no longer reduced by the state deduction → pinned in Task 4 (note: federal tax will go *up* vs old wrong behavior — that is the fix).
- Salaried user picks "× hourly" overtime: model must not charge OT unless an explicit rate exists (validator message "Set an hourly rate first" becomes real) → pinned in Task 5.
- User edits only overtime on an active profile: header dot must appear → pinned in Task 6.
- Zero/negative income input: no NaN in UI, bars render empty, no crash → pinned in Task 3 / Task 9.

---

### Task 1: Config loading — Germany deductions key

**Files:** Modify `lib/data/models/tax_config.dart:34`; Test `test/models/tax_config_test.dart` (create).

- [x] **Step 1: Failing test** — `TaxConfig.fromJson` on a map with `deductions` key (`{"country":"de","currency":"€","extraTaxes":[],"deductions":{"type":"rate","value":0.093,"cap":2400}}` — shape per `Deductions.fromJson`) yields non-null `deductions`. Run: fails (null today).
- [x] **Step 2: Implement** — guard on `json['deductions']`, parse the same key.
- [x] **Step 3: Commit** `fix: Germany deductions JSON key never matched`.

### Task 2: US Social Security wage-base cap (config-supplied)

**Files:** Modify `assets/taxes/us.json` (Social Security entry only); Test `test/domain/extras_test.dart`.

- [x] **Step 1: Failing tests** — (a) loaded `us.json` Social Security ExtraTax has `type == 'capped'` and `cap != null`; (b) engine test: income 250,000 → SS-line sum ≈ 11,439.00 (0.062 × 184,500, from JSON), Medicare line ≈ 250,000 × 0.0145.
- [x] **Step 2: Implement** — `"type": "capped", "cap": 184500` on the SS entry (engine `capped` branch exists).
- [x] **Step 3: Commit** `fix: US Social Security applies 2026 wage-base cap from config`.

### Task 3: Effective tax rate guard

**Files:** Modify `lib/domain/calculators/task_calculator.dart` (`effectiveTaxRate`); Test `test/domain/extras_test.dart`.

- [x] **Step 1: Failing test** — zero income result: `effectiveTaxRate` is 0 (today NaN).
- [x] **Step 2: Implement** — `annualIncome > 0 ? totalTax / annualIncome : 0`.
- [x] **Step 3: Commit** `fix: guard effective tax rate against zero income`.

### Task 4: Region tax base (flat honors own deduction; federal base untouched)

**Files:** Modify `lib/domain/calculators/task_calculator.dart` (`calculate`, `calculateRegionTax`, drop the shared `applyRegionDeductions` call); Test `test/domain/region_tax_test.dart` (create).

- [x] **Step 1: Failing tests (load real us.json config + RegionTax fixtures by code)**
  - Arizona (flat, std 8350): 75k single → region tax ≈ (75000 − 8350) × 0.025.
  - Federal line for the same case *increases* relative to a no-region clone (state deduction no longer trims federal taxable): assert main income tax equals the no-region case at the same income/status.
  - Progressive region (California-style fixture with brackets): region brackets apply to `taxableIncome − regionDeductions`, federal unchanged.
- [x] **Step 2: Implement** — in `calculate()`: region deductions no longer subtracted from the shared taxable income; `calculateRegionTax` computes its own base: flat → `(annualIncome − regionStd − exemption) · rate` clamped ≥ 0; progressive → `calculateBrackets(taxableIncome − regionDeductions, …)`. Remove `applyRegionDeductions` (no overrides exist; verified by grep).
- [x] **Step 3: Commit** `fix: region deductions apply to the region tax base, not federal`.

### Task 5: Per-period user deductions + overtime rate sourcing

**Files:** Modify `lib/domain/usecases/profile_inputs.dart` (`extrasFromInputs` non-percentage amount × `periodsPerYear(frequency)`); Modify `lib/features/calculator/provider/calculator_provider.dart` (default `hourlyRate = 0`; `buildExtras` passes `hourlyRate: frequency == PayFrequency.hourly ? income : hourlyRate`); Tests `test/domain/profile_inputs_test.dart`, `test/providers/calculator_provider_inputs_test.dart`.

- [x] **Step 1: Failing tests** — (a) annually frequency, $100/mo... concretely: income 52,500 annually, deduction `value: 100` non-percentage → pre-tax annual = 1000 with biweekly? No — annual frequency ⇒ periods=1... choose biWeekly: income per period 2000, `value: 100` non-percentage pre-tax ⇒ `preTaxDeductionsAnnual == 2600` (today 100). Percentage deductions unchanged. (b) engine-level via `extrasFor`: same math. (c) OT: annual salary 100k, `×1.5` multiplier OT, `hourlyRate: 0` ⇒ `additionalAnnualGross == 0` (today 25×1.5×days); hourly frequency: per-period income 40 ⇒ OT annual uses 40 as ordinary rate.
- [x] **Step 2: Implement** both one-liners; break no percentage path.
- [x] **Step 3: Commit** `fix: per-period deductions annualize; overtime rate not invented from defaults`.

### Task 6: Provider staleness — regions/results + unsaved-changes key

**Files:** Modify `lib/features/calculator/provider/calculator_provider.dart` (`applyProfile`, `setCountry`); Modify `lib/features/calculator/provider/profile_provider.dart` (`hasUnsavedChanges`); Tests `test/providers/calculator_provider_inputs_test.dart`, `test/providers/profile_provider_test.dart`.

- [x] **Step 1: Failing tests** — (a) setCountry to a non-regions country leaves regionA/regionB null and clears resultA/resultB (today stale + kept); (b) applyProfile from a country-profile resets regionA/B to new config first/last; (c) editing only overtime flips `hasUnsavedChanges` to true.
- [x] **Step 2: Implement** — `setCountry`/`applyProfile`: regionA = config?.regions?items first, regionB last (or null), resultA = resultB = null. Add `'overtime'` key to the unsaved-changes comparison (jsonEncode like the lists).
- [x] **Step 3: Commit** `fix: reset compare state on country/profile switch; overtime counts as unsaved change`.

### Task 7: Saved-cards currency + result freshness

**Files:** Modify `lib/features/calculator/presentation/screens/saved_calculations_screen.dart` (`ProfileCard`); Test `test/screens/saved_calculations_screen_test.dart`.

- [x] **Step 1: Failing tests** — card shows the profile's own currency (German profile + US working country ⇒ € formatting); renaming/remount-free update recomputes the result (didUpdateWidget path).
- [x] **Step 2: Implement** — currency from `profile.country`; `didUpdateWidget` re-creates `_resultFuture` when `widget.profile != oldWidget.profile` (bi-temporal via `updatedAt`/value equality).
- [x] **Step 3: Commit** `fix: saved cards use profile currency and refresh results`.

### Task 8: Breakdown includes user deductions

**Files:** Modify `lib/features/calculator/presentation/widgets/breakdown_bar.dart`, `breakdown_list.dart`; Test `test/screens/home_sections_test.dart`.

- [x] **Step 1: Failing tests** — result with pre 500/post 300 renders list rows labeled pre-tax/post-tax amounts, and bar adds segments (widget finds ≥2 extra segment children when both > 0).
- [x] **Step 2: Implement** — conditionally append segments/rows when > 0.
- [x] **Step 3: Commit** `fix: breakdown surfaces user pre/post-tax deductions`.

### Task 9: Home wiring + compare hint counts

**Files:** Modify `lib/features/calculator/presentation/screens/home_screen.dart`, `lib/features/calculator/presentation/widgets/home_header.dart` (remove `onCompare`/`onAnnualProjection` params), `lib/features/calculator/presentation/widgets/empty_compare_hint.dart`; Tests `test/screens/home_sections_test.dart` (hint counts cases 0/1/2 selected).

- [x] **Step 1: Failing tests** — hint shows "Select 1 more region" with regionA set; "2 more regions" with none; no hint path broken with regions == null. Header test: const-constructible without the two callbacks.
- [x] **Step 2: Implement** — count = (regionA != null ? 1 : 0) + (regionB != null ? 1 : 0), remaining = 2 − count; strip dead params + call sites.
- [x] **Step 3: Commit** `fix: compare hint counts and dead header callbacks`.

### Task 10: Projection screen — live source, gate, chip, retry

**Files:** Modify `lib/features/calculator/presentation/screens/annual_projection_screen.dart`; Tests `test/screens/annual_projection_screen_test.dart` (replace tautologies with real asserts).

**Interfaces:**
- Consumes: `CalculatorProvider.result`, `CalculatorProvider.snapshotToProfile()`, `ProfileProvider.hasUnsavedChanges`, `projectYear(profile, result)`, `FeatureAccess.canProject(hasAccess)`, `SubscriptionProvider.hasAccess`, `SubscriptionPlansScreen`.
- Produces: `_ProjectionBody(result, profile)` shape used by Task 11's chart embed (unchanged public API of the file; chart widget API in Task 11).

- [x] **Step 1: Failing tests** — (a) no `hasAccess`: intro card + "Explore premium" CTA, no bars; (b) with `hasAccess` + provider result: annual net card text present and equals provider result net formatted; (c) `hasUnsavedChanges` true ⇒ chip visible, false ⇒ hidden; (d) error future ⇒ Retry button that re-issues (smoke: tap does not throw).
- [x] **Step 2: Implement** — convert screen to watch CalculatorProvider for result + snapshot; keep shell classes; gate first; fallback loader while result null; note text mentions "26 (occasionally 27) pay periods".
- [x] **Step 3: Commit** `feat: projection follows the live working calculation with premium gate and unsaved chip`.

### Task 11: MonthlyBarsChart rebuild — selection, readout, theming, value repaint

**Files:** Modify `lib/features/calculator/presentation/widgets/monthly_bars_chart.dart`; Tests `test/screens/annual_projection_screen_test.dart` or new `test/screens/monthly_bars_chart_test.dart`.

- [x] **Step 1: Failing tests** — (a) tapping bar i sets selected value readout text for month i+1 (e.g. tap leftmost → "Jan"-labelled selection with formatted net); (b) drag across shows last-dragged month readout; (c) dark theme: painter colors resolve (pump in dark ThemeData, assert no fixed `AppColors.primary` — via theme-dependent rendering, test builder uses colorScheme tertiary…) — concretely: selected bar color equals `theme.colorScheme.primary` path by asserting the readout + a golden-free structural assert; keep simple: no test on colors, but a test that the widget renders in dark theme without exception; (d) `shouldRepaint` returns false when points values identical (construct painter, compare instances).
- [x] **Step 2: Implement** — single hit-test `barIndexFromX(x, width)` shared by drag+tap (fixes month-13); readout row; painter takes `ColorScheme`-derived colors; value-based `shouldRepaint`; Semantics.
- [x] **Step 3: Commit** `feat: interactive themed month bars with selection readout`.

### Task 12: Full validation sweep

- [x] **Step 1:** `dart format .` clean; `flutter analyze` ≤ 18 known issues (0 errors); `flutter test` fully green; `flutter build apk --debug` succeeds.
- [x] **Step 2:** Update ledger `.superpowers/sdd/2026-10-27-feature-expansion/progress.md` with tasks 1–12 lines; commit `docs: projection rebuild + fixes validation`.
