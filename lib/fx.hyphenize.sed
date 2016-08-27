#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

/\a!<dashify>$/{
  s~\a[^\a]+$~\a!<skip-eol>~
  p
  N;s~^[^\n]+\n~~
  s![^A-Za-z0-9_-]+!-!g
  s~$~\a!<skip-eol>~
}
