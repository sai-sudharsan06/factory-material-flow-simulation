param kind: string -> time
-- RandomTime: every random time of the model in one place. Returns seconds.
-- Randomness = false gives the fixed values (deterministic baseline).
--   "pick"    picking one kit       triangular(min 0.75, mode 1, max 1.5) min, mean 1.08  (stream 1)
--   "load"    loading per trip      triangular(2, 3, 5) min, mean 3.33                    (stream 2)
--   "unload"  unloading per stop    triangular(1.5, 2, 3) min, mean 2.17                  (stream 3)
--   "disturb" delay before a trip (blocked aisle, battery change, vehicle needed elsewhere):
--             with probability DisturbProb a delay of uniform(5, 15) min, else 0     (streams 4, 5)
-- Kitting uses RandomTime("pick") as its Formula processing time.
if kind = "pick"
	if Randomness
		return z_triangle(1, 1, 0.75, 1.5) * 60
	end
	return 60
elseif kind = "load"
	if Randomness
		return z_triangle(2, 3, 2, 5) * 60
	end
	return 3 * 60
elseif kind = "unload"
	if Randomness
		return z_triangle(3, 2, 1.5, 3) * 60
	end
	return 2 * 60
elseif kind = "disturb"
	if Randomness and z_uniform(4, 0, 1) < DisturbProb
		return z_uniform(5, 5, 15) * 60
	end
	return 0
end
print "RandomTime: unknown kind " + kind
return 0
