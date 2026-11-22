# Problem statement

## Company and situation

AX Drives GmbH (fictional) makes industrial electric drive units. Its factory has a central
warehouse on one side of the hall and two assembly lines on the other:

- **Line A** builds one unit every 8 minutes (60 units per 480-minute shift).
- **Line B** builds one unit every 12 minutes (40 units per shift).

Each unit needs one pre-made **kit** (all components for one unit). Kits are picked in the
warehouse, wait in a dispatch area, and a forklift brings them to small line-side stores
(**supermarkets**) when a line asks for them.

## What is going wrong

The factory manager reports:

1. Assembly workers sometimes wait because their kit has not arrived.
2. The forklift makes many trips, some of them only partly loaded.
3. Some supermarkets hold too much stock while others run short.
4. Transport routes are not planned.
5. Nobody knows whether a forklift, a tugger train or AGVs would work better.
6. More vehicles might cut delays but would cost more and add traffic.

## Study question

> How can the factory move kits from the warehouse to the lines with less waiting, less
> travel and fewer bottlenecks, without buying more equipment than it needs?

This is answered with a discrete-event simulation in **Siemens Tecnomatix Plant Simulation**,
so different ways of working can be tested before anything changes on the shop floor.

## Questions the model must answer

| # | Question | How the model answers it |
|---|---|---|
| 1 | Forklift on request, or a scheduled tugger-train milk run? | Scenarios A vs C |
| 2 | Can one vehicle supply both lines? | Vehicle utilisation and starvation in every scenario |
| 3 | Deliver every 20 min, every 30 min, or on request? | Scenarios A vs C vs D |
| 4 | How much stock should sit beside each line? | Reorder-point test for Scenario A |
| 5 | Would a different route or staging position help? | Not studied (listed as a next step) |

## Scenario design

The four scenarios are set up so that each step changes **one** thing:

| Step | From → to | What changes | What stays the same |
|---|---|---|---|
| Dispatch rule | A → B | On request → fixed 30-min round | Vehicle (forklift, 8 kits) |
| Vehicle | B → C | Forklift → tugger train | Fixed 30-min round |
| Frequency | C → D | 30 min → 20 min | Vehicle (tugger, 16 kits) |

## Scope

**In scope:** kit picking, staging, transport, line-side supermarkets, assembly as a single
station per line, finished goods leaving the system.

**Out of scope:** the inside of each assembly line, component-level stock in the warehouse
(the warehouse never runs out), external suppliers, purchase orders, goods receipts, BOM and
MRP, supplier lead times, costs in euros, AGVs (named by management but left for a later
study), people other than one picker and one driver. This is an **intralogistics** study
(factory material flow and line replenishment), not an end-to-end supply-chain model.

## Success criteria (KPIs)

| KPI | Definition |
|---|---|
| Completed output | Units finished per shift; units still in assembly at shift end are reported separately as WIP |
| Line starvation | Minutes a line waits with an empty supermarket |
| Vehicle time | Productive (loading, driving, unloading) and disrupted (disturbance delays), % of the shift |
| Transport distance | Metres driven per shift |
| Replenishment lead time | Minutes from request to kits arriving in the supermarket |
| Average line-side stock | Time-weighted average kits in each supermarket |
| Delivery service level | On-time orders (arrived before the line ran dry) / (on time + late + outstanding overdue); orders still open at shift end are always counted |

All input data are invented demonstration values. The study validates the model's logic and
internal consistency, not a real factory.
