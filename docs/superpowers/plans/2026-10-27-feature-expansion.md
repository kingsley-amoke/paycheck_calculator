# Paycheck Calculator Feature Expansion — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add multiple saved calculation profiles (Hive), a saved-calculations manager, saved-profile job comparison, overtime, additional income, custom deductions, an annual income projection chart, and an Expense Tracker entry point — as an extension of the existing single-calculation app.

**Architecture:** Profiles are JSON maps stored in a Hive box keyed by stable IDs. `CalculatorProvider` stays the single working-calculation state; a new `ProfileProvider` coordinates Hive persistence and loads profiles into `CalculatorProvider`; a small `ComparisonProvider` computes per-profile engine results without touching active state. The existing `TaxCalculator` engine gains one optional `CalculationExtras` parameter (pre/post-tax deductions, additional annual gross) — same engine, no second implementation.

**Tech Stack:** Flutter + Provider + Hive (new dep: `hive`, `hive_flutter`) + existing RevenueCat/purchases_flutter, url_launcher, intl. No new chart library — CustomPaint (matches existing `DonutChartPainter` convention).

**Spec:** The user's project brief (Sections 1–17) — this plan implements it after Phase 1 inspection.

## Global Constraints

- Hive only for profile persistence. No SQLite/sqflite/Isar/ObjectBox. No Firebase for local features.
- One tax engine. Extend `lib/domain/calculators/task_calculator.dart`; never duplicate.
- Preserve RevenueCat: entitlements `access`/`premium`, `ReviewAccessService`, paywall screens, restore flow — untouched.
- Auth-free UX; no backend. No app-id/signing/production-env changes. No secrets in source.
- Never invent Expense Tracker package/store identifiers — supply as clearly named config constants.
- All comparison/projection numbers come from `TaxCalculatorFactory` + `profile_inputs` mapping.
- Baseline analysis has 3 pre-existing issues (broken `test/widget_test.dart` referencing `MyApp`, unused `_actionButton`, `print` in `purchase_view.dart`). Do not add new issues; fix the widget_test one.

## Inspection Findings (Phase 1)

- Flow: `main` → Firebase + RevenueCat init → `PaycheckApp` → `OnboardingScreen` → `PurchaseView` (paywall) → `MainShell` (`lib/core/widgets/splash.dart`) with 3 tabs: `HomeScreen`, `CompareTaxScreen` (region A vs B of same income), `SettingsScreen`.
- Engine: `TaxCalculator.calculate({income, frequency, filingStatus, region})` normalizes to annual (hourly×40×52, biWeekly×26…), returns annual `PaycheckResult{grossIncome, netIncome, totalTax, effectiveTaxRate, deductions[]}` where `deductions` is the tax breakdown list (name/amount).
- `CalculatorProvider` holds raw inputs: income (default 75000), frequency, country, filingStatus, hourlyRate/hoursPerWeek, regionA/B. No persistence anywhere — `LocalStorageService`, `paywall_service`, `analytics_service` are empty files. **No migration needed**, documented below.
- No user-defined deductions/overtime/additional income; `Deductions` model is Germany-specific allowance config from tax JSON.
- Home card shows annual net pay; breakdown bar/list render `result.deductions`.
- No named routes (`routes.dart` empty); screens pushed with `MaterialPageRoute`.
- `openUrl` util already handles launch failure with a snackbar; `CurrencyFormatter.format(amount, country)` exists.
- Subscription check: `SubscriptionProvider.hasAccess` (from `RevenueCatService.getSubscriptionStatus`); `SubscriptionPlansScreen` is the existing plans screen.

## Global Decisions

