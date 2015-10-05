
# Notes

1. Create Local Jail from Local Base System Build

**References**
* [Managing Jails with ezjail](https://www.freebsd.org/doc/handbook/jails-ezjail.html)
* [ezjail homepage](https://erdgeist.org/arts/software/ezjail/)
* [Appserver Jails HOWTO](https://wiki.freebsd.org/AppserverJailsHOWTO)

**Ed Note**: The following text about ezjail might be a useful summary, though not going into detail about launching poudriere from within the created jail

First, **configure `rc.conf` for `cloned_interfaces="lo1"`**, then `service netif cloneup`

Secondly, **update the system ports tree** (`portsnap`) 

>    cd /usr/src
>    portsnap fetch
>    portsnap update

If needed, **rebuild the system's pkgng**

>    cd /usr/ports/ports-mgmt/pkg
>    make
>    make deinstall
>    make install clean

**Build and install ezjail**

>    cd /usr/ports/sysutils/ezjail
>    make install clean

Optionally, **configure `rc.conf` for `ezjail_enable="YES"`** and `service ezjail start`

**Build the _basejail_** for the host -- to `/usr/jails/fulljail` from `/usr/src` (as previously a `make installworld` source)

>    ezjail-admin update -i -p

Ed. note: _This takes a short while_

**Create a jail for use by Poudriere** (non-ZFS), at `/usr/jails/portjail`

>    ezjail-admin create portjail 'lo1|127.0.0.1,em0|192.168.100.50'

Ed. Note: ... sshd, ntpd, syslogd ...

**Ed. Note:** ezjail may not be "the right tool" to use for creating build-time jails to use in Poudriere. However, ezjail can be useful for managing jails in which to run poudriere

**Creating a jail source tfor Poudriere build-time jails**

>    cd /usr/src
>    make installworld DESTDIR=/usr/jails/pjail DB_FROM_SRC=1
>    make distrib-dirs DESTDIR=/usr/jails/pjail DB_FROM_SRC=1
>    make distribution DESTDIR=/usr/jails/pjail DB_FROM_SRC=1


**Initialize the jail with Poudriere**

>    VERSION=$(uname -r)
>    JAILNAME=$(echo $VERSION | sed 's|\.|-|')

**NOT**
>    poudriere jail -c -j ${JAILNAME} -v ${VERSION} -m null -M /usr/jails/portjail

**INSTEAD**
>    poudriere jail -c -j ${JAILNAME} -v ${VERSION} -m null -M /usr/jails/pjail

_Ed. Note: The jail created in this step will be used as a source for initializing a 'reference jail', at build time_

**Initialize a ports tree with Poudriere**, using the 'git' ports method

>    PORTSNAME="$(hostname -s)"
>    poudriere ports -c -p ${PORTSNAME} -m git

Ports tree will be cloned to "/usr/local/poudriere/ports/${PORTSNAME}"

Ed. note: _This takes a short while_

**Create a list of packages to build**

>    cat<<EOF>> my.list
>    misc/mmv
>    sysutils/less
>    sysutils/xstow
>    sysutils/screen
>    EOF

**Configure packages from list**

>    poudriere options -p ${PORTSNAME} -j ${JAILNAME} -f my.list

Ed. note: Some configuration options may result in selection of additional dependencies, thus requiring later configuration dialogues

** Build Packages from list**, 3 parallel builds

>    poudriere bulk -p ${PORTSNAME} -j ${JAILNAME} -f my.list -J 3 -C

Ed. note: distfiles retrieved from `MASTER_SITES`

Ed. note: FIles will be created at  `"/usr/local/poudriere/data/packages/${JAILNAME}-${PORTSNAME}"`

Ed. note: See also `pkg.conf(5)`

>    mkdir -p /usr/local/etc/pkg/repos
>    REPNAME=${PORTSNAME}
>    CONF=/usr/local/etc/pkg/repos/${PORTSNAME}.conf
>    PKGPATH=/usr/local/poudriere/data/packages/${JAILNAME}-${PORTSNAME}
>    if ! [ -a ${CONF} ]; then
>      cat <<EOF> ${CONF}
>    ${REPNAME} {
>       url: "file://${PKGPATH}"
>       priority: 10
>    }
>    EOF

...

FIXME: That's all of a non-optimal way to do it


Alternate approach: Install from list in build log 

>    export ASSUME_ALWAYS_YES=yes
>    PKGS=$(awk '{print $1}' /usr/local/poudriere/data/logs/bulk/${JAILNAME}-${PORTSNAME}/latest/.poudriere.ports.built)
>    pkg remove ${PKGS} && pkg install ${PKGS}


Alternate approach : Reinstall all packages installed from repository ${REPNAME}

>    export ASSUME_ALWAYS_YES=yes
>    PKGS="$(pkg rquery -r ${REPNAME} '%n')"
>    pkg remove ${PKGS} && pkg install ${PKGS}

**Next: Updating Jail and Ports, Rebuilding Packages, and Upgrading Packages on Network Hosts...*

**Also: Building as non-root**