#!/bin/sh

# Copyright (c) 2009, Jeremy Chase
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

#    * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.

#    * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.

#    * Neither the name Jeremy Chase nor the names of any contributors may be
#    used to endorse or promote products derived from this software without
#    specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

VERSION=46

############################################################################

if [ "$1" = "-h" -o "$1" = "--help" ]; then
  echo "Usage: post_upgrade.sh [download_dir]"
  echo ""
  echo "  This script asks to do several things you probably don't want"
  echo "  to do, but might. In order:"
  echo "    1) Perform a sysmerge using etcXX.tgz and xetcXX.tgz from in"
  echo "       download_dir, but defaults to today's snapshot directory" 
  echo "    2) Use pkg_add to update all packages"
  echo "    3) Use lynx to view http://www.openbsd.org/faq/current.html"
  echo "    4) Backup ports/distfiles into the backup directory"
  echo "    5) Fetch latest ports.tar.gz"
  echo "    6) rm /usr/ports/*"
  echo "    7) Untar new ports.tar.gz in place"
  echo "    8) Restore the ports distfiles"

  echo ""
  echo "download_dir  Directory containing etc.tgz, defaults to current day's"
  echo "              directory made by get_snapshot.sh"
  echo ""
  exit
fi

function yes_no {
  read
  echo -n $REPLY | grep -i yes

  # This works because if [ ]  will not execute but if [ STRING ] will.
  # see man TEST(1)
}

function setup_snapdir {
  if [ -n "$1" ]; then
    SNAP_DIR=$1
  else
    SNAP_DIR=snapshot_`date "+%m%d%y"`
    echo "No directory specified, using: " $SNAP_DIR
  fi

  if [ ! -d $SNAP_DIR ]; then
    echo "WARNING: The directory does not exist:" $SNAP_DIR
    mkdir $SNAP_DIR
  fi
}

echo -n "Perform sysmerge? [yes/NO]"
if [ `yes_no` ]; then
  setup_snapdir $1

  if [ -f "$SNAP_DIR/etc$VERSION.tgz" ]; then
    echo ""
    echo "Updating etc$VERSION.tgz"
    sudo sysmerge -as $SNAP_DIR/etc$VERSION.tgz
  else
    echo "ERROR: $SNAP_DIR did not contain etc$VERSION.tgz"
    exit 1
  fi

  if [ -f "$SNAP_DIR/xetc$VERSION.tgz" ]; then
    echo ""
    echo "Updating xetc$VERSION.tgz"
    sudo sysmerge -ax $SNAP_DIR/xetc$VERSION.tgz
  else
    echo "WARNING: $SNAP_DIR did not contain xetc$VERSION.tgz, skipping"
  fi
else
  echo "Skipping sysmerge"
fi

echo ""
echo -n "Update packages? [yes/NO]"
if [ `yes_no` ]; then
  sudo pkg_add -ui -F update -F updatedepends
else
  echo "Skipping package update"
fi

echo ""
echo -n "Take a look at faq/current.html? [yes/NO]"
if [ `yes_no` ]; then
  lynx http://www.openbsd.org/faq/current.html
else
  echo "Skipping faq/current.html"
fi

function backup_ports_distfiles {
  BK_DIR=backup_`date "+%m%d%y"`

  if [ -d $BK_DIR ]; then
    echo "WARNING: The directory exists:" $BK_DIR
  else
    mkdir $BK_DIR
  fi

  cd $BK_DIR
  echo -n "Making backup of /usr/ports/distfiles "
  sudo tar cf distfiles.tar -C /usr/ports distfiles && echo "Backup successful."
  cd - > /dev/null
}

function restore_ports_distfiles {
  BK_DIR=backup_`date "+%m%d%y"`

  if [ -f $BK_DIR/distfiles.tar ]; then
    echo "Untarring distfiles."
    sudo tar xf $BK_DIR/distfiles.tar -C /usr/ports
  else
    echo "ERROR: The distfiles do not exist."
  fi
}

echo ""
echo -n "Backup /usr/ports/distfiles? [yes/NO]"
if [ `yes_no` ]; then
  backup_ports_distfiles
else
  echo "Skipping distfiles backup"
fi

echo ""
echo -n "Fetch the latest ports.tar.gz? [yes/NO]"
if [ `yes_no` ]; then
  setup_snapdir $1

  cd $SNAP_DIR
  ftp -C ftp://ftp.openbsd.org/pub/OpenBSD/snapshots/ports.tar.gz
else
  echo "Skiping ports.tar.gz download"
fi

echo ""
echo -n "Remove old ports? [yes/NO]"
if [ `yes_no` ]; then
  sudo rm -rf /usr/ports/*
else
  echo "Not deleting /usr/ports/"
fi

echo ""
echo -n "Untar new ports? [yes/NO]"
if [ `yes_no` ]; then
  setup_snapdir
  if [ -f $SNAP_DIR/ports.tar.gz ]; then
    echo "Untarring ports.tar.gz"
    sudo tar xzf $SNAP_DIR/ports.tar.gz -C /usr
  else
    echo "ERROR: The ports files does not exist."
  fi
else
  echo "Not unpacking ports.tar.gz"
fi

echo ""
echo -n "Restore /usr/ports/distfiles? [yes/NO]"
if [ `yes_no` ]; then
  restore_ports_distfiles
else
  echo "Skipping distfiles restore"
fi

