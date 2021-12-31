export STATATMP="/media/steven/525 GB Hard Disk/statatmp"
stata-mp -e intro.do
stata-mp -e shares.do
stata-mp -e pairs.do
stata-mp -e bartik.do
stata-mp -e imm_shift.do
stata-mp -e percentiles.do
stata-mp -e correction.do
stata-mp -e figures.do
stata-mp -e regressions.do
stata-mp -e regressions_time.do
stata-mp -e regressions_timealt.do
systemctl suspend
