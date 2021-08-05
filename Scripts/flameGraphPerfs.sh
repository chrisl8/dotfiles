#!/bin/bash

SED_REPLACEMENTS=()
# From https://nodejs.org/en/docs/guides/diagnostics-flamegraph/
SED_REPLACEMENTS+=(-e "/ __libc_start/d")
SED_REPLACEMENTS+=(-e "/ LazyCompile /d")
SED_REPLACEMENTS+=(-e "/ v8::internal::/d")
SED_REPLACEMENTS+=(-e "/ Builtin:/d")
SED_REPLACEMENTS+=(-e "/ Stub:/d")
SED_REPLACEMENTS+=(-e "/ LoadIC:/d")
SED_REPLACEMENTS+=(-e "/\[unknown\]/d")
SED_REPLACEMENTS+=(-e "/ LoadPolymorphicIC:/d")

# My own additions
SED_REPLACEMENTS+=(-e "/ start_thread/d")

cp perfs.out temp.out
#echo -i "${SED_REPLACEMENTS[@]}" temp.out
sed -i "${SED_REPLACEMENTS[@]}" temp.out
sed -i -e 's/ LazyCompile:[*~]\?/ /' temp.out
stackvis perf < temp.out > flamegraph.htm
rm temp.out
