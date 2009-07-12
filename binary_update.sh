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

#############################################################################

. ./settings.config

if [ "$1" = "-h" -o "$1" = "--help" ]; then
  echo "Usage: binary_update.sh"
  echo ""
  echo "  Updates without install kernel; NOT RECOMMENDED"
  echo ""
  
  exit
fi

. ./includes.sh

echo ""
echo "Do you want to install without using the install kernel?"
echo -n "This is not recommended. Are you sure? [yes/NO] "
if [ `yes_no` ]; then
  setup_snapdir $1
else
  echo "You chose wisely."
  exit
fi

if [ -f $SNAP_DIR/xserv$VERSION.tgz -a \
     -f $SNAP_DIR/xfont$VERSION.tgz -a \
     -f $SNAP_DIR/xshare$VERSION.tgz -a \
     -f $SNAP_DIR/xbase$VERSION.tgz ]; then
   echo "X accounted for.."
   UPDATE_X=yes
else
   echo "WARNING: The directory is missing X files: " $SNAP_DIR
   echo "         X will not be installed."
fi

if [ -f $SNAP_DIR/bsd -a \
     -f $SNAP_DIR/game$VERSION.tgz -a \
     -f $SNAP_DIR/misc$VERSION.tgz -a \
     -f $SNAP_DIR/comp$VERSION.tgz -a \
     -f $SNAP_DIR/man$VERSION.tgz -a \
     -f $SNAP_DIR/base$VERSION.tgz ]; then
  echo "All files accounted for.. Hold onto your hats.."
  cd $SNAP_DIR
else 
  echo "ERROR: The directory is missing files: " $SNAP_DIR
  exit 1
fi

echo "Installing new bsd"
sudo rm /obsd 
sudo ln /bsd /obsd && sudo cp bsd /nbsd && sudo mv /nbsd /bsd

echo "Installing new bsd.rd"
sudo cp bsd.rd /

if [ $UPDATE_X ]; then
  echo "Blowing away old X11 modules"
  sudo rm -rf /usr/X11R6/lib/modules/*
fi

echo "Backing up reboot"
sudo cp /sbin/reboot /sbin/oreboot

if [ $UPDATE_X ]; then
  echo "Untarring X packages"
  sudo tar -C / -xzphf xserv$VERSION.tgz
  sudo tar -C / -xzphf xfont$VERSION.tgz
  sudo tar -C / -xzphf xshare$VERSION.tgz
  sudo tar -C / -xzphf xbase$VERSION.tgz
fi
echo "Untarring main packages"
sudo tar -C / -xzphf game$VERSION.tgz
sudo tar -C / -xzphf misc$VERSION.tgz
sudo tar -C / -xzphf comp$VERSION.tgz
sudo tar -C / -xzphf man$VERSION.tgz
sudo tar -C / -xzphf base$VERSION.tgz # Install last!
sudo /sbin/oreboot
