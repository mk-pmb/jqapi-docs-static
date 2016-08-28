#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function fx_def_ent () {
  local LN=
  local ENT=()
  local RGX='\&\$([A-Za-z0-9]+);'
  local -A ENTS
  local IFS=$'\n'  # default = $' \t\n' makes bash skip leading whitespace.
  while read -rs LN; do
    while [[ "$LN" =~ $RGX ]]; do
      ENT=( "${BASH_REMATCH[@]}" )
      ENT[2]="${ENTS[${ENT[1]}]}"
      [ -n "${ENT[2]}" ] || echo $'\a'"<$FUNCNAME> undefined entity: ${ENT[0]}"
      LN="${LN//${ENT[0]}/${ENT[2]%:}}"
    done
    case "$LN" in
    $'\a!def-ent '* )
      LN="${LN#* }"
      ENT=( "${LN%%=*}" "${LN#*=}" )
      [ "${ENT[0]}" == "${ENT[1]}" ] && ENT[0]=
      if [ -n "${ENT[0]}" ]; then
        ENTS["${ENT[0]}"]="${ENT[1]}:"
      else
        echo $'\a'"<$FUNCNAME> entity name missing in definition"
      fi
      continue;;
    esac
    printf '%s\n' "$LN"
  done
  return 0
}










[ "$1" == --lib ] && return 0; fx_def_ent "$@"; exit $?
