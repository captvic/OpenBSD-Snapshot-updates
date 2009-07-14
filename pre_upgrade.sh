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

##########################################################################

. ./settings.config

if [ "$1" = "-h" -o "$1" = "--help" ]; then
  echo "Usage: prepare_for_upgrade.sh [download_dir]"
  echo ""
  echo "  This script asks to do several things you probably don't want"
  echo "  to do, but might. In order:"
  echo "    1) Move the bsd.rd in the appropriate snapshot dir to /."
  echo "       A backup is made of bsd.rd"
  echo "    2) Make a backup of /etc in a dated directory."
  echo "    3) Delete X11 Modules."
  echo ""
  echo "download_dir  Directory containing bsd.rd, defaults to current day's"
  echo "              directory made by get_snapshot.sh"
  echo ""
  exit
fi

. ./includes.sh

function backup_etc {
  BK_DIR=backup_`date "+%m%d%y"`

  if [ -d $BK_DIR ]; then
    echo "WARNING: The directory exists:" $BK_DIR
  else
    mkdir $BK_DIR
  fi

  cd $BK_DIR
  echo -n "Making backup of /etc "
  sudo tar czf etc.tgz -C / etc && echo "Backup successful.."
  cd - > /dev/null
}

echo ""
echo -n "Move bsd.rd to /? [yes/NO] "
if [ `yes_no` ]; then
  setup_snapdir $1

  if [ -f "$SNAP_DIR/bsd.rd" ]; then
    sudo mv /bsd.rd /obsd.rd
    sudo cp $SNAP_DIR/bsd.rd /
  else
    echo "ERROR: $SNAP_DIR did not contain bsd.rd"
    exit 1
  fi
else
  echo "skipping bsd.rd"
fi

echo ""
echo -n "Backup /etc? [yes/NO] "
if [ `yes_no` ]; then
  backup_etc  
else
  echo "Skipping /etc backup"
fi

echo ""
echo -n "Remove X11R6 modules? [yes/NO] "
if [ `yes_no` ]; then
  echo "Deleting them..."
  sudo rm -rf /usr/X11R6/lib/modules/*
else
  echo "Leaving lib modules in place"
fi
