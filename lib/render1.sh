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
  csed - xml.pre-chunk.sed -- "$@" \
    | csed - xml.entry-head.sed \
    | csed - xml.signature.argprops.sed \
    | csed - xml.signature.parse.sed \
    | csed =- xml.signature.hoist-func-arg.sed | csed =fx_rebuffer \
    | csed - xml.revive_verbatim_html.sed \
    \
    | csed - fx.hyphenize.sed \
    | csed - fx.skip-eol.sed \
    | fx_def_ent \
    \
    | csed - fx.complaints.sed
  return 0
}


function csed () {
  local SED_OPTS="$1"; shift
  local SED_FN="$SELFPATH/$1"; shift
  local ABS_PWD="$(readlink -m .)"
  [ -n "$ABS_PWD" ] || ABS_PWD="$PWD"
  case "$SED_FN" in
    "$PWD"/* ) SED_FN="./${SED_FN#$PWD/}";;
    "$ABS_PWD"/* ) SED_FN="./${SED_FN#$ABS_PWD/}";;
  esac
  local SED_CMD=( sed "$SED_OPTS" "$SED_FN" "$@" )
  case "$SED_OPTS" in
    =* ) cat; return $?;;
    - ) SED_CMD=( "${SED_CMD[@]:2}" );;
  esac
  # echo "S: ${SED_CMD[*]}" >&2
  LANG=C LANGUAGE=C "${SED_CMD[@]}"
  return $?
}








render_mode_detect "$@"; exit $?
