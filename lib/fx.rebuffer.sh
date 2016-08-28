#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function fx_rebuffer () {
  local LN=
  local CMD_RGX='^ *'$'\a''\!buffer-([a-z-]+) +([A-Za-z0-9_-]+)$'
  local -A BUFS
  local B_CMD=
  local B_USE=
  local WARN=( printf '\a@<%s> buffer "%s": %s\n' "$FUNCNAME" )
  local IFS=$'\n'  # default = $' \t\n' makes bash skip leading whitespace.
  while read -rs LN; do
    if [[ "$LN" =~ $CMD_RGX ]]; then
      B_CMD="${BASH_REMATCH[1]}"
      B_USE="${BASH_REMATCH[2]}"
      # "${WARN[@]}" "$B_USE" "cmd:[$B_CMD]"
      case "$B_CMD" in
      init )
        if [ -n "${BUFS[$B_USE]}" ]; then
          "${WARN[@]}" "$B_USE" 'dumping unused content (re-init):'
          echo -n "${BUFS[$B_USE]}"
        fi
        BUFS["$B_USE"]=;;
      add ) ;;
      sed-* )
        B_CMD="${B_CMD#sed-}"   # extract sed options
        read -rs LN             # read next line as sed argument
        LN="$(echo -n "${BUFS[$B_USE]}" | sed -"$B_CMD" "$LN"; echo :)"
        BUFS["$B_USE"]="${LN%:}";;
      end-print )
        [ -n "${BUFS[$B_USE]}" ] && echo -n "${BUFS[$B_USE]}"
        BUFS["$B_USE"]=
        B_USE=;;
      * ) "${WARN[@]}" "$B_USE" "unsupported buffer command: $B_CMD";;
      esac
      continue
    fi
    if [ -n "$B_USE" ]; then
      BUFS["$B_USE"]+="$LN"$'\n'
    else
      printf '%s\n' "$LN"
    fi
  done
  for B_USE in "${!BUFS[@]}"; do
    [ -n "${BUFS[$B_USE]}" ] || continue
    "${WARN[@]}" "$B_USE" 'dumping unused content (finish):'
    echo -n "${BUFS[$B_USE]}"
  done
  return 0
}










[ "$1" == --lib ] && return 0; fx_rebuffer "$@"; exit $?
