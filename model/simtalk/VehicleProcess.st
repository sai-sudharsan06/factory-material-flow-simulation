-- VehicleProcess: the whole vehicle logic. Started once by Init and runs until the shift ends.
-- Times are in seconds inside Plant Simulation; the logs are written in minutes.
--   Load 3 min per trip at the warehouse, unload 2 min per stop (Inputs sheet).
--   These times come from RandomTime (random if Randomness = true), and a trip can be
--   delayed by a disturbance before loading (logged in TripLog column 8).
--   Scenario A: forklift on request, first come first served (A7). One trip per order.
--   Scenario B/C/D: fixed round W -> A -> B -> W every 30 / 30 / 20 min (A4).
--     Order-up-to: each line is filled up to its maximum (A 12, B 9), counting kits
--     already on the vehicle; Line A is loaded first if capacity is short (A3).
--     The pick list for the next round is made when a round leaves, so picking runs
--     while the vehicle drives. If a round comes back late, the next one leaves at once (A5).
--     StartMode 0: first round leaves at minute 0 (supermarkets are still full, so the second
--     round carries nothing - a start-up effect). StartMode 1 (aligned start): the first pick
--     list is made 10 min before the first departure at minute 30 (D: 20).
var delay: real
var trip: integer := 0
var tr: integer
var t0: real
var mu: object
var fails: integer
var dist: real

if Scenario = "A"
	var row: integer := 0
	while true
		waituntil OpenOrders > 0
		OpenOrders := OpenOrders - 1
		row := row + 1                     -- next order in arrival order (FCFS)
		var line: string := OrderLog[1, row]
		var qty: integer := OrderLog[2, row]
		-- picking is first come first served, so the oldest order's kits are first in Staging
		waituntil Staging.NumMU >= qty
		trip := trip + 1
		tr := TripLog.YDim + 1
		t0 := EventController.SimTime
		TripLog[1, tr] := trip
		TripLog[2, tr] := t0 / 60
		TripLog[3, tr] := -1
		delay := RandomTime("disturb")
		TripLog[8, tr] := delay / 60
		if delay > 0
			wait delay
		end
		wait RandomTime("load")
		fails := 0
		for var i := 1 to qty
			if not Staging.cont.move(Vehicle)
				fails := fails + 1
			end
		next
		if line = "A"
			TripLog[5, tr] := Vehicle.NumMU
			TripLog[6, tr] := 0
		else
			TripLog[5, tr] := 0
			TripLog[6, tr] := Vehicle.NumMU
		end
		OrderLog[4, row] := EventController.SimTime / 60
		OrderLog[8, row] := trip
		-- drive to the line, unload, drive back
		var sm: object
		var asm: object
		var tOut: object
		var tBack: object
		if line = "A"
			sm := SupermarketA
			asm := AssemblyA
			tOut := T_WA
			tBack := T_AW
		else
			sm := SupermarketB
			asm := AssemblyB
			tOut := T_WB
			tBack := T_BW
		end
		DriveTo(tOut)
		dist := tOut.Length
		TripLog[4, tr] := dist
		wait RandomTime("unload")
		for var j := Vehicle.NumMU downto 1
			if not Vehicle.MU(j).move(sm)
				fails := fails + 1
			end
		next
		LogStock
		OrderLog[5, row] := EventController.SimTime / 60
		OrderLog[6, row] := OrderLog[5, row] - OrderLog[3, row]
		OrderLog[7, row] := asm.Occupied      -- false = the line had already run dry
		DriveTo(tBack)
		dist := dist + tBack.Length
		TripLog[4, tr] := dist
		TripLog[3, tr] := EventController.SimTime / 60
		TripLog[7, tr] := fails
	end
else
	var interval: real := 30 * 60
	if Scenario = "D"
		interval := 20 * 60
	end
	var nextDep: real := 0
	var qA: integer
	var qB: integer
	if StartMode = 1
		nextDep := interval
		wait interval - 10 * 60
	end
	PickList(1, 0, 0, nextDep)             -- first pick list
	while true
		trip := trip + 1
		-- kits on this round's pick list
		qA := 0
		qB := 0
		for var r := 1 to OrderLog.YDim
			if OrderLog[8, r] = trip
				if OrderLog[1, r] = "A"
					qA := OrderLog[2, r]
				else
					qB := OrderLog[2, r]
				end
			end
		next
		-- leave at the planned time (at once if the last round came back late, A5),
		-- as soon as the kits are picked
		if EventController.SimTime < nextDep
			wait nextDep - EventController.SimTime
		end
		waituntil Staging.NumMU >= qA + qB
		tr := TripLog.YDim + 1
		t0 := EventController.SimTime
		TripLog[1, tr] := trip
		TripLog[2, tr] := t0 / 60
		TripLog[3, tr] := -1
		delay := RandomTime("disturb")
		TripLog[8, tr] := delay / 60
		if delay > 0
			wait delay
		end
		wait RandomTime("load")
		fails := 0
		for var k := 1 to qA + qB
			if not Staging.cont.move(Vehicle)
				fails := fails + 1
			end
		next
		TripLog[5, tr] := qA
		TripLog[6, tr] := qB
		for var r2 := 1 to OrderLog.YDim
			if OrderLog[8, r2] = trip
				OrderLog[4, r2] := EventController.SimTime / 60
			end
		next
		nextDep := nextDep + interval
		-- pick list for the next round now; the kits on the vehicle count as on the way
		PickList(trip + 1, qA, qB, nextDep)
		-- stop at Line A
		DriveTo(T_WA)
		dist := T_WA.Length
		TripLog[4, tr] := dist
		wait RandomTime("unload")
		for var j := Vehicle.NumMU downto 1
			mu := Vehicle.MU(j)
			if mu.Name = "KitA"
				if not mu.move(SupermarketA)
					fails := fails + 1
				end
			end
		next
		LogStock
		for var r3 := 1 to OrderLog.YDim
			if OrderLog[8, r3] = trip and OrderLog[1, r3] = "A"
				OrderLog[5, r3] := EventController.SimTime / 60
				OrderLog[6, r3] := OrderLog[5, r3] - OrderLog[3, r3]
				OrderLog[7, r3] := AssemblyA.Occupied
			end
		next
		-- stop at Line B
		DriveTo(T_AB)
		dist := dist + T_AB.Length
		TripLog[4, tr] := dist
		wait RandomTime("unload")
		for var j2 := Vehicle.NumMU downto 1
			mu := Vehicle.MU(j2)
			if mu.Name = "KitB"
				if not mu.move(SupermarketB)
					fails := fails + 1
				end
			end
		next
		LogStock
		for var r4 := 1 to OrderLog.YDim
			if OrderLog[8, r4] = trip and OrderLog[1, r4] = "B"
				OrderLog[5, r4] := EventController.SimTime / 60
				OrderLog[6, r4] := OrderLog[5, r4] - OrderLog[3, r4]
				OrderLog[7, r4] := AssemblyB.Occupied
			end
		next
		-- back to the warehouse
		DriveTo(T_BW)
		dist := dist + T_BW.Length
		TripLog[4, tr] := dist
		TripLog[3, tr] := EventController.SimTime / 60
		TripLog[7, tr] := fails
	end
end
