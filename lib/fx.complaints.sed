#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

: read_all
$!{N;b read_all}

s~‹~\a@<complain:unparsed> &~g
s~\s*\a~\n\n!! ~g
