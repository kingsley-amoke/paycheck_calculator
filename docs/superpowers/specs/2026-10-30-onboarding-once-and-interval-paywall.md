# Onboarding once + interval paywall — Design

Date: 2026-10-30 · Status: awaiting approval
Branch: `feature/expansion` · Appends to plan `2026-10-29-projection-and-fixes.md` as Tasks 13–18.

## Intent

- Onboarding shows **only on the first app opening**.
- Free users see a skippable paywall **after every 4 successful calculations** —
  user's refinement: navigation-count triggers were dropped; income *typing*
  alone must not rack up counts.
- The paywall is the onboarding paywall's design (`PurchaseView`) and a **real**
  RevenueCat purchase surface (it already is one: real offerings, real
  `Purchases.purchase`, real restore, 5s close cooldown — kept as-is).

## What counts as one "successful calculation"

A coalesced recalculation burst in `CalculatorProvider`: after any
user-driven input change (income, frequency, filing status, region, country,
overtime save/clear, extra-income / deduction add-edit-remove, profile
activation), the engine recalculates; if the previous user-driven recalc was
less than ~3 s ago, it counts as the **same** calculation (that's the "not
just typing" rule — typing one salary ≈ one calculation; separate edits count
separately). The count increments only after `calculate()` completes
successfully. Activating a saved profile counts as one calculation.

## Approaches (picked)

- **Reuse `PurchaseView` as-is** with one new optional `onPurchaseSuccess`
  callback: interval context pops back instead of `pushAndRemoveUntil(MainShell)`.
  (Alternative "build a separate SubscriptionPlansScreen-based popup" rejected —
  duplicate design work for no benefit.)
- **`PaywallScheduler`** (ChangeNotifier, `lib/features/paywall/`): holds the
  count, persisted in the existing Hive stateBox (`paywall_calc_count`).
  `onCalculationCompleted()` → count++, when ≥ 4 and the user is free
  (`!subscription.hasAccess`) it becomes "pending". Display resets the count.
- **`PaywallHost`** wraps `MainShell` (not the onboarding route — first-run
  users already get the onboarding paywall): on pending, pushes
  `PurchaseView(onPurchaseSuccess/onDismiss → pop)`; on dismiss calls
  `scheduler.onPaywallShown()` → count = 0, persisted.
- **Onboarding flag:** `LocalStorageService.onboardingCompleteKey`; read in
  `main.dart` from the stateBox that's already opened; `PaycheckApp.home`
  chooses `OnboardingScreen` vs `MainShell`. The two onboarding exits set the
  flag: skip (`_reviewBypass`) and purchase success.
- **Mock removal:** `purchase_model.dart` + `paywall_screen_2.dart` are dead
  code and get deleted.

## Constraints honored

- Premium state only via `SubscriptionProvider.hasAccess` (includes
  RemoteConfig review-access override — those users are treated as premium
  and never see the paywall).
- No new dependencies; Hive stateBox already opened in `main.dart`.
- Paywall never appears while already visible; queued-hold code is not needed
  (pending shows at next app frame, single push guarded by a local flag).

## Tests

- Scheduler unit: count → threshold → pending; reset on shown; persisted in
  a FakeBox; free-user check suppression when `hasAccess`.
- Provider unit: two recalc calls within the same burst count once; distinct
  edits count separately.
- Widget: `PaywallHost` pushes the paywall for a free user at threshold and
  pops+resets on dismiss; subscriber (`hasAccess`) sees nothing.

## Out of scope

Time-based triggers (dropped by user decision), navigation-count triggers
(dropped), deep-link paywall location tuning, iOS review-note surfaces.
