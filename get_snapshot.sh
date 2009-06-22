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

# Settings
VERSION=46
ARCH=i386
# make sure OPENBSD_MIRROR is set and exported

#############################################################################
# Shouldn't have to play beyond here
#############################################################################

SNAP_DIR=snapshot_`date "+%m%d%y"`

function mirror_message {
  echo "  $ export OPENBSD_MIRROR=\"ftp://mirror.openbsd.org/pub/OpenBSD\""
  echo ""
  echo "A list of mirrors can be found here:"
  echo ""
  echo "  http://www.openbsd.org/ftp.html"
  echo ""
}

if [ "$1" = "-h" -o "$1" = "--help" ]; then
  echo "Usage: get_snapshot.sh"
  echo ""
  echo "  This script downloads the necessary files to update your system to"
  echo "  the latest OpenBSD snapshot. Files are downloaded from the mirror"
  echo "  set in OPENBSD_MIRROR, and their checksums are verified."
  echo ""
  echo "  You may have to edit the settings at the top of the script to"
  echo "  set your ARCH, and when the version changes the VERSION"
  echo ""
  echo "  You may also want to change the files that are downloaded, by"
  echo "  default bsd.mp is skipped."
  echo ""
  
  echo "  Make sure you have the OPENBSD_MIRROR environment variable set."
  echo ""
  mirror_message
  exit
fi


if [ -d $SNAP_DIR ]; then
  echo "WARNING: Download directory exists:" $SNAP_DIR
else 
  mkdir "$SNAP_DIR"
fi

if [ ! -n $OPENBSD_MIRROR ]; then
  echo "ERROR: Make sure you have \$OPENBSD_MIRROR set by doing something like:"
  echo ""
  mirror_message
 
  exit 1
fi

cd $SNAP_DIR

function download_file {
  ftp -C $OPENBSD_MIRROR/snapshots/$ARCH/$1 || exit 1
  echo -n "Checking SHA256 for $1: "
  grep `cksum -a sha256 $1 | awk '{print $4}'` SHA256 > /dev/null || \
      { echo "CKSUM ERROR" ; exit 1; }
  echo "GOOD"
}

# Always fetch the new checksums from the main site
rm SHA256
ftp ftp://ftp.openbsd.org/pub/OpenBSD/snapshots/$ARCH/SHA256 || exit 1

download_file base$VERSION.tgz
download_file bsd
#download_file bsd.mp
download_file bsd.rd
download_file comp$VERSION.tgz
download_file etc$VERSION.tgz
download_file game$VERSION.tgz
download_file man$VERSION.tgz
download_file misc$VERSION.tgz
download_file xbase$VERSION.tgz
download_file xetc$VERSION.tgz
download_file xfont$VERSION.tgz
download_file xserv$VERSION.tgz
download_file xshare$VERSION.tgz
