#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

: read_all
$!{N;b read_all}

s~‹~\a@<complain:unparsed> &~g
: space_bell_to_middot
  s~ ( *\a)~·\1~g
t space_bell_to_middot
s~\s*((·)*)\a(@<([^<>]+)>|)~\n\n!! @\4\1~g
