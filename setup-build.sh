#!/bin/bash

#
# Installs dependencies for the VFDeps package.
#

set -e # Stop as soon as a command fails.
set -x # Print what is being executed.

if [ $(uname -s) = "Linux" ]; then
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
       git wget ca-certificates make m4 \
       gcc patch unzip libgtk2.0-dev \
       valac ninja-build
  if [ "${1}" = "add_focal_repository" ]; then
    sudo add-apt-repository -y "deb http://mirrors.kernel.org/ubuntu/ focal universe"
    sudo apt-get update
  fi
  sudo apt-get install -y --no-install-recommends libgtksourceview2.0-dev

elif [ $(uname -s) = "Darwin" ]; then
  #brew update

  if [ $TRAVIS = "true" ]; then
      brew unlink python # See https://github.com/verifast/verifast/issues/127
  fi

  function brewinstall {
      if brew list $1 1>/dev/null 2>/dev/null; then
	  true;
      else
	  brew install $1;
      fi
  }  
  brewinstall wget
  brewinstall gtk+
  # brewinstall gtksourceview
  brewinstall oras
  if [ "$(uname -m)" = "x86_64" ]; then
    oras pull ghcr.io/homebrew/core/gtksourceview:2.10.5_7@sha256:8ffbbf1fedbe9fa3be634e02c5f9eca4106ff742a1d80b51b75b1582067d2589
    brew install ./gtksourceview--2.10.5_7.sonoma.bottle.tar.gz
  else
    oras pull ghcr.io/homebrew/core/gtksourceview:2.10.5_7@sha256:3ba411d8b2d8c2e2549f03262bb8e2c2e6d3824efb2d3f5a9e99efc6c0eefd0b
    brew install ./gtksourceview--2.10.5_7.arm64_sonoma.bottle.tar.gz
  fi
  brewinstall vala
  brewinstall ninja
  
else

  echo "Your OS is not supported by this script. For Windows, see verifast/vfdeps-win."
  exit 1

fi
