#!/bin/sh

_SCRIPT=$(readlink -f $0)
_DIR=$(dirname ${_SCRIPT})/../..

_BASE=$(grep -oE 'Version: [0-9.]*' ${_DIR}/rpm/SailfishWeibo.yaml | awk '{ print $2 }') 
_RELEASE=$(grep 'Release:*' ${_DIR}/rpm/SailfishWeibo.yaml | awk '{ print $2 }') 

if [ -d $_DIR/.git ]; then
	_REV=$(git rev-parse --short HEAD)
	#echo "${_BASE}.${_RELEASE}-build-${_REV}"
	echo "${_BASE}.${_RELEASE}-build-${_REV}"
else
	echo ${_BASE}
fi
