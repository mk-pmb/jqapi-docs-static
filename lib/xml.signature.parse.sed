#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

/^  ‹signature›/{
  N
  s~^  ‹signature›\s*‹added›([0-9.]+)‹/added›|$\
    ~  <section class="doc-funcsig" data-since-version="\1"><header>\
    <h3>\&$funcName;(<ol class="doc-funcargs">\
      </ol><!--/.doc-funcargs-->)</h3>\
    <p class="since-version">\1</p>\n  </header><dl class="doc-funcargs">\n~
  /^  </!b
  : read_entire_sig
    N
  /‹\/signature›/!b read_entire_sig

  s~‹argument( [^‹›<>]+)›~<dt class="doc-funcarg"\a\1>\a\1</dt>\
    <dd class="doc-funcarg">~g
  s~(<([a-z]+) class="doc-funcarg)("[^<>]*) (optional)="true"($\
     ^1^2                          ^3        ^4     \
     v5                                             \
    |[^<>]*>[^<>]*)</\2>~\1 doc-\4-funcarg\3\5</\2>~g
  s~(\n *)‹/argument›~\1</dd><!--/.doc-funcarg-->\n~g

  : parse_args
    s~>(\a[^<>]*) (type)="([A-Za-z]+)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (name)="([A-Za-z]+)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (optional)="(true)"~><arg-\2=\3\a>\1~g
    s~"\a ([a-z]+="[A-Za-z]+")~" data-\1\a~g
  t parse_args

  s~"\a\s*>~">~g
  s~<arg-type=([A-Za-z]+)\a><arg-name=([A-Za-z]+)\a>\s*~<a\
      class="doc-link doc-type-link argtype" href="Types.html#\1"\
      >\1</a><span class="arg-type-space">\
      </span><span class="argname">\2</span>~g
  s~<arg-(optional)=(true)\a>~<span\
      class="arghint arg-\1">\1</span>~g
  s~(>|)\a(\s*)(</(li)[ >])~\2\1\3~g
  s~\a(\s*</(ol|li|dt)[ >])~\1~g

  s~(\n *)‹\/signature›$~\1</dl></section><!--/.doc-funcargs/.doc-funcsig-->~
  /\a/{s~\a~&@<signature:bell after end of signature> ~;b}

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
