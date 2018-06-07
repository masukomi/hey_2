#!/bin/sh
VERSION="dev_version"
if [ "$1" != "" ]; then
  VERSION=$1
  perl -pi -e "s/VERSION_NUMBER_HERE/$1/" src/hey.cr
fi
echo "building hey..."
crystal build --release src/hey.cr
if [ "$1" != "" ]; then
  perl -pi -e "s/$1/VERSION_NUMBER_HERE/" src/hey.cr
fi



echo "building people_report..."
crystal build --release src/hey/reports/people_report.cr
echo "building interrupts_by_hour..."
crystal build --release src/hey/reports/interrupts_by_hour.cr
echo "building sparkline_24..."
crystal build --release src/hey/reports/sparkline_24.cr

echo "copying files around for distribution..."
version_dir="hey_$VERSION"
rm -rf $version_dir

mkdir -p $version_dir/reports
cp people_report $version_dir/reports/
cp interrupts_by_hour $version_dir/reports/
cp sparkline_24 $version_dir/reports/

mkdir -p $version_dir/upgrade_scripts
cp upgrade_scripts/* $version_dir/upgrade_scripts/

cp hey $version_dir/


# make sure the required directories exist
mkdir -p ~/.config/hey/reports


cp starter_files/hey.db $version_dir/hey.db

# compress version dir
echo "tarring it up as $version_dir.tgz"
tar -czf $version_dir.tgz $version_dir
rm -rf $version_dir
echo "DONE"


