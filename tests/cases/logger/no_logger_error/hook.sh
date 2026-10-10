#!/bin/sh
set -eu

case "${1:-run}" in
  pre)
    ;;
  post)
    LC_ALL=C sed \
      -e 's/t .*\/tests\//t \/tests\//' \
      stderr.txt > gen.txt
    mv gen.txt out-actual.txt
    ;;
esac

      #-e 's/^while processing //g' \
