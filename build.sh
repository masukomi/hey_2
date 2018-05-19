#!/bin/sh

crystal build src/hey.cr
crystal build src/hey/reports/people_report.cr
crystal build src/hey/reports/interrupts_by_hour.cr
crystal build src/hey/reports/sparkline_24.cr

cp hey starter_files/

# move reports
cp people_report ~/.config/hey/reports/
mv people_report starter_files/reports/

cp interrupts_by_hour ~/.config/hey/reports/
mv interrupts_by_hour starter_files/reports/

cp sparkline_24 ~/.config/hey/reports/
mv sparkline_24 starter_files/reports/
