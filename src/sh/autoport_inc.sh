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

JAIL=${JAIL:-$(echo $VERSION | sed -E 's!(\.[0-9]+)-(RELEASE|STABLE)!\1-!;s!\.!-!')_${ARCH}}

## FIXME: what is/was the 'gjb' jail method?
#JHOW=${JHOW:-ftp}
## svn must be installed first
#JHOW=${JHOW:-svn+ssh}


JHOW=${JHOW:-null -M /usr/local/jail}
## cd /usr/src && for tgt in installworld distrib-dirs distribution; do make $tgt installworld DESTDIR=${JAIL_PATH} DB_FROM_SRC=1
##
## cp /etc/make.conf ${JAIL_PATH}
##
## ... modify for ccache ?, see :
## https://fossil.etoilebsd.net/poudriere/doc/trunk/doc/ccache.wiki
## 


#JHOW=${JHOW:-src=/usr/src}


#PHOW=${PHOW:-portsnap}
## To use the git method, of course git must be installed first
PHOW=${PHOW:-portsnap}


## do we have to run portsnap first, independent of poudriere?
## `portsnap fetch` ... ?


TREE=${TREE:-local}

PARALLEL=${PARALLEL:-6}

PCMD=poudriere

LIST=${1:-local.list}

MAINS=${MAINS:--F}
