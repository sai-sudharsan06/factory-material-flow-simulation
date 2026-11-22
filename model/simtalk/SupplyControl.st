-- SupplyControl: entrance control of AssemblyA / AssemblyB.
-- A kit entering assembly has just left the supermarket (assumption A2), so:
-- 1) log the new stock, 2) validation mode: put a kit back at once,
-- 3) Scenario A: reorder check (A <= 4 -> 8 kits, B <= 3 -> 6 kits), one open order per line.
--    Reorder-point test: ExtraReorder = 1 raises Line B's reorder point to 4,
--    ExtraReorder = 2 raises both (A 5, B 4). Order quantities stay 8 and 6.
--    Each order gets a due time = request + planned lead time with a free forklift
--    (picking 1 min/kit + load 3 + drive + unload 2): A 17.17 min, B 16.83 min.
var line: string
var sm: object
var minStock: integer
var qty: integer
var plannedLead: real
if ? = AssemblyA
	line := "A"
	sm := SupermarketA
	minStock := 4
	if ExtraReorder = 2
		minStock := 5
	end
	qty := 8
	plannedLead := 8 + 3 + 250 / 60 + 2
else
	line := "B"
	sm := SupermarketB
	minStock := 3
	if ExtraReorder >= 1
		minStock := 4
	end
	qty := 6
	plannedLead := 6 + 3 + 350 / 60 + 2
end
if PerfectSupply
	var k: object := .MUs.Part.create(sm)
	k.Name := "Kit" + line
elseif Scenario = "A" and sm.NumMU <= minStock
	-- is an order for this line still open (not yet delivered)?
	var isOpen: boolean := false
	for var r := 1 to OrderLog.YDim
		if OrderLog[1, r] = line and OrderLog[5, r] < 0
			isOpen := true
		end
	next
	if not isOpen
		var row: integer := OrderLog.YDim + 1
		OrderLog[1, row] := line
		OrderLog[2, row] := qty
		OrderLog[3, row] := EventController.SimTime / 60
		OrderLog[4, row] := -1
		OrderLog[5, row] := -1
		OrderLog[9, row] := OrderLog[3, row] + plannedLead
		-- pick order: the kits are picked one by one in Kitting (1 min/kit) into Staging
		for var i := 1 to qty
			var mu: object := .MUs.Part.create(Warehouse)
			mu.Name := "Kit" + line
		next
		OpenOrders := OpenOrders + 1
	end
end
LogStock
