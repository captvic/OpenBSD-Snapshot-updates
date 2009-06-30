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
  echo "Usage: includes.sh"
  echo ""
  echo "  Don't run this; it is meant to be included by other scripts."
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

echo "Includes loaded.."
