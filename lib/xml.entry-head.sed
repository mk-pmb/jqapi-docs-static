#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

1{/^‹entry /{
  s~ ~\t~g
  N;s~^‹entry(\s[^‹›<>]+)›\n\s*‹title›([^‹›<>]+)‹/title›$|$\
    ~<chapter class="doc-entry§c">\n  <h>\2</h>\n\t\1~
  /^<chapter/{
    s~<h>~<header class="entry-title§h">\n    <h2>~
    s~</h>~</h2>\n  </header>~
    s~^([^\t]*)(§c[^\t]*\n\t.*)\t(type)="(method|$\
      )"~\1 doc-\4-entry\2~
    s~^(<[^\t<>]*)(>[^\t]*\n\t.*)\t(name)="([a-zA-Z.]+|$\
      )"~\1 id="\a!<dashify>\n\4\n"\2~
    s~(\n *</header>[^\t]*\n\t.*)\t(return)="([A-Za-z]+|$\
      )"~\n    <p class="doc-\2-value">\3</p>\1~
    s~§[ch]~~g
    s~\s+$~~
    s~\t[\n\t]*~\a@<entry:attr> ~g
  }
}}

${/^‹\/entry›$/d}
