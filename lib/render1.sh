#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"


function render_mode_detect () {
  local SRC_FN="$1"; shift
  case "$SRC_FN" in
    -* ) echo "E: unsupported option: $SRC_FN" >&2; return 2;;
  esac

  local FX_LIB=
  for FX_LIB in "$SELFPATH"/fx.*.sh; do
    [ -n "$FX_LIB" ] || continue
    tail -n 1 "$FX_LIB" | grep -qFe '[ "$1" == --lib ]' || continue
    source "$FX_LIB" --lib || return $?
  done

  local SRC_TYPE="$(head -c 256 -- "$SRC_FN" | grep -oPe '^<entry ' -m 1 \
    | tr -dc 'a-z')"
  case "$SRC_TYPE" in
    entry ) render_one_"$SRC_TYPE" "$SRC_FN"; return $?;;
  esac
  echo "E: failed to guess source type for file $SRC_FN" >&2
  return 4
}


function render_one_entry () {
  [ "$#" == 0 ] && tty --silent && echo 'I: start reading XML from stdin.'
  csed -urf xml.pre-chunk.sed -- "$@" \
    | csed -urf xml.entry-head.sed \
    | csed -urf xml.signature.parse.sed | fx_rebuffer \
    | csed -urf xml.revive_verbatim_html.sed \
    \
    | csed -urf fx.hyphenize.sed \
    | csed -urf fx.skip-eol.sed \
    | fx_def_ent \
    \
    | csed -urf fx.complaints.sed
  return 0
}


function csed () {
  case "$1" in
    =* ) cat; return $?;;
  esac
  LANG=C LANGUAGE=C sed "$@"
  return $?
}








render_mode_detect "$@"; exit $?
