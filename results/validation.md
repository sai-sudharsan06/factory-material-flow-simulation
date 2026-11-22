# Validation of the base model: production lines without transport

Model: `model/ax-drives-material-flow.spp` (Plant Simulation 2404, Student licence).
Run length: 480 min (EventController end 8:00:00). Output printed by the `EndSim` method.

## Test 1: perfect supply (`PerfectSupply = true`)

A new kit is put back into the supermarket the moment a kit enters assembly, so the lines
can never run short. This checks the assembly capacity against the hand calculation.

| KPI | Expected (hand calc) | Model |
|---|---|---|
| Units Line A | 60 started | completed 59 + 1 in progress (WIP) at 480:00 |
| Units Line B | 40 started | completed 39 + 1 in progress (WIP) at 480:00 |
| Line A working time | 480 min | 480 min |
| Line B working time | 480 min | 480 min |
| Starvation A / B | 0 % / 0 % | 0 % / 0 % |
| Supermarket stock at end | 12 / 9 | 12 / 9 |

**Why 59 and not 60:** the first kit starts at minute 0, so unit *n* of Line A finishes at
8 x *n* minutes. Unit 60 finishes at exactly 480:00, the same instant the run stops, so
Plant Simulation still shows it inside the station. Both lines were busy for the full 480
minutes, which is the capacity check. All results therefore report **completed output**
(59 + 39 = 98) and **WIP at shift end** (1 + 1) separately, never added together as throughput.

## Test 2: no resupply (`PerfectSupply = false`)

Only the starting stock is available. This checks that a line stops when its supermarket is
empty, which the starvation KPI depends on.

| KPI | Expected | Model |
|---|---|---|
| Units Line A | 12 (starting stock) | 12 |
| Units Line B | 9 (starting stock) | 9 |
| Line A working time | 12 x 8 = 96 min | 96 min |
| Line B working time | 9 x 12 = 108 min | 108 min |
| Starvation A | 384 / 480 = 80 % | 80 % |
| Starvation B | 372 / 480 = 77.5 % | 77.5 % |
| Kits in = kits out | 21 = 21 | 21 in finished goods, 0 left |

## Findings for the model

- **No kits are lost or duplicated:** 21 kits in, 21 units out in Test 2.
- **A line cannot assemble without a kit:** starvation appears exactly when stock runs out.
- **Plant Simulation's built-in "waiting" share is not starvation.** It leaves out the time a
  station stands empty, so it showed 11 % instead of 80 %. Starvation is therefore
  calculated as *480 min minus working time*. This is valid because the finished-goods drain
  never blocks a line.
- **A run can end early** when no events are left (Test 2 stopped at 108 min). KPIs are
  therefore always converted to the full 480-minute shift.
