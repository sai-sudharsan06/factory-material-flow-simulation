-- LogStock: write the current supermarket stock to StockLog.
-- Called after every pick and every delivery. EndSim uses the log for the
-- time-weighted average stock and the capacity check.
var r: integer := StockLog.YDim + 1
StockLog[1, r] := EventController.SimTime / 60
StockLog[2, r] := SupermarketA.NumMU
StockLog[3, r] := SupermarketB.NumMU
