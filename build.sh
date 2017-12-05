#!/bin/sh

crystal build src/hey.cr
crystal build src/hey/reports/people_report.cr
mv people_report ~/.config/hey/reports/
