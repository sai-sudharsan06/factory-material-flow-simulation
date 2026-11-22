param trk: object
-- DriveTo: put the vehicle at the start of track trk and wait until it reaches the end.
-- Driving time is not typed in anywhere: it follows from track length / vehicle speed.
Arrived := false
if not Vehicle.move(trk)
	print "ERROR: vehicle could not enter " + trk.Name
end
waituntil Arrived
