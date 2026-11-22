-- BuildModel: record of how the transport, KPI and experiment objects were added to the base model by script.
-- It was run once (in steps). It does nothing now, because the objects already exist.
-- Steps: 1) five tracks with real lengths, 2) variables, methods, log tables, track exit controls,
-- 3) vehicle classes Forklift and TuggerTrain. Method code is in model/simtalk/*.st.
-- Note: CurveTmp (helper table) must exist; it is filled by getCurveSegments.
if existsObject(".Models.Model.VehicleProcess")
	print "BuildModel: model already built - nothing to do."
else
	-- The drawn line is only a picture. TransferLengthToObject = false keeps the real length in metres,
	-- so the vehicle needs Length / Speed to drive each track.
	-- CurveTmp is a helper table; getCurveSegments fills it with row 1 = start point and
	-- row 2 = the straight segment (column 1 = direction in degrees, clockwise; column 2 = drawn length).
	var t: object
	var tb: object := CurveTmp
	if existsObject(".Models.Model.T_WA")
		str_to_obj(".Models.Model.T_WA").deleteObject
	end
	if existsObject(".Models.Model.T_AB")
		str_to_obj(".Models.Model.T_AB").deleteObject
	end
	if existsObject(".Models.Model.T_BW")
		str_to_obj(".Models.Model.T_BW").deleteObject
	end
	if existsObject(".Models.Model.T_WB")
		str_to_obj(".Models.Model.T_WB").deleteObject
	end
	if existsObject(".Models.Model.T_AW")
		str_to_obj(".Models.Model.T_AW").deleteObject
	end
	-- T_WA: 250 m
	t := str_to_obj(".MaterialFlow.Track").createObject(current, 350, 250, "T_WA")
	t.TransferLengthToObject := false
	t.getCurveSegments(tb)
	tb[1, 2] := -25.463
	tb[2, 2] := 11.63
	t.setCurveSegments(tb)
	t.Length := 250
	print t.Name + " length " + to_str(t.Length)
	-- T_AB: 120 m
	t := str_to_obj(".MaterialFlow.Track").createObject(current, 565, 155, "T_AB")
	t.TransferLengthToObject := false
	t.getCurveSegments(tb)
	tb[1, 2] := 90.0
	tb[2, 2] := 10.5
	t.setCurveSegments(tb)
	t.Length := 120
	print t.Name + " length " + to_str(t.Length)
	-- T_BW: 350 m
	t := str_to_obj(".MaterialFlow.Track").createObject(current, 560, 370, "T_BW")
	t.TransferLengthToObject := false
	t.getCurveSegments(tb)
	tb[1, 2] := -154.537
	tb[2, 2] := 11.63
	t.setCurveSegments(tb)
	t.Length := 350
	print t.Name + " length " + to_str(t.Length)
	-- T_WB: 350 m
	t := str_to_obj(".MaterialFlow.Track").createObject(current, 340, 265, "T_WB")
	t.TransferLengthToObject := false
	t.getCurveSegments(tb)
	tb[1, 2] := 28.706
	tb[2, 2] := 11.971
	t.setCurveSegments(tb)
	t.Length := 350
	print t.Name + " length " + to_str(t.Length)
	-- T_AW: 250 m
	t := str_to_obj(".MaterialFlow.Track").createObject(current, 550, 140, "T_AW")
	t.TransferLengthToObject := false
	t.getCurveSegments(tb)
	tb[1, 2] := 151.294
	tb[2, 2] := 11.971
	t.setCurveSegments(tb)
	t.Length := 250
	print t.Name + " length " + to_str(t.Length)
	var v: object
	v := str_to_obj(".InformationFlow.Variable").createObject(current, 80, 40, "Scenario")
	v.DataType := "string"
	v.Value := "A"
	v := str_to_obj(".InformationFlow.Variable").createObject(current, 180, 40, "OpenOrders")
	v.DataType := "integer"
	v := str_to_obj(".InformationFlow.Variable").createObject(current, 280, 40, "Arrived")
	v.DataType := "boolean"
	v := str_to_obj(".InformationFlow.Variable").createObject(current, 380, 40, "Vehicle")
	v.DataType := "object"
	var m: object
	m := str_to_obj(".InformationFlow.Method").createObject(current, 480, 40, "VehicleProcess")
	m := str_to_obj(".InformationFlow.Method").createObject(current, 580, 40, "DriveTo")
	m := str_to_obj(".InformationFlow.Method").createObject(current, 680, 40, "TrackEnd")
	m := str_to_obj(".InformationFlow.Method").createObject(current, 780, 40, "LogStock")
	tb := str_to_obj(".InformationFlow.DataTable").createObject(current, 980, 100, "OrderLog")
	tb.setDataType(1, "string")
	tb.setDataType(2, "integer")
	tb.setDataType(3, "real")
	tb.setDataType(4, "real")
	tb.setDataType(5, "real")
	tb.setDataType(6, "real")
	tb.setDataType(7, "boolean")
	tb.setDataType(8, "integer")
	tb.ColumnIndex := true
	tb[1, 0] := "Line"
	tb[2, 0] := "Qty"
	tb[3, 0] := "RequestMin"
	tb[4, 0] := "DepartMin"
	tb[5, 0] := "DeliveredMin"
	tb[6, 0] := "LeadMin"
	tb[7, 0] := "OnTime"
	tb[8, 0] := "Trip"
	tb := str_to_obj(".InformationFlow.DataTable").createObject(current, 1080, 100, "TripLog")
	for var col := 1 to 7
		tb.setDataType(col, "real")
	next
	tb.ColumnIndex := true
	tb[1, 0] := "Trip"
	tb[2, 0] := "StartMin"
	tb[3, 0] := "EndMin"
	tb[4, 0] := "DistanceM"
	tb[5, 0] := "KitsA"
	tb[6, 0] := "KitsB"
	tb[7, 0] := "MoveFails"
	tb := str_to_obj(".InformationFlow.DataTable").createObject(current, 1180, 100, "StockLog")
	for var c2 := 1 to 3
		tb.setDataType(c2, "real")
	next
	tb.ColumnIndex := true
	tb[1, 0] := "TimeMin"
	tb[2, 0] := "StockA"
	tb[3, 0] := "StockB"
	-- tracks call TrackEnd when the vehicle reaches their end
	T_WA.ExitCtrl := str_to_obj(".Models.Model.TrackEnd")
	T_AB.ExitCtrl := str_to_obj(".Models.Model.TrackEnd")
	T_BW.ExitCtrl := str_to_obj(".Models.Model.TrackEnd")
	T_WB.ExitCtrl := str_to_obj(".Models.Model.TrackEnd")
	T_AW.ExitCtrl := str_to_obj(".Models.Model.TrackEnd")
	-- room for queued pick orders and picked kits
	Warehouse.Capacity := -1
	Staging.Capacity := -1
	print "build part 2 done"
	-- Vehicle classes in .MUs: Forklift 8 kits, 1 m/s; TuggerTrain 16 kits, 50 m/min.
	-- Load bay capacity = X x Y x Z places. Start delay 0 so driving time = length / speed exactly.
	var src: object := str_to_obj(".MUs.Transporter")
	var c: object := src.derive(str_to_obj(".MUs"), "Forklift")
	c.XDim := 4
	c.YDim := 2
	c.Speed := 1
	c.StartDelayDuration := 0
	var d: object := src.derive(str_to_obj(".MUs"), "TuggerTrain")
	d.XDim := 8
	d.YDim := 2
	d.Speed := 50 / 60
	d.StartDelayDuration := 0
	d.Length := 6
end
-- Randomness and experiments: switches, RandomTime, RunResults, TripLog column 8.
-- The ExperimentManager could not be created by script ("cannot be adopted"); it was dragged in
-- from the Toolbox (Tools tab). SetupExperiments and ExportRunResults were added the same way as
-- the other methods. Kitting's processing time was set to Formula: RandomTime("pick").
if existsObject(".Models.Model.RandomTime")
	print "BuildModel (experiments part): already built - nothing to do."
else
	var v3: object
	v3 := str_to_obj(".InformationFlow.Variable").createObject(current, 1000, 200, "Randomness")
	v3.DataType := "boolean"
	v3.Value := false
	v3 := str_to_obj(".InformationFlow.Variable").createObject(current, 1000, 230, "DemandFactor")
	v3.DataType := "real"
	v3.Value := 1
	v3 := str_to_obj(".InformationFlow.Variable").createObject(current, 1000, 260, "DisturbProb")
	v3.DataType := "real"
	v3.Value := 0.1
	var m3: object := str_to_obj(".InformationFlow.Method").createObject(current, 1250, 200, "RandomTime")
	var tb3: object := str_to_obj(".InformationFlow.DataTable").createObject(current, 1250, 270, "RunResults")
	tb3.ColumnIndex := true
	tb3.setDataType(1, "string")
	tb3[1, 0] := "Scenario"
	tb3.setDataType(2, "integer")
	tb3[2, 0] := "Variant"
	tb3.setDataType(3, "boolean")
	tb3[3, 0] := "Randomness"
	tb3.setDataType(4, "real")
	tb3[4, 0] := "DemandFactor"
	tb3.setDataType(5, "real")
	tb3[5, 0] := "DisturbProb"
	tb3.setDataType(6, "integer")
	tb3[6, 0] := "UnitsA"
	tb3.setDataType(7, "integer")
	tb3[7, 0] := "UnitsB"
	tb3.setDataType(8, "real")
	tb3[8, 0] := "StarveAMin"
	tb3.setDataType(9, "real")
	tb3[9, 0] := "StarveBMin"
	tb3.setDataType(10, "integer")
	tb3[10, 0] := "Trips"
	tb3.setDataType(11, "real")
	tb3[11, 0] := "DistanceM"
	tb3.setDataType(12, "real")
	tb3[12, 0] := "BusyPct"
	tb3.setDataType(13, "real")
	tb3[13, 0] := "LeadAMean"
	tb3.setDataType(14, "real")
	tb3[14, 0] := "LeadBMean"
	tb3.setDataType(15, "real")
	tb3[15, 0] := "LeadBMax"
	tb3.setDataType(16, "real")
	tb3[16, 0] := "ServiceLevelPct"
	tb3.setDataType(17, "real")
	tb3[17, 0] := "AvgStockA"
	tb3.setDataType(18, "real")
	tb3[18, 0] := "AvgStockB"
	tb3.setDataType(19, "integer")
	tb3[19, 0] := "MinStockA"
	tb3.setDataType(20, "integer")
	tb3[20, 0] := "MinStockB"
	tb3.setDataType(21, "integer")
	tb3[21, 0] := "Disturbances"
	tb3.setDataType(22, "boolean")
	tb3[22, 0] := "ChecksOK"
	TripLog.setDataType(8, "real")
	TripLog[8, 0] := "DisturbMin"
	print "BuildModel (experiments part) done"
end
-- Last step: PrepareStudy (see PrepareStudy.st) added StartMode, OrderLog column 9 (due time)
-- and the 34-column RunResults layout.
