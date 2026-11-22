param roundNo: integer, onA: integer, onB: integer, plannedDep: real
-- PickList (Scenarios B, C, D): makes the order-up-to pick list for one round (A3).
-- Each line is filled up to its maximum (A 12, B 9) minus its stock minus the kits already
-- on the way (onA, onB). Line A is served first if the vehicle capacity is short.
-- The kits are created in Warehouse and picked one by one in Kitting (1 min/kit).
-- Due time of each delivery = planned departure of the round (plannedDep, seconds) + load 3 min
-- + driving to the stop + unloading 2 min (+ the A stop before B).
var cap: integer := Vehicle.Capacity
var qA: integer := 12 - SupermarketA.NumMU - onA
var qB: integer := 9 - SupermarketB.NumMU - onB
if qA < 0
	qA := 0
end
if qB < 0
	qB := 0
end
if qA > cap
	qA := cap
end
if qB > cap - qA
	qB := cap - qA
end
var row: integer
var mu: object
var vMin: real := Vehicle.Speed * 60                 -- m/min
var dueA: real := plannedDep / 60 + 3 + 250 / vMin + 2
var dueB: real := dueA + 120 / vMin + 2
if qA > 0
	row := OrderLog.YDim + 1
	OrderLog[1, row] := "A"
	OrderLog[2, row] := qA
	OrderLog[3, row] := EventController.SimTime / 60
	OrderLog[4, row] := -1
	OrderLog[5, row] := -1
	OrderLog[8, row] := roundNo
	OrderLog[9, row] := dueA
	for var i := 1 to qA
		mu := .MUs.Part.create(Warehouse)
		mu.Name := "KitA"
	next
end
if qB > 0
	row := OrderLog.YDim + 1
	OrderLog[1, row] := "B"
	OrderLog[2, row] := qB
	OrderLog[3, row] := EventController.SimTime / 60
	OrderLog[4, row] := -1
	OrderLog[5, row] := -1
	OrderLog[8, row] := roundNo
	OrderLog[9, row] := dueB
	for var i2 := 1 to qB
		mu := .MUs.Part.create(Warehouse)
		mu.Name := "KitB"
	next
end
