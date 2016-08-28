#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

: again
/\a!<skip-eol>$/{
  s~\a[^\a]+$~~
  N
  s~\n~~
  b again
}
