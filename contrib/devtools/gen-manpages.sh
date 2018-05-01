#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

NEWCOIND=${NEWCOIND:-$SRCDIR/blocknewd}
NEWCOINCLI=${NEWCOINCLI:-$SRCDIR/blocknew-cli}
NEWCOINTX=${NEWCOINTX:-$SRCDIR/blocknew-tx}
NEWCOINQT=${NEWCOINQT:-$SRCDIR/qt/blocknew-qt}

[ ! -x $NEWCOIND ] && echo "$NEWCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
NTCVER=($($NEWCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$BITCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $NEWCOIND $NEWCOINCLI $NEWCOINTX $NEWCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${NTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${NTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
