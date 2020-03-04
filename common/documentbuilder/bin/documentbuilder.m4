#!/bin/sh

DIR=/opt/M4_DB_PREFIX
LD_LIBRARY_PATH=$DIR
export LD_LIBRARY_PATH
exec $DIR/docbuilder $@
