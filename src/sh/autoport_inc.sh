## autoport_inc.sh
##
## common variables and shell functions for the autoport utility
##
##


name() {
	basename $0
}

msg() {
	echo "$(name): $@" 
}

VERSION=${VERSION:-$(uname -r)}

ARCH=${ARCH:-$(uname -m)}

JAIL=${JAIL:-$(echo $VERSION | sed -E 's!(\.[0-9]+)-(RELEASE|STABLE)!\1-!;s!\.!-!')${ARCH}}

## FIXME: what is/was the 'gjb' jail method?
#JHOW=${JHOW:-ftp}
## svn must be installed first
#JHOW=${JHOW:-svn+ssh}

JHOW=${JHOW:-null -M /usr/local/jail}
#JHOW=${JHOW:-src=/usr/src}


#PHOW=${PHOW:-portsnap}
## To use the git method, of course git must be installed first
PHOW=${PHOW:-git}


## do we have to run portsnap first, independent of poudriere?
## `portsnap fetch` ... ?


TREE=${TREE:-local}

PARALLEL=${PARALLEL:-6}

PCMD=poudriere

LIST=${1:-local.list}

MAINS=${MAINS:--F}
