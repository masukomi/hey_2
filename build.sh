#!/bin/sh
VERSION="dev_version"
if [ "$1" != "" ]; then
  VERSION=$1
  perl -pi -e "s/VERSION_NUMBER_HERE/$1/" src/hey/version.cr
fi
echo "building hey..."
if [ "$1" != "" ]; then
  crystal build --release src/hey.cr
else
  crystal build src/hey.cr
fi
if [ "$1" != "" ]; then
  perl -pi -e "s/$1/VERSION_NUMBER_HERE/" src/hey/version.cr
fi

echo "copying files around for distribution..."
version_dir="hey_v$VERSION"
rm -rf $version_dir

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

db_sha=$(shasum -a 256 starter_files/hey.db | sed -e "s/ .*//")
if [ "$db_sha" != "88fe5ed82c33da62bbd9790722e0ff025da96a906aa20b761b94d307d1966264" ]; then
  echo "WARNING: starter db has been updated." 
  echo "You must:"
  echo " * upload the updated hey.db to the starer_files dir"
  echo " * update the sha in db_setup.sh to $sha"
  echo " * upload the updated db_setup.sh"
  echo " * create/update and upload the db upgrade script"
  echo " * update the sha in build.sh once all of that has been done"
else
  echo "starter db is unchanged."
fi

sha=$(shasum -a 256 $version_dir.tgz)
echo "homebrew release sha is $sha"
echo "DONE"

