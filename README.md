autoport - a build automation tool for FreeBSD ports
====================================================

# Overview

This is a rudimentary collection of shell scripts for automating
port builds with the FreeBSD `poudriere` tool.

## Prerequisites - ports

* ports-mgmt/pkg
* ports-mgmt/dialog4ports
* ports-mgmt/poudriere

## Prerequisites - other resources

By default, autport uses a jail that would exist at `/usr/local/jail`
such that may be created as by the following procedure:

> JAIL_HOME=/usr/local/jail
> cd /usr/src && make installworld distrib-dirs distribution DESTDIR=${JAIL_HOME} DB_FROM_SRC=1
> cp /etc/make.conf ${JAIL_HOME}/etc/make.conf
> ... etc


## Example

sh src/sh/do_build.sh src/list/corvid.list


## Copyright

Refer to the file `LICENSE`
