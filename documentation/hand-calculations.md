# Hand calculations

These numbers are worked out before building the model, so the simulation can be checked
against them. Every value also sits as a live Excel formula in
`assumptions-and-input-data.xlsx` (sheet *Hand calculations*). Inputs are in the sheet
*Inputs*; assumptions added by this study (A1-A8) are in *Added assumptions*.

## 1. Capacity with perfect supply

| Line | Calculation | Units per shift |
|---|---|---|
| A | 480 / 8 | **60** |
| B | 480 / 12 | **40** |

The model must reach exactly 60 + 40 = 100 when the supermarkets never run empty. This is
the first validation test.

## 2. Forklift, request-based (Scenario A)

| Item | Calculation | Minutes |
|---|---|---|
| Round trip to Line A | 3 load + 2 x 250/60 + 2 unload | 13.33 |
| Round trip to Line B | 3 load + 2 x 350/60 + 2 unload | 16.67 |
| Lead time A, forklift free | 8 picks x 1 + 3 + 4.17 + 2 | 17.17 |
| Lead time B, forklift free | 6 picks x 1 + 3 + 5.83 + 2 | 16.83 |
| Stock cover at reorder, A | 4 kits x 8 | 32.00 |
| Stock cover at reorder, B | 3 kits x 12 | 36.00 |

**Worst case:** both lines ask at the same moment and A is served first. B's kits arrive
after 8 (A picking) + 13.33 (A trip) + 3 + 5.83 + 2 = **32.17 min**, still inside B's 36-min
cover. The margin is only 3.8 min, so any random delay can make Line B starve.

**Per shift:** 7 requests from A and 6 from B, so the forklift is busy
7 x 13.33 + 6 x 16.67 = **193 min (40 %)** and drives 7 x 500 + 6 x 700 = **7,700 m**.

## 3. Scheduled rounds (Scenarios B, C, D)

Loop W -> A -> B -> W = 250 + 120 + 350 = **720 m**.

| Item | Forklift (B) | Tugger (C, D) |
|---|---|---|
| Driving | 720 / 60 = 12.0 min | 720 / 50 = 14.4 min |
| + load 3 + two stops x 2 | 19.0 min | 21.4 min |
| Kits needed per 30 min | 3.75 + 2.5 = 6.25 (fits 8) | 6.25 (fits 16) |
| Rounds per shift at 30 min | 16 | 16 |
| Distance per shift | 11,520 m | 11,520 m |
| Utilisation (driving + handling) | 63 % | 71 % |

**Findings before any simulation:**

1. **No starvation is expected in the deterministic baseline.** Every scenario should make
   100 units (98 completed + 2 still in assembly at 480:00). Differences will show in distance,
   utilisation and stock, and only the random runs and stress tests separate the scenarios on
   reliability.
2. **A fixed round drives more than the request-based forklift** (11.5 km vs 7.7 km), because
   it goes round every 30 min whether or not much is needed. Its advantage is
   predictability and smaller, more frequent deliveries (lower line-side stock).
3. **One tugger cannot run a 20-min cycle.** The loop takes 21.4 min before any picking, so
   Scenario D will slip to about one round every 21-22 min (assumption A5). Holding 20 min
   would need faster loading, a shorter route or a second train.
4. **Scenario B needs a fixed round.** With an 8-kit forklift and an 8-kit Line A order,
   request-based trips can never be combined (assumption A4).
