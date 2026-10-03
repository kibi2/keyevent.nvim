#!/bin/sh
set -eu

case "${1:-run}" in
  pre)
    ;;
  post)
    LC_ALL=C sed \
      -e '/^Error detected /d' \
      -e '/^line   39:$/d' \
      out-actual.txt > gen.txt
    mv gen.txt out-actual.txt
    ;;
esac

      #-e 's/^while processing //g' \