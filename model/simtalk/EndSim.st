-- EndSim: called by the EventController at the end of the run (480 min).
-- Deterministic runs print the logs (TRIP; ORDER; STOCK; lines) first, then the KPIs and the
-- verification checks. Every run (except PerfectSupply) adds one row to RunResults.
-- KPI definitions:
--   Completed output = units that left assembly into FinishedGoods during the shift.
--   WIP = units still inside an assembly station at 480 min (started, not finished).
--   Starvation = 480 min - working time (Plant Simulation's waiting share leaves out the empty state).
--   Orders: on time = the kits arrived while the line was still running (before it ran dry);
--     late = the line had already run dry; outstanding at shift end = not delivered, split into
--     overdue (its line is standing empty at 480 min) and not yet due (the line still has kits,
--     so the order belongs to the next shift). Service level = on time / (on time + late + overdue).
--     Separately: delivered by the planned due time (OrderLog column 9) = punctuality against
--     the timetable; it has no allowance, so it is only meaningful in deterministic runs.
--   Vehicle time per trip (dispatch to return): productive = load + drive + unload;
--     disrupted = disturbance delay; elapsed = both. A trip still running at 480 counts until 480.
--   Distance: each track is added to TripLog only after DriveTo has returned (the end was
--     reached). If the vehicle is still driving at 480, the metres already driven on that track
--     (Vehicle.FrontPos) are added as partial distance; unfinished trips are counted separately.
var tNow: real := EventController.SimTime / 60
if not PerfectSupply and not Randomness
	for var t2 := 1 to TripLog.YDim
		print "TRIP;" + to_str(TripLog[1, t2]) + ";" + to_str(round(TripLog[2, t2], 3)) + ";" + to_str(round(TripLog[3, t2], 3)) + ";" + to_str(TripLog[4, t2]) + ";" + to_str(TripLog[5, t2]) + ";" + to_str(TripLog[6, t2]) + ";" + to_str(TripLog[7, t2]) + ";" + to_str(round(TripLog[8, t2], 3))
	next
	for var r2 := 1 to OrderLog.YDim
		print "ORDER;" + OrderLog[1, r2] + ";" + to_str(OrderLog[2, r2]) + ";" + to_str(round(OrderLog[3, r2], 3)) + ";" + to_str(round(OrderLog[4, r2], 3)) + ";" + to_str(round(OrderLog[5, r2], 3)) + ";" + to_str(round(OrderLog[9, r2], 3)) + ";" + to_str(OrderLog[8, r2])
	next
	for var s2 := 1 to StockLog.YDim
		print "STOCK;" + to_str(round(StockLog[1, s2], 3)) + ";" + to_str(StockLog[2, s2]) + ";" + to_str(StockLog[3, s2])
	next
end
var workA: real := AssemblyA.statWorkingPortion * tNow
var workB: real := AssemblyB.statWorkingPortion * tNow
var compA: integer := AssemblyA.statNumOut
var compB: integer := AssemblyB.statNumOut
var wipA: integer := AssemblyA.NumMU
var wipB: integer := AssemblyB.NumMU
print "=== AX Drives - Scenario " + Scenario + "  StartMode " + to_str(StartMode) + "  Randomness " + to_str(Randomness) + "  DemandFactor " + to_str(DemandFactor) + "  DisturbProb " + to_str(DisturbProb) + "  ExtraReorder " + to_str(ExtraReorder) + "  variant " + to_str(EventController.RandomNumbersVariant) + "  (PerfectSupply " + to_str(PerfectSupply) + ")  run ended at min " + to_str(round(tNow, 2)) + " ==="
print "Completed output A / B: " + to_str(compA) + " / " + to_str(compB) + "   WIP at shift end: " + to_str(wipA) + " / " + to_str(wipB) + "   started: " + to_str(compA + wipA) + " / " + to_str(compB + wipB) + "   (capacity " + to_str(round(60 * DemandFactor, 1)) + " / " + to_str(round(40 * DemandFactor, 1)) + ")"
print "Starvation A: " + to_str(round(480 - workA, 2)) + " min   B: " + to_str(round(480 - workB, 2)) + " min"
if not PerfectSupply
	-- orders
	var nReq: integer := 0
	var nOnTime: integer := 0
	var nLate: integer := 0
	var nOverdue: integer := 0
	var nNotDue: integer := 0
	var nSched: integer := 0
	var kitsOrdered: integer := 0
	var nA: integer := 0
	var nB: integer := 0
	var sumA: real := 0
	var sumB: real := 0
	var maxLB: real := 0
	for var r := 1 to OrderLog.YDim
		nReq := nReq + 1
		kitsOrdered := kitsOrdered + OrderLog[2, r]
		if OrderLog[5, r] >= 0
			if OrderLog[7, r]
				nOnTime := nOnTime + 1
			else
				nLate := nLate + 1
			end
			if OrderLog[5, r] <= OrderLog[9, r] + 0.001
				nSched := nSched + 1
			end
			if OrderLog[1, r] = "A"
				nA := nA + 1
				sumA := sumA + OrderLog[6, r]
			else
				nB := nB + 1
				sumB := sumB + OrderLog[6, r]
				if OrderLog[6, r] > maxLB
					maxLB := OrderLog[6, r]
				end
			end
		elseif (OrderLog[1, r] = "A" and not AssemblyA.Occupied) or (OrderLog[1, r] = "B" and not AssemblyB.Occupied)
			nOverdue := nOverdue + 1
		else
			nNotDue := nNotDue + 1
		end
	next
	var svc: real := 100
	if nOnTime + nLate + nOverdue > 0
		svc := nOnTime / (nOnTime + nLate + nOverdue) * 100
	end
	print "Orders: " + to_str(nReq) + " = on time " + to_str(nOnTime) + " + late " + to_str(nLate) + " + outstanding overdue " + to_str(nOverdue) + " + outstanding not yet due " + to_str(nNotDue) + "   service level " + to_str(round(svc, 1)) + " %   delivered by planned time: " + to_str(nSched)
	if nA > 0
		print "Lead time A mean " + to_str(round(sumA / nA, 2)) + " min"
	end
	if nB > 0
		print "Lead time B mean " + to_str(round(sumB / nB, 2)) + " min, max " + to_str(round(maxLB, 2)) + " min"
	end
	-- trips: distance, productive / disrupted / elapsed time, load, overlap
	var nTrips: integer := 0
	var nEmpty: integer := 0
	var elapsed: real := 0
	var disrupted: real := 0
	var dist: real := 0
	var maxLoad: real := 0
	var fails: real := 0
	var overlaps: integer := 0
	var nDist: integer := 0
	var prevEnd: real := 0
	var tEnd: real
	var dMin: real
	var nUnfinished: integer := 0
	var partial: real := 0
	for var t := 1 to TripLog.YDim
		tEnd := TripLog[3, t]
		if tEnd < 0
			tEnd := tNow
			nUnfinished := nUnfinished + 1
		else
			nTrips := nTrips + 1
		end
		elapsed := elapsed + tEnd - TripLog[2, t]
		dMin := TripLog[8, t]
		if dMin > tEnd - TripLog[2, t]
			dMin := tEnd - TripLog[2, t]
		end
		disrupted := disrupted + dMin
		if TripLog[8, t] > 0
			nDist := nDist + 1
		end
		dist := dist + TripLog[4, t]
		if TripLog[5, t] + TripLog[6, t] > maxLoad
			maxLoad := TripLog[5, t] + TripLog[6, t]
		end
		if TripLog[5, t] + TripLog[6, t] = 0
			nEmpty := nEmpty + 1
		end
		fails := fails + TripLog[7, t]
		if TripLog[2, t] < prevEnd
			overlaps := overlaps + 1
		end
		prevEnd := tEnd
	next
	-- metres already driven on the track the vehicle is on at shift end (not yet in TripLog)
	if nUnfinished > 0 and not Arrived
		partial := Vehicle.FrontPos
		dist := dist + partial
	end
	print "Trips completed " + to_str(nTrips) + " of " + to_str(TripLog.YDim) + " started, empty trips " + to_str(nEmpty) + ", disturbed trips " + to_str(nDist) + ", distance " + to_str(round(dist, 1)) + " m (of which " + to_str(round(partial, 1)) + " m on a track not yet finished at 480; unfinished trips " + to_str(nUnfinished) + ")"
	print "Vehicle time: productive " + to_str(round((elapsed - disrupted) / 480 * 100, 1)) + " %  + disrupted " + to_str(round(disrupted / 480 * 100, 1)) + " %  = elapsed (dispatch to return) " + to_str(round(elapsed / 480 * 100, 1)) + " % of the shift"
	-- stock
	var areaA: real := 0
	var areaB: real := 0
	var maxSA: real := 0
	var maxSB: real := 0
	var minSA: real := 99
	var minSB: real := 99
	var tNext: real
	for var s := 1 to StockLog.YDim
		if s < StockLog.YDim
			tNext := StockLog[1, s + 1]
		else
			tNext := tNow
		end
		areaA := areaA + StockLog[2, s] * (tNext - StockLog[1, s])
		areaB := areaB + StockLog[3, s] * (tNext - StockLog[1, s])
		if StockLog[2, s] > maxSA
			maxSA := StockLog[2, s]
		end
		if StockLog[3, s] > maxSB
			maxSB := StockLog[3, s]
		end
		if StockLog[2, s] < minSA
			minSA := StockLog[2, s]
		end
		if StockLog[3, s] < minSB
			minSB := StockLog[3, s]
		end
	next
	print "Average stock A / B: " + to_str(round(areaA / tNow, 2)) + " / " + to_str(round(areaB / tNow, 2)) + " kits (lowest " + to_str(minSA) + " / " + to_str(minSB) + ")"
	-- checks
	var created: integer := 21 + kitsOrdered
	var counted: integer := FinishedGoods.statNumIn + wipA + wipB + SupermarketA.NumMU + SupermarketB.NumMU + Warehouse.NumMU + Kitting.NumMU + Staging.NumMU + Vehicle.NumMU
	var vehOnTracks: integer := T_WA.NumMU + T_AB.NumMU + T_BW.NumMU + T_WB.NumMU + T_AW.NumMU
	var ok: boolean := created = counted and maxSA <= 12 and maxSB <= 9 and maxLoad <= Vehicle.Capacity and fails = 0 and vehOnTracks = 1 and overlaps = 0
	print "Checks: kits in " + to_str(created) + " = out " + to_str(counted) + ", max stock " + to_str(maxSA) + "/12 " + to_str(maxSB) + "/9, max load " + to_str(maxLoad) + "/" + to_str(Vehicle.Capacity) + ", vehicles " + to_str(vehOnTracks) + ", overlaps " + to_str(overlaps) + "  -> all OK: " + to_str(ok)
	-- one row per run
	var rr: integer := RunResults.YDim + 1
	RunResults[1, rr] := Scenario
	RunResults[2, rr] := EventController.RandomNumbersVariant
	RunResults[3, rr] := Randomness
	RunResults[4, rr] := DemandFactor
	RunResults[5, rr] := DisturbProb
	RunResults[6, rr] := ExtraReorder
	RunResults[7, rr] := StartMode
	RunResults[8, rr] := compA
	RunResults[9, rr] := compB
	RunResults[10, rr] := wipA
	RunResults[11, rr] := wipB
	RunResults[12, rr] := 480 - workA
	RunResults[13, rr] := 480 - workB
	RunResults[14, rr] := nTrips
	RunResults[15, rr] := dist
	RunResults[16, rr] := (elapsed - disrupted) / 480 * 100
	RunResults[17, rr] := disrupted / 480 * 100
	RunResults[18, rr] := elapsed / 480 * 100
	RunResults[19, rr] := nReq
	RunResults[20, rr] := nOnTime
	RunResults[21, rr] := nLate
	RunResults[22, rr] := nOverdue
	RunResults[23, rr] := nNotDue
	RunResults[24, rr] := svc
	if nA > 0
		RunResults[25, rr] := sumA / nA
	end
	if nB > 0
		RunResults[26, rr] := sumB / nB
	end
	RunResults[27, rr] := maxLB
	RunResults[28, rr] := areaA / tNow
	RunResults[29, rr] := areaB / tNow
	RunResults[30, rr] := minSA
	RunResults[31, rr] := minSB
	RunResults[32, rr] := nDist
	RunResults[33, rr] := nEmpty
	RunResults[34, rr] := ok
	RunResults[35, rr] := nSched
	RunResults[36, rr] := nUnfinished
	RunResults[37, rr] := partial
end
