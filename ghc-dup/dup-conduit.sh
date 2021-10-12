#!/bin/bash

run() {
  cabal run dup-conduit -- --$1 $2 >/dev/null +RTS -hy -s -RTS 
  hp2pretty dup-conduit.hp
  mv dup-conduit.svg dup-conduit-$2-$1.svg
}

run "no-dup"  "source"
run "use-dup" "source"
