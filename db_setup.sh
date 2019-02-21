#!/bin/bash

LATEST_VERSION="2.0.0-a2"
which hey > /dev/null
if [ $? -ne 0 ]; then
	echo "Hey! doesn't appear to be installed."
	echo "Which is kinda weird, since this script should only be loaded"
	echo "when hey told you to."
	echo "Most likely it's installed but just not in your PATH."
	echo "Run this to see all the directories in your PATH:"
	echo "  echo \$PATH"
	echo "If that doesn't help, talk to me at @masukomi on Twitter"
	echo "or email via masukomi@masukomi.org and I'll try and help you out."
	exit 2
fi

HEY_VERSION=$(hey --version | sed -e "s/.*Version //")
if [ "$HEY_VERSION" != "$LATEST_VERSION" ]; then
  echo "Your version of hey is at $HEY_VERSION but this script is at $LATEST_VERSION"
  echo "Please upgrade hey before continuing."
  exit 3
fi

function test_if_version_needs_upgrade() {
  version=$1
  if [ "$version" == "1.0.0" ] || [ "$version" == "" ]; then
    echo "yes"
  else
    echo "no"
  fi
}


# setup the directories we'll need
mkdir -p $HOME/.config/hey/reports

# test if you need a db
if [ ! -f $HOME/.config/hey/hey.db ]; then
  # download a starter db
  curl \
    https://interrupttracker.com/starter_files/hey.db \
    --output $HOME/.config/hey/hey.db
  sha=$(shasum -a 256 $HOME/.config/hey/hey.db | sed -e "s/ .*//")
  if [ "$sha" != "88fe5ed82c33da62bbd9790722e0ff025da96a906aa20b761b94d307d1966264" ]; then
    echo "WARNING! Downloaded DB does not match expectations."
    echo "THIS FILE MAY HAVE BEEN TAMPERED WITH"
    echo "PLEASE CONTANCT @masukomi on twitter or masukomi@masukomi.org"
    echo ""
    echo "There is no known security risk resulting from this file being "
    echo "tampered with, but there's no point in taking any chances."
    echo "Please wait for me to get back to you with an updated database file"
    echo "before proceeding. - masukomi"
  fi
fi

if [ ! -f $HOME/.config/hey/hey.db ]; then
  echo ""
  echo "Unable to download starter db to $HOME/.config/hey/hey.db"
  echo "See errors above."
  echo "Exiting because there's no point in proceeding without a database."
  exit 4
fi

# is it a current version?
# extract the version from the db
db_version=$(sqlite3 $HOME/.config/hey/hey.db "select major || '.' ||  minor || '.' ||  patch from versions order by id desc limit 1" 2>/dev/null)
if [ "$db_version" == "" ]; then
  db_version="1.0.0"
fi
if [ "$db_version" != "$LATEST_VERSION" ]; then
  needs_upgrade=$(test_if_version_needs_upgrade $db_version)
  if [ "$needs_upgrade" == "yes" ]; then
    # request your approval for upgrading
    upgrade_file=$(echo $db_version | tr "." "_")".sql"

    echo "Your DB is at v$db_version but the latest version is $LATEST_VERSION"
    echo "Unfortunately there's no automated upgrade _currently_ available."
    echo "If you'd like to maintain your current data you can manually"
    echo "run the upgrade SQL found here:"
    echo "https://interrupttracker.com/upgrade_scripts/$upgrade_file"
    echo ""
    echo "Alternately just replace your old db with a fresh starter db"
    echo "for $LATEST_VERSION Run the following command to do that:"
    echo "  curl https://interrupttracker.com/starter_files/hey.db \\"
    echo "     --output $HOME/.config/hey/hey.db"
    # echo "Is it ok if I upgrade it?"
    # read approval
    # approval=$(echo $approval | tr '[:upper:]' '[:lower:]')
    #
    # if [ "$approval" == "y" ] || [ "$approval" == "yes" ]; then
    #   # make a backup
    #   echo "Backing up your old db at $HOME/.config/hey/hey.db.$db_version"
    #   cp $HOME/.config/hey/hey.db $HOME/.config/hey/hey.db.$db_version
    #   #download the upgrade script for your version
    #   url="https://interrupttracker.com/upgrade_scripts/$upgrade_file"
    #   curl $url -o $upgrade_file
    #   sqlite3 < "$HOME/.config/hey/hey.db" < $upgrade_file
    #   if [ $? -eq 0 ]; then
    #     echo "DB Has been upgraded"
    #     rm $upgrade_file
    #   else
    #     echo "Eeep. There was a problem upgrading your db."
    #     echo "I'm going to stop here."
    #     echo "Please send the error to masukomi@masukomi.org along with the"
    #     echo "\"Your DB is at ...\" line, and ping me at @masukomi on twitter."
    #     rm $upgrade_file
    #     exit 4
    #   fi
    # else
    #   echo "Ok. I'll stop here"
    #   exit 1
    # fi
  fi
else
  echo "Your DB is up to date!"
fi


