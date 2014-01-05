#!/bin/sh

ACLOCAL=${ACLOCAL:-aclocal}
AUTOHEADER=${AUTOHEADER:-autoheader}
AUTOCONF=${AUTOCONF:-autoconf}

set -e

run() {
    echo "$0: running \`$@'"
    $@
}

run $ACLOCAL
run $AUTOHEADER -W all
run $AUTOCONF -W all
