#!/bin/sed -nurf
# -*- coding: UTF-8, tab-width: 2 -*-

: copy
  p;n
  /^  ‹signature›$/{b in_signature}
b copy


: in_signature
  \~‹/signature›~b copy
  /^ *‹argument [^‹›]+›$/b funcsig_arg_start
  p;n
b in_signature
