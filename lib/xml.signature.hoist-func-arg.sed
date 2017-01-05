#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

/^  ‹signature›/{

  /\a/{s~\a~&@<signature:bell before buffer marks> ~;b}
  s~<ol class="doc-funcargs">\n~&\n\a!buffer-init funcsig-head\
    \a!buffer-init funcsig-defer\n~
  s~</dt( [^<>]*|)>\s*<dd class="doc-funcarg[ "]~\a&~g
  s~(\n *)<dt(\sclass="doc-funcarg[ "][^\a]+)\a</dt([^\n]+)\n~\
    \a!buffer-add funcsig-head\n    <li\2</li\3\n\
    \a!buffer-add funcsig-defer\1<dt\2</dt\3\n~g
  s~$~\
    \a!buffer-sed-re funcsig-head\
      s:^:  :\
    \a!buffer-end-print funcsig-head\
    \a!buffer-end-print funcsig-defer~














}
