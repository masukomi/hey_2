#!/bin/sh
VERSION="dev_version"
if [ "$1" != "" ]; then 
  VERSION=$1
  perl -pi -e "s/VERSION_NUMBER_HERE/$1/" src/hey.cr
fi
crystal build --release src/hey.cr
if [ "$1" != "" ]; then 
  perl -pi -e "s/$1/VERSION_NUMBER_HERE/" src/hey.cr
fi



crystal build --release src/hey/reports/people_report.cr
crystal build --release src/hey/reports/interrupts_by_hour.cr
crystal build --release src/hey/reports/sparkline_24.cr

version_dir="hey_$VERSION"
rm -rf $version_dir
mkdir -p $version_dir/reports
mkdir -p $version_dir/upgrade_scripts
cp upgrade_scripts/* $version_dir/upgrade_scripts/
cp hey $version_dir/


# make sure the required directories exist
mkdir -p ~/.config/hey/reports


cp starter_files/hey.db $version_dir/hey.db
mkdir -p $version_dir/reports
cp people_report $version_dir/reports/
cp interrupts_by_hour $version_dir/reports/
cp sparkline_24 $version_dir/reports/

# compress version dir
tar -czf $version_dir.tgz $version_dir
rm -rf $version_dir


