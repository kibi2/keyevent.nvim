#!/bin/sh
set -eu

stylua --check $KIBI2_ROOT/lua $KIBI2_ROOT/tests > out-actual.txt