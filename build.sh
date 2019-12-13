#!/bin/bash

set -e

name=precise-crosshair
version=$(git describe --abbrev=0 --tags)

rm -f $name.pk3

scripts/make_changelog.sh

zip $name.pk3 \
    *.md  \
    *.zs  \
    *.txt \
    graphics/*.png \
    zscript/*.zs   \
    zscript/*/*.zs

cp $name.pk3 $name-$version.pk3

gzdoom -file $name.pk3 "$@"
