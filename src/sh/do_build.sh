#!/bin/sh

THIS_PATH="$(readlink -f $0)"
THIS_DIR="$(dirname $THIS_PATH)"
. "${THIS_DIR}/autoport_inc.sh"

msg "Using jail name $JAIL"

## Create or Update jail

if $PCMD jail -l -q | awk '{print $1}' | grep "^${JAIL}\$" > /dev/null; then
    ## don't update jail if using 'null' method - kludge (FIXME)
    if ! bash -c "[[ \"$JHOW\" =~ 'null' ]]"; then
       msg "Updating jail ${JAIL}"
       { $PCMD jail -k -j ${JAIL} -p ${TREE} &&
               $PCMD jail -u -j ${JAIL} -J ${PARALLEL} -a ${ARCH} -v ${VERSION} -m ${JHOW} -p ${TREE}; } ||
           exit ## ||
    fi
else
  ## create jail
  msg "Creating jail ${JAIL}"
  $PCMD jail -c -j ${JAIL} -J ${PARALLEL} -a ${ARCH} -v ${VERSION} -m ${JHOW} ||
    exit ## ||
fi

## Create or Update ports tree


if $PCMD ports -l -q | awk '{print $1}' | grep "^${TREE}\$" > /dev/null; then
  ## update ports tree
  msg "Updating ports tree ${TREE}"
  $PCMD ports -u -p ${TREE} -m ${PHOW}
else
  ## create ports tree
  msg "Creating ports tree ${TREE}"
  $PCMD ports -c -p ${TREE} -m ${PHOW}
fi


## Configure

msg "Configuring ports from list $1"

$PCMD options -j ${JAIL} -p ${TREE} -f ${LIST}

## Build

msg "Building ports from list $1"

$PCMD bulk -j ${JAIL} -C -v -p ${TREE} -f ${LIST} -J ${PARALLEL} ${MAINS}
