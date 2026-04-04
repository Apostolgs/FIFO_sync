#Riviera Pro
vsim +access+r +sv_seed={random} -random_seed=random -srandomforrandom +UVM_TESTNAME=fifo_test +UVM_NO_RELNOTES
run -all
acdb save;
acdb report -verbose
exec cat acdb_report.txt
