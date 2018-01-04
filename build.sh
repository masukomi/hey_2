#!/bin/sh

crystal build src/hey.cr
crystal build src/hey/reports/people_report.cr
crystal build src/hey/reports/interrupts_by_hour.cr
mv people_report ~/.config/hey/reports/
mv interrupts_by_hour ~/.config/hey/reports/
