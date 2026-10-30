# Projection rebuild + correctness fixes — Design

Date: 2026-10-29 · Status: **approved** (user: "go with the recommendation")
Branch: `feature/expansion` · Follows the completed 12-task expansion plan.

## A. Projection feature (main work)

**Data source — decision (user-approved):** the projection screen follows the
**live working calculation**, not only the saved active profile.
`CalculatorProvider.result` is already the engine's annual result for the
current working inputs (income, frequency, region, filing status, overtime,
extra income, user deductions). The screen projections from that result via
`projectYear(provider.snapshotToProfile(), provider.result)` — no second
computation, no engine calls added. A "Unsaved changes" chip mirrors the
Home header (`ProfileProvider.hasUnsavedChanges`, after fixing its missing
overtime key). Fallback when the working result is not ready: loader.

**Premium gate:** `FeatureAccess.canProject(hasAccess)` — zero call sites
today. Same pattern as Compare hub: `SubscriptionProvider.hasAccess`; locked
state shows an intro card with an "Explore premium" CTA →
`SubscriptionPlansScreen`. Unlocked shows the projection.

**Chart (`MonthlyBarsChart`) rebuild:**
- One selection path: drag and tap share a single bar hit-test (fixes the
  month-13 off-by-one).
- Selected month shows a formatted value readout (Net/Gross series applied).
- Painter colors from `Theme.of(context).colorScheme` (works in dark mode)
  instead of fixed `AppColors` light values.
- `points` list treated as values; `shouldRepaint` compares values, not list
  identity; painter doesn't rebuild work per frame.
- Semantics labels on the chart.

**Screen shell:** keep the current shell (annual-net card, header tiles,
note), add an intro sentence, error state with Retry, and the correct
"26/27 pay days" wording. Out of scope (documented, not silent): year
picker (`year` param stays unused), per-month tax accrual (projection keeps
using the engine's annualized ratios — documented in
`annual_projection.dart`).

## B. Definite wrong-logic fixes (each test-covered)

1. **Germany config never loads deductions** — `tax_config.dart` guards on
   `json['deduction']` but parses `json['deductions']`. Fix the guard.
2. **US Social Security has no wage-base cap** — engine already supports
   `type: "capped"`. Supply the 2026 wage base in config:
   `"type": "capped", "cap": 184500` in `assets/taxes/us.json`. The value
   lives in JSON, never hard-coded in Dart.
3. **Per-paycheck user deductions treated as annual** — the UI hint says
   "Amount per period" but `extrasFromInputs` adds the raw value to the
   annual totals. Fix: non-percentage amounts × `periodsPerYear(frequency)`.
   *Behavior change:* previously saved per-period amounts now annualize as
   the UI always promised.
4. **Region tax base is wrong for flat regions** — states like AZ/CO/UT tax
   gross income and ignore their own standard deduction, while the
   subtraction wrongly trims *federal* taxable income instead. Fix: region
   standard deduction/exemption applies to the **region** base only
   (flat: `(income − regionDeductions)·rate`, clamped at 0; progressive:
   `brackets(taxableIncome − regionDeductions)`), and the federal/main
   taxable income never sees region deductions.
5. **Effective tax rate is NaN at zero income** — guard `totalTax / annualIncome`
   with `annualIncome > 0 ? … : 0`.
6. **Overtime ×hourly derives from a hard-coded default 25/h** — `hourlyRate`
   defaults to 25 with no UI setter; salaried ×hourly overtime silently uses
   $25. Fix: default 0, and when `frequency == hourly` the ordinary hourly
   rate *is* the income, so `buildExtras` passes `income` as the hourly rate.
7. **`applyProfile`/`setCountry` leave stale compare state** — `regionA/B`
   use `??=` so old-country regions survive a profile switch; a non-regions
   country never clears them; `setCountry` leaves stale `resultA/B`. Fix:
   reset A/B to the new config's first/last (or null), clear A/B results.
8. **Saved-cards currency + stale result** — card formats with the *current
   working* country; use `profile.country`. `_resultFuture` never refreshes
   when the profile changes (rename/save) — recompute on `didUpdateWidget`.
9. **`hasUnsavedChanges` ignores overtime edits** — add the `overtime` key.
10. **Breakdown omits user deductions** — bar + list add pre/post-tax user
    deduction rows from `result.preTaxDeductions`/`postTaxDeductions`.
11. **Empty-compare hint counts wrong** — it decrements on `resultB` instead
    of `regionB`. Count selected regions directly.
12. **Home header dead wiring** — `onCompare`/`onAnnualProjection` are
    required no-ops; both features are bottom-nav tabs. Remove the dead
    params (menu items are already commented out).

## Tests

Engine: config key, SS cap, region base, per-period annualization, OT rate,
effective-rate guard, provider staleness. Widget: projection (live source,
chip, gate, readout selection), saved card currency, breakdown rows, hint
counts. Replace the 3 near-tautological projection tests with real asserts.

## Explicit non-goals

Year picker, per-month tax accrual, delete-last-profile working-state
behavior (explicit-save model keeps the working state), Gold/Silver blue
theme changes, backend/storage changes, new dependencies.
