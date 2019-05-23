#!/bin/bash

#IWAD=~/Programs/Games/wads/doom/freedoom1.wad
#IWAD=~/Programs/Games/wads/doom/HERETIC.WAD
#IWAD=~/Programs/Games/wads/modules/game/harm1.wad

name=precise-crosshair
version=$(git describe --abbrev=0 --tags)

rm -f $name.pk3 \
&& \
scripts/make_changelog.sh && \
zip $name.pk3 \
    *.md  \
    *.zs  \
    *.txt \
    zscript/*.zs   \
    zscript/*/*.zs \
&& \
cp $name.pk3 $name-$version.pk3 \
&& \
gzdoom -iwad $IWAD \
       -file \
       $name.pk3 \
       ~/Programs/Games/wads/maps/DOOMTEST.wad \
       "$1" "$2" \
       +map test \
       +notarget