- **Storage:** JSON maps, no TypeAdapters/codegen — `Box<Map>` keyed by profile id; `app_state` box holds `active_profile_id`. Tolerant parses (skip + keep others on malformed entries). Maps absorb schema changes; no generated-code fabrication (project has no hive codegen workflow). Add `hive: ^2.2.3`, `hive_flutter: ^1.1.0`.
- **Migration:** None exists today (nothing was ever persisted — `LocalStorageService` empty, no shared_preferences/other storage found in repo). Documented in report; loader handles empty boxes safely.
- **Premium gating (centralized in `FeatureAccess`)**: free users get 1 saved profile, 2 income items, 2 deductions; compare + projection are premium. Saved data always stays visible/editable after lapse; over-limit actions show `SubscriptionPlansScreen`. Never hides/deletes existing profiles.
- **One-time assumptions (documented in UI):** engine is an annualized withholding estimate (no per-paycheck supplemental flat-rate bonus withholding — deferred, engine can't model it); one-time income items and projection charts distribute across months; biweekly/weekly projections use pay *dates* anchored to Jan 1 of the year; salary overtime requires an explicit OT hourly rate (no invented FLSA allocation).
- **Autosave:** when an active profile exists, every calculator input change updates that profile by ID in Hive. Explicit ops (rename/duplicate/delete/create) `await` the Hive `put` before notifying success.

## Review Focus

1. Corrupt/malformed Hive entry → skip it, never crash, keep remaining profiles (pinned in profile_provider_test).
2. Pre-tax deduction must NOT reduce FICA/extra-tax wage base, only income-tax taxable wages (pinned in extras_test).
3. Duplicate must deep-copy income/deduction lists — no shared references (model test).
4. Deleting the active profile → activates first remaining profile, else null with intact working state (provider test).
5. CalculatorProvider↔ProfileProvider listener must not recurse/echo saves (apply-guard flag, pinned in provider test).
6. Comparison must not mutate saved profiles or active id (comparison test).

---

### Task 1: Dependencies + profile data model

**Files:**
- Modify: `pubspec.yaml` (add `hive: ^2.2.3`, `hive_flutter: ^1.1.0`)
- Create: `lib/data/models/calculation_profile.dart`
- Test: `test/models/calculation_profile_test.dart`

**Interfaces (produces):**
- `class OvertimeInput { final double hoursPerPeriod; final double? explicitRate; final double? multiplier; }`
- `enum ExtraIncomeOccurrence { everyPaycheck, oncePerYear }`
- `class ExtraIncomeItem { final String id; final String name; final double amount; final ExtraIncomeOccurrence occurrence; }`
- `enum DeductionKind { traditional401k, roth401k, hsa, insurancePremium, other }`
- `class UserDeduction { final String id; final String name; final double value; final bool isPercentage; final bool preTax; final DeductionKind kind; }`
- `class CalculationProfile { String id; String name; Country country; PayFrequency payFrequency; double income; FilingStatus? filingStatus; String? regionCode; double hourlyRate; double hoursPerWeek; OvertimeInput? overtime; List<ExtraIncomeItem> incomeItems; List<UserDeduction> deductions; DateTime createdAt; DateTime updatedAt; }` with `copyWith`, `toJson` (holds `"v": 1`), `CalculationProfile.fromJson(Map)` (all values defaulted/safe-cast: unknown country/frequency → us/annually; negative numbers clamped at 0; malformed → still valid object).
- Free function `String generateProfileId()` — `DateTime.now().microsecondsSinceEpoch.toRadixString(36)` + random suffix (no uuid dep).

- [ ] Add deps to pubspec, run `flutter pub get`.
- [ ] Write test: roundtrip preserves every field; `fromJson({'id':'x','name':'X','corrupt':true})` (missing fields) produces valid defaults; duplicate via copyWith has new id and items with equal values but distinct list instances; percentages>100 allowed (engine clamps at application); timestamp fields survive.
- [ ] Run `flutter test test/models/calculation_profile_test.dart` → fail → implement model → pass.

### Task 2: Engine extras + pay-period math

**Files:**
- Modify: `lib/domain/entities/paycheck_result.dart` (add defaulted fields), `lib/domain/calculators/task_calculator.dart`
- Create: `lib/domain/entities/calculation_extras.dart`, `lib/domain/usecases/pay_periods.dart`
- Test: `test/domain/extras_test.dart`, `test/domain/pay_periods_test.dart`

**Interfaces (produces):**
- `class CalculationExtras { final double additionalAnnualGross; final double preTaxDeductionsAnnual; final double postTaxDeductionsAnnual; const CalculationExtras({…=0}); }`
- `TaxCalculator.calculate({required double income, required PayFrequency frequency, FilingStatus? filingStatus, RegionTax? region, CalculationExtras? extras})` — annualIncome += `extras?.additionalAnnualGross`; taxableIncome -= `extras?.preTaxDeductionsAnnual` (after standard deduction/allowance/region hooks); extra taxes still computed on **full annualIncome** (FICA wage base not reduced); netIncome = annualIncome − totalTax − `extras?.postTaxDeductionsAnnual`.
- `PaycheckResult` gains **defaulted** fields: `federalTax=0, regionTaxAmount=0, extraTaxesTotal=0, preTaxDeductions=0, postTaxDeductions=0, additionalAnnualIncome=0` (base `calculate()` populates them; existing call sites unaffected).
- `int periodsPerYear(PayFrequency f)` → hourly:52 (40h week cycle), weekly:52, biWeekly:26, monthly:12, annually:1.
- `List<double> payPeriodsByMonth(int year, PayFrequency f)` → 12 monthly period counts; weekly/biWeekly walk pay **dates** from Jan 1 of `year` (7/14-day steps); monthly = 1 each; annually = 1/12 each; sums must equal the year's total period count (biWeekly year-start dependent 26).

- [ ] Write engine tests using US config via `TaxDataLoader.load(Country.us)` (rootBundle works under `flutter test`): baseline `calculate(income:75000, frequency: annually, filingStatus: single)` recorded; with `CalculationExtras(additionalAnnualGross: 10000, preTaxDeductionsAnnual: 5000, postTaxDeductionsAnnual: 1000)`: gross is baseline+10000; totalTax does not increase by full 10000×marginal (brackets apply); net = gross − tax − 1000; **extraTaxesTotal identical to baseline** (FICA unchanged); `extras: null` byte-for-byte identical totals to baseline (regression).
- [ ] Pay-period test: `payPeriodsByMonth(2026, PayFrequency.biWeekly)` == `[2,2,2,2,2,2,3,2,2,2,2,2]`, sum 26; monthly == 12×1; weekly sums 52; everyPaycheck biWeekly 2026 has Jul = 3.
- [ ] Run → fail → implement → pass.

### Task 3: Calculator input extensions + profile→inputs mapper

**Files:**
- Modify: `lib/features/calculator/provider/calculator_provider.dart`
- Create: `lib/domain/usecases/profile_inputs.dart`
- Test: `test/domain/profile_inputs_test.dart`

**Interfaces (produces):**
- `CalculatorProvider` adds: `double overtimeHoursPerPeriod = 0; double? overtimeRate; double? overtimeMultiplier; List<ExtraIncomeItem> incomeItems = <ExtraIncomeItem>[]; List<UserDeduction> userDeductions = <UserDeduction>[];` with setters that call the existing `calculate()` path (`setOvertime({double hoursPerPeriod, double? rate, double? multiplier})`, `clearOvertime()`, `addIncomeItem/EditIncomeItem/removeIncomeItem`, `addDeduction/EditDeduction/removeDeduction` keyed by item id; setters notify).
- `profile_inputs.dart`:
  - `double resolvedOvertimeRate(CalculationProfile p)` → `p.overtime.explicitRate ?? hourlyRate × multiplier`; for salaried profiles (hourlyRate==0) without explicit rate → returns 0 (unsupported; UI requires explicit rate — documented).
  - `double overtimeAnnual(CalculationProfile p)` → rate × hoursPerPeriod × periodsPerYear.
  - `double extraIncomeAnnual(CalculationProfile p)` → Σ recurring items × periodsPerYear + oncePerYear items once.
  - `CalculationExtras extrasFor(CalculationProfile p)` → additionalAnnualGross = overtimeAnnual + extraIncomeAnnual; preTax = Σ preTax items × annual gross (incl. extras); postTax = Σ post-tax items.
- Provider `calculate()` builds the same extras from its inline fields (shared mapper: provider exposes these as a transient `CalculationProfile`-shaped input set; to stay DRY provider-level `buildExtras()` mirrors `extrasFor` math — single source: mapper functions take plain values). Exact: `CalculationExtras extrasFromInputs({required double hourlyRate, required double overtimeHoursPerPeriod, double? overtimeRate, double? multiplier, required double annualOrdinaryGross, required List<ExtraIncomeItem> incomeItems, required List<UserDeduction> userDeductions, required PayFrequency frequency})`; profile version delegates to it.

- [ ] Tests: rate override precedence (explicit beats multiplier); multiplier uses hourlyRate; salaried+multiplier-only → 0; percentage deduction = pct × annual gross (pct base includes other extras); fixed + percent mix sums; oncePerYear counted once vs everyPaycheck × periods.
- [ ] Run → implement providers/mapper → pass.

### Task 4: Hive persistence + ProfileProvider

**Files:**
- Modify: `lib/core/services/local_storage_service.dart` (currently empty → becomes the Hive bootstrap), `lib/main.dart` (init + provide ProfileProvider + ComparisonProvider + FeatureAccess wiring)
- Create: `lib/features/calculator/provider/profile_provider.dart`, `lib/features/calculator/provider/comparison_provider.dart` (type only here; behavior in Task 5)
- Test: `test/providers/profile_provider_test.dart`

**Interfaces:**
- `LocalStorageService`: `static const String profilesBoxName = 'calculation_profiles'; static const String stateBoxName = 'app_state'; static const String activeProfileKey = 'active_profile_id'; static Future<Box<Map>> openProfilesBox(); static Future<Box> openStateBox();`
- `ProfileProvider extends ChangeNotifier`: constructor `ProfileProvider(CalculatorProvider calculator)`; `Future<void> load({Box<Map>? profilesBox, Box? stateBox})` (injectable for tests; default = LocalStorageService boxes opened if not already); `bool isLoading`; `List<CalculationProfile> profiles`; `String? activeProfileId`; `CalculationProfile? get activeProfile`;
  - `Future<String> saveCurrentAs(String name)` — snapshot calculator inputs → new profile (generateProfileId, now timestamps), persist (await put), becomes active.
  - `Future<void> updateActiveSnapshot()` — persists current calculator inputs into activeProfile by id (autosave; called from calculator listener; skipped while `applyProfile` in flight via `_restoring` guard).
  - `Future<void> activate(String id)` — sets calculator inputs via `applyProfile`, awaits its settle, sets + persists activeProfileId.
  - `Future<void> rename(String id, String name)` / `Future<CalculationProfile> duplicate(String id)` (new id, new name `<name> (copy)`, deep lists, persisted) / `Future<void> delete(String id)` (await delete; if active deleted → activate first remaining, else clear active id and leave calculator state as-is).
  - Constructor registers `calculator.addListener(_autosave)`; `dispose()` removes. `_autosave`: if activeId != null && !_restoring && calculator inputs differ from active snapshot → `updateActiveSnapshot()` (write-through, no notify loop).
- `main.dart`: after Firebase/RC init → `await Hive.initFlutter()`; open boxes; `ProfileProvider(calc)` created, `load()` awaited before runApp? No — runApp proceeds, `load()` awaited inside (isLoading covers UI). Provide ComparisonProvider after.

- [ ] Tests with `Hive.init(t.join(tmp,'profile_test'))` fresh per test: create/saveCurrentAs → new instance loading same boxes sees profile (restart survival); rename persists; duplicate → 2 profiles, deep-copied lists (mutating copy doesn't affect original); activate switch persists accessToken; delete active → next remaining becomes active; delete last → activeId null, calculator inputs unchanged; malformed entry in box (e.g. `{'id': 'bad'}` non-map garbage `{}`) is skipped, others load; save/put awaited before state list mutation (checked by observing returned future completes before `profiles.length` changes — assert order with a box spy via injected mock).
- [ ] Run → implement → pass.

### Task 5: Comparison orchestration

**Files:**
- Modify: `lib/features/calculator/provider/comparison_provider.dart` (created in Task 4)
- Test: `test/providers/comparison_provider_test.dart`

**Interfaces:**
- `class ComparisonRow { final CalculationProfile profile; final RegionTax? region; final PaycheckResult result; }`
- `ComparisonProvider extends ChangeNotifier`: `final List<String> selectedIds = [];` `int get selectionCount`; `void toggle(String id)` (max 4, documented cap); `void remove(String id)`; `void clear()`; `Future<List<ComparisonRow>> computeRows(List<CalculationProfile> allProfiles)` — engine per profile: `TaxCalculatorFactory.get(p.country)`, region resolved from `TaxDataLoader.load(p.country).regions` by `regionCode`, `calculate(income: p.income, frequency: p.payFrequency, filingStatus: p.filingStatus, region: resolved, extras: extrasFor(p))`; **does not touch CalculatorProvider/ProfileProvider state**.

- [ ] Tests: two real profiles (same country, different income/OT) → rows' results differ in net as engine dictates; toggle cap enforced at 4; compute again after removing selection returns fewer rows; profile objects' `updatedAt`/lists unchanged after compute (no mutation); zero selections → empty rows.
- [ ] Run → implement → pass.

### Task 6: Annual projection

**Files:**
- Create: `lib/domain/usecases/annual_projection.dart`
- Test: `test/domain/annual_projection_test.dart`

**Interfaces:**
- `class MonthlyProjectionPoint { final int month; final double gross; final double net; }`
- `List<MonthlyProjectionPoint> projectYear(CalculationProfile p, PaycheckResult annualResult, {int? year})` → 12 points; per-month nets distributed by `payPeriodsByMonth` (period net = `annualResult.netIncome / periodsInYear`); monthly frequency → 1 paycheck per month; annually → 1/12 each month (salary accrues evenly); **documented**: one-time income items and overtime are embedded in the engine's annual result and therefore spread across their containing paydays (assumption note shipped in the screen footer).

- [ ] Tests: biWeekly 2026 uses `[2,2,...,3,...]` counts; `sum(monthly.net) == annualResult.netIncome` (±1e-6); monthly frequency → each month `= net/12`… (equal); annual frequency → equal accrual; year param changes distribution for a year where Jan-1 anchoring shifts (2027 biWeekly sums 26).
- [ ] Run → implement → pass.

### Task 7: Feature gating + Expense Tracker config + settings entry

**Files:**
- Create: `lib/features/subscription/domain/feature_access.dart`, `lib/core/config/expense_tracker_config.dart`
- Modify: `lib/features/settings/settings_screen.dart` (add "Manage Your Budget" tile in SUPPORT section)
- Test: `test/screens/settings_budget_tile_test.dart`

**Interfaces:**
- `class FeatureAccess { static const int freeProfileLimit = 1; static const int freeIncomeItems = 2; static const int freeDeductionItems = 2; static bool canAddProfile(int existing, bool hasAccess) => hasAccess || existing < freeProfileLimit; static bool canAddItem(int existing, bool hasAccess) => hasAccess || existing < 2; static bool canCompare(bool hasAccess) => hasAccess; static bool canProject(bool hasAccess) => hasAccess; }`
- `class ExpenseTrackerConfig { static const String? androidPackageId = null; /* TODO(dev): supply before shipping (spec §12) */ static const String? storeUrl = null; static bool get isConfigured => storeUrl != null; }`
- Settings tile: icon `account_balance_wallet_outlined` teal, title **"Manage Your Budget"**, subtitle **"Track your expenses and manage your budget with our Expense Tracker app."** — onTap: `ExpenseTrackerConfig.isConfigured ? openUrl(storeUrl) : dialog('Budgeting lives in our Expense Tracker app. Its store destination is not configured in this build yet.')` (clear fallback; app keeps working; no data ever sent).

- [ ] Widget test: pump SettingsScreen with providers → tap tile → dialog text visible; with config stubbed non-null (via `ExpenseTrackerConfig.storeUrl` runtime override hook `static String? Function()` `storeUrlOverride` for tests) → no dialog (would call openUrl; assert dialog absent only — launcher not invoked in test env).
- [ ] Run → implement → pass.

### Task 8: Home screen sections (overtime, additional income, deductions) + header entries

**Files:**
- Create: `lib/features/calculator/presentation/widgets/overtime_section.dart`, `extra_income_section.dart`, `user_deductions_section.dart`
- Modify: `lib/features/calculator/presentation/screens/home_screen.dart` (mount three sections between FilingStatusSelector and TakeHomeCard; header gains icon buttons: bookmark_add (Save current as profile → dialog), list_alt (→ SavedCalculationsScreen), insert_chart_outlined (→ projection, gated))
- Test: `test/screens/home_sections_test.dart`

**Interfaces (UI):**
- Sections styled like existing `Container(…BorderRadius.circular(16)…Theme.cardColor)` cards with `SectionLabel`-style headers; edit via bottom-sheet dialogs with `TextFormField` + validation (reject negatives, empty names, OT multiplier-without-rate when hourlyRate == 0 → error text; percentage > 100 allowed with note).
- Overtime section: shows hours/period, resolved rate rule (`explicit` vs `× multiplier` chips), clear button; income section: item rows (name, amount, occurrence icon) add/edit/remove; deductions grouped **Pre-tax** / **Post-tax** with % / fixed badge.
- Save-current dialog: name field (default "My Calculation <n>"), created via ProfileProvider.saveCurrentAs; denied (non-premium over limit) → `SubscriptionPlansScreen`.

- [ ] Widget tests: add income item via dialog → item row appears and take-home value changes; remove → disappears; add pre- vs post-tax deduction → grouped under right header; overtime multiplier without rate shows validation error; save dialog creates profile (ProfileProvider state count +1).
- [ ] Run → implement → pass.

### Task 9: SavedCalculationsScreen

**Files:**
- Create: `lib/features/calculator/presentation/screens/saved_calculations_screen.dart`, `lib/features/calculator/presentation/widgets/profile_card.dart`
- Test: `test/screens/saved_calculations_screen_test.dart`

**Interfaces (UI):**
- CustomScrollView list of `ProfileCard`(s): name, `payFrequencyLabel(freq)`, gross summary (`CurrencyFormatter` of annual gross), per-period take-home (annual net / periodsPerYear), green "Active" chip when `id == activeProfileId`, trailing `IconButton(Icons.more_vert)` → bottom-sheet menu: **Open / Activate / Duplicate / Rename / Delete**.
- Open → activate + pop back (Calculator input state now shows profile). Activate → same without hiding list (chip moves). Duplicate → list refreshes. Rename → dialog. Delete → confirm dialog "Delete '<name>'? This cannot be undone." → delete.
- Empty state: illustration-less centered column "No saved calculations yet" + "Save your current calculation" button (runs save dialog). Top bar: back arrow + "Saved Calculations" + `IconButton(Icons.add)` → save dialog (gated). Bottom bar for selection flow lives in Compare screen instead (no checkboxes here).
- Loading state: `isLoading` → `CircularProgressIndicator`.

- [ ] Widget tests: empty state text; seeded Hive → 2 cards with names and "Active" chip; open/activate switches hex activeId; rename updates card; delete with confirm removes card; duplicate adds "(copy)" card; overflow menu lists 5 actions.
- [ ] Run → implement → pass. Wire Home header buttons in this task.

### Task 10: CompareCalculationsScreen

**Files:**
- Create: `lib/features/calculator/presentation/screens/compare_calculations_screen.dart`, `lib/features/calculator/presentation/widgets/comparison_table.dart`
- Test: `test/screens/compare_calculations_screen_test.dart`

**Interfaces (UI):**
- Entry: from Home header (compare icon, gated by `FeatureAccess.canCompare` → plans screen for non-premium) and from Saved screen "Compare" overflow option.
- Screen: horizontal `Wrap` of profile chips (toggle select, max 4, deleted-profile safety via id filter); when ≥2 selected → `ComparisonTable`. Below-table: "Higher net pay: <name>" banner + note "Withholding estimates only — annual liability depends on totals and credits."
- Table: vertical metric rows — per profile a column; columns in horizontal `SingleChildScrollView` (narrow-screen safe). Rows: Gross per pay period (annualGross/periods), Additional income (per period), Federal income tax (annual→per-period? show **per pay period** beside annual in subtitle), Region/state tax (label = actual region name; hidden row entirely when none of the profiles has region tax), Social Security/Medicare/extra (sum of `extraTaxesTotal`, hidden when zero everywhere), Pre-tax deductions, Post-tax deductions, Estimated net pay, Effective withholding rate (`result.effectiveTaxRate`, labeled), Annual gross, Annual net. Each numeric cell shows delta chip vs best column for income rows (▲ higher) and neutral ± for tax rows (no "better" claim).
- Remove profile via chip's ✕.

- [ ] Widget tests: 3 seeded profiles → select 2 → table renders with names, net values from engine (assert engine-consistent, not magic numbers), "Higher net pay" names the engine-max profile; clear selection → hint state; deleting selected profile mid-session doesn't crash (chip filter).
- [ ] Run → implement → pass.

### Task 11: Annual Projectionscreen + chart

**Files:**
- Create: `lib/features/calculator/presentation/screens/annual_projection_screen.dart`, `lib/features/calculator/presentation/widgets/monthly_bars_chart.dart`
- Test: `test/screens/annual_projection_screen_test.dart`

**Interfaces (UI):**
- Entry: Home header chart icon (gated premium; non-premium → plans screen).
- Screen: `MonthlyBarsChart` (CustomPaint, 12 month bars, value-scaled, month letters J–D beneath, legend chips for selectable series: **Net**, **Gross**), annual totals row (gross/net), assumptions footer ("Projection distributes {frequency} paydays by calendar pay dates; withholding is the engine's annualized estimate; taxes/credits not modeled."). Profile source = active profile (doc note if none) — simplest that stays honest.
- Responsive: chart in `AspectRatio` ≥ 16:9, bars recompute on layout width; `LayoutBuilder` used.

- [ ] Widget test: pump with seeded active profile → 12 bars painted (find.byType(CustomPaint) with painter `MonthlyBarsChartPainter`), toggle Gross chip → second series legend state changes; totals text uses `CurrencyFormatter`.
- [ ] Run → implement → pass.

### Task 12: main.dart wiring, smoke test fix, full validation

**Files:**
- Modify: `lib/main.dart` (Hive initflutter + boxes + ProfileProvider/ComparisonProvider into MultiProvider), `test/widget_test.dart` (replace broken `MyApp` smoke with `PaycheckApp` onboarding smoke), `lib/core/config/expense_tracker_config.dart` finalized comments
- Test: full suite

- [ ] `dart format lib test` (or `flutter format`), `flutter analyze` → 3 baseline issues or better, no new.
- [ ] `flutter test` all → all pass.
- [ ] `flutter build apk --debug` (or report environment limitation honestly).
- [ ] Commit.

## Deferred (documented, honest)

- Supplemental flat-rate bonus withholding (engine computes annualized ordinary-rate withholding; UI copy states estimates are annualized, no per-line flat-rate modeling).
- Salary-overtime auto-derivation (FLSA rate allocation): requires explicit OT rate input — enforced by validation, not invented.
- User-chosen projection anchor payday (Jan 1 documented anchor).
- Expense Tracker app-to-app deep link: undefined in codebase → config constants ship `null` with TODO; store-listing fallback completes when supplied.
