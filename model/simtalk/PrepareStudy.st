-- PrepareStudy (run once): StartMode switch, due-time column in OrderLog, new RunResults layout.
if not existsObject(".Models.Model.StartMode")
	var v: object := str_to_obj(".InformationFlow.Variable").createObject(current, 1000, 320, "StartMode")
	v.DataType := "integer"
	v.Value := 1
end
OrderLog.setDataType(9, "real")
OrderLog[9, 0] := "DueMin"
RunResults.delete
RunResults.setDataType(1, "string")
RunResults[1, 0] := "Scenario"
RunResults.setDataType(2, "integer")
RunResults[2, 0] := "Variant"
RunResults.setDataType(3, "boolean")
RunResults[3, 0] := "Randomness"
RunResults.setDataType(4, "real")
RunResults[4, 0] := "DemandFactor"
RunResults.setDataType(5, "real")
RunResults[5, 0] := "DisturbProb"
RunResults.setDataType(6, "integer")
RunResults[6, 0] := "ExtraReorder"
RunResults.setDataType(7, "integer")
RunResults[7, 0] := "StartMode"
RunResults.setDataType(8, "integer")
RunResults[8, 0] := "CompletedA"
RunResults.setDataType(9, "integer")
RunResults[9, 0] := "CompletedB"
RunResults.setDataType(10, "integer")
RunResults[10, 0] := "WipA"
RunResults.setDataType(11, "integer")
RunResults[11, 0] := "WipB"
RunResults.setDataType(12, "real")
RunResults[12, 0] := "StarveAMin"
RunResults.setDataType(13, "real")
RunResults[13, 0] := "StarveBMin"
RunResults.setDataType(14, "integer")
RunResults[14, 0] := "Trips"
RunResults.setDataType(15, "real")
RunResults[15, 0] := "DistanceM"
RunResults.setDataType(16, "real")
RunResults[16, 0] := "ProductivePct"
RunResults.setDataType(17, "real")
RunResults[17, 0] := "DisruptedPct"
RunResults.setDataType(18, "real")
RunResults[18, 0] := "ElapsedPct"
RunResults.setDataType(19, "integer")
RunResults[19, 0] := "Orders"
RunResults.setDataType(20, "integer")
RunResults[20, 0] := "OnTime"
RunResults.setDataType(21, "integer")
RunResults[21, 0] := "Late"
RunResults.setDataType(22, "integer")
RunResults[22, 0] := "OutstandingOverdue"
RunResults.setDataType(23, "integer")
RunResults[23, 0] := "OutstandingNotDue"
RunResults.setDataType(24, "real")
RunResults[24, 0] := "ServiceLevelPct"
RunResults.setDataType(25, "real")
RunResults[25, 0] := "LeadAMean"
RunResults.setDataType(26, "real")
RunResults[26, 0] := "LeadBMean"
RunResults.setDataType(27, "real")
RunResults[27, 0] := "LeadBMax"
RunResults.setDataType(28, "real")
RunResults[28, 0] := "AvgStockA"
RunResults.setDataType(29, "real")
RunResults[29, 0] := "AvgStockB"
RunResults.setDataType(30, "integer")
RunResults[30, 0] := "MinStockA"
RunResults.setDataType(31, "integer")
RunResults[31, 0] := "MinStockB"
RunResults.setDataType(32, "integer")
RunResults[32, 0] := "Disturbances"
RunResults.setDataType(33, "integer")
RunResults[33, 0] := "EmptyTrips"
RunResults.setDataType(34, "boolean")
RunResults[34, 0] := "ChecksOK"
RunResults.setDataType(35, "integer")
RunResults[35, 0] := "DeliveredByPlannedTime"
RunResults.setDataType(36, "integer")
RunResults[36, 0] := "UnfinishedTrips"
RunResults.setDataType(37, "real")
RunResults[37, 0] := "PartialDistanceM"
print "PrepareStudy done, RunResults columns: " + to_str(RunResults.XDim)
