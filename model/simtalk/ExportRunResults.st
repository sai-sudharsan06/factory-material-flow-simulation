-- ExportRunResults: how to get RunResults into Excel.
-- Writing files from SimTalk is blocked in this model (File > Model Settings > General >
-- "Prohibit access to the computer" is on, and it is left on). So:
--   1. Reset, double-click RunResults, click a cell, Ctrl+A, Ctrl+C.
--   2. In Excel, paste into the Runs sheet of results/results.xlsx below the header row.
print "RunResults has " + to_str(RunResults.YDim) + " rows. Open RunResults, Ctrl+A, Ctrl+C, paste into Excel."
