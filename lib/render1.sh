#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"


function render1 () {
  export LANG{,UAGE}=C
  [ "$#" == 0 ] && tty --silent && echo 'I: start reading XML from stdin.'
  sed -urf xml.pre-chunk.sed -- "$@" \
    | sed -urf xml.entry-head.sed \
    | sed -urf xml.revive_verbatim_html.sed \
    \
    | sed -urf fx.hyphenize.sed \
    | sed -urf fx.skip-eol.sed \
    \
    | sed -urf fx.complaints.sed
  return 0
}








[ "$1" == --lib ] && return 0; render1 "$@"; exit $?
