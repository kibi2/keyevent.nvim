#!/bin/sh
set -eu

rg "log\.probe\(" $KIBI2_ROOT/lua > out-actual.txt