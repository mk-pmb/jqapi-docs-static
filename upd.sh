#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"


function upd () {
  cd "$SELFPATH" || return $?

  local CACHE_DIR="cache/$(date +%F)"
  mkdir -p "$CACHE_DIR" || return $?

  local JQAPI_REPO='https://github.com/jquery/api.jquery.com/'
  unzip_good_parts "$JQAPI_REPO"archive/master.zip || return $?

  return 0
}


function dwnl () {
  local SAVE_FN="$1"; shift
  local SRC_URL="$1"; shift
  [ -f "$CACHE_DIR/$SAVE_FN" ] && [ -s "$CACHE_DIR/$SAVE_FN" ] && return 0
  echo -n "DL: $SAVE_FN <"
  wget -O "$CACHE_DIR/$SAVE_FN".part -c "$SRC_URL" || return $?
  mv -- "$CACHE_DIR/$SAVE_FN"{.part,} || return $?
  return 0
}


function fail2 () {
  echo "E: failed to $*" >&2
}


function unzip_good_parts () {
  local REPO_ZIPBALL_SRC="$1"
  local ZIP_SAVE_FN='api-repo.zip'
  dwnl "$ZIP_SAVE_FN" "$REPO_ZIPBALL_SRC" || return $?

  local WANT_FILES=(
    categories.xml
    entries/
    redirects.json
    resources/
    )
  unzip_flattened -qu "$CACHE_DIR/$ZIP_SAVE_FN" "${WANT_FILES[@]}" || return $?
}


function unzip_flattened () {
  local ZIP_OPTS="$1"; shift
  local ZIP_FILE="$1"; shift

  local ZIP_BASEPATH="$(unzip -l "$ZIP_FILE" \
    | grep -xPe '-{3,}\s[\s-]+' -m 1 -A 1 | grep -oPe '\S+/$')"
  [ -n "$ZIP_BASEPATH" ] || return 5$(fail2 'determine zipball basepath')

  local FN=
  local DEST_DIR=
  for FN in "$@"; do
    DEST_DIR="$CACHE_DIR"
    case "$FN" in
      */ )
        DEST_DIR+="/$FN"
        mkdir -p "$DEST_DIR" || return $?
        FN+='*';;
    esac
    unzip -j "$ZIP_OPTS" "$ZIP_FILE" "$ZIP_BASEPATH$FN" \
      -d "$DEST_DIR" || return $?
  done
  return 0
}











[ "$1" == --lib ] && return 0; upd "$@"; exit $?
