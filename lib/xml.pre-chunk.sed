#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

/^<\?xml\b[^<>]*\?>$/d

: read_pre
/<pre/{/<\/pre>/!{N;b read_pre}}

: read_cdata
/<!\[CDATA\[/{/\]\]>/!{N;b read_cdata}}

: read_desc
/<desc/{/<\/desc>/!{N;b read_desc}}

s~\s+$~~
# s~^(\s*)(<)~\1\&\2~
s~\r~¶~g
s~\t~\&#9;~g
s~\n~\t~g

s~<~‹~g
s~>~›~g
