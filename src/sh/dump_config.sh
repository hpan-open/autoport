#!/bin/sh

## trivial config dump script for autoport

THIS_PATH="$(readlink -f $0)"
THIS_DIR="$(dirname $THIS_PATH)"
. "${THIS_DIR}/autoport_inc.sh"


msg "Using jail name $JAIL"

poudriere options -s -j ${JAIL} -p ${TREE} -f ${LIST} |
  grep -E -v "^=+>" | 
  sed -E 's|^[ \t]+([A-Za-z0-9_]+=[A-Za-z0-9_]+)\:.*|\1|' | 
  sort | uniq

