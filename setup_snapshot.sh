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


if [ "$1" = "-h" -o "$1" = "--help" ]; then
  echo "Usage: setup_snapshot.sh [download_dir]"
  echo ""
  echo "  This will simply move the current /bsd.rd to /obsd.rd and copy the"
  echo "  new bsd.rd to /. This requires you to be root or use sudo"
  echo ""
  echo "download_dir  Directory containing bsd.rd, defaults to current day's"
  echo "              directory made by get_snapshot.sh"
  echo ""
  exit
fi

if [ -n "$1" ]; then
  SNAP_DIR=$1
else
  SNAP_DIR=snapshot_`date "+%m%d%y"`
  echo "No directory specified, using: " $SNAP_DIR
fi 

if [ ! -d $SNAP_DIR ]; then
  echo "ERROR: The directory does not exist:" $SNAP_DIR
  exit 1
fi

if [ -f "$SNAP_DIR/bsd.rd" ]; then
  sudo mv /bsd.rd /obsd.rd
  sudo cp $SNAP_DIR/bsd.rd /
else
  echo "ERROR: $SNAP_DIR did not contain bsd.rd"
  exit 1
fi
