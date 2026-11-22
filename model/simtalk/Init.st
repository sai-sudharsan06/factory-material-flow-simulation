-- Init: called by the EventController at the start of every run.
-- 1) clear the logs, 2) fill the supermarkets to their maximum (A 12, B 9),
-- 3) create the vehicle for the chosen Scenario, 4) start the vehicle logic.
-- Scenario A = forklift on request, B = forklift round every 30 min,
-- C = tugger train every 30 min, D = tugger train every 20 min.
-- Stress test: DemandFactor 1.2 makes both lines 20 % faster (A 6.67, B 10 min per unit).
AssemblyA.ProcTime := 8 * 60 / DemandFactor
AssemblyB.ProcTime := 12 * 60 / DemandFactor
OrderLog.delete
TripLog.delete
StockLog.delete
OpenOrders := 0
Arrived := false
var mu: object
for var i := 1 to 12
	mu := .MUs.Part.create(SupermarketA)
	mu.Name := "KitA"
next
for var i := 1 to 9
	mu := .MUs.Part.create(SupermarketB)
	mu.Name := "KitB"
next
LogStock
if not PerfectSupply
	-- the vehicle waits at the warehouse (end of track T_BW).
	-- Classes in .MUs: Forklift = 8 kits, 1 m/s (60 m/min); TuggerTrain = 16 kits, 50 m/min.
	if Scenario = "A" or Scenario = "B"
		Vehicle := .MUs.Forklift.create(T_BW, T_BW.Length)
	else
		Vehicle := .MUs.TuggerTrain.create(T_BW, T_BW.Length)
	end
	&VehicleProcess.methCall(0)
end
