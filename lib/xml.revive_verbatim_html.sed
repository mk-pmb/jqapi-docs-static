#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

/^\s+‹(desc|longdesc)›.*‹\/\1›$/{
  s~^(\s+)‹(desc|longdesc)›~\1<div class="\2">~
  s~‹/(desc|longdesc)›$~</div>~
  s~‹pre›‹code›([^‹›<>]+)‹/code›‹/pre›|$\
    ~<pre class="code doc-pre-code">\1</pre>~g
  s~(‹code)›‹(abbr )~\1+\2~g
  s~‹/(abbr›)(‹/code)›~\2+\1~g
  s~‹(/?(ul|ol|li|p))›~<\1>~g
  s~(‹a href="[^"‹›<>]+"›[^‹›<>]+)‹/a›~\1</a>~g

  : desc_easy_tags
    s~‹(code|strong|em)›([^‹›<>]+)‹/\1›~<\1>\2</\1>~g
    s~‹((code\+|)abbr)( title="[^"‹›<>]+")›([^‹›<>]+)‹/\1›~<\1\3>\4</\1>~g
    s~‹a href="/((jQuery\.|)[a-z][A-Za-z]+)/"›|$\
        ~<a class="doc-link doc-entry-link" href="\1.html">~g
    s~‹a href="/(([A-Z][a-z]+_?){1,2})/"›|$\
        ~<a class="doc-link doc-pages-link" href="\1.html">~g
    s~‹a href="#([A-Za-z-]+)"›|$\
        ~<\1 class="doc-link doc-section-link" href="#\1">~g
    s~‹a href="((https?)://[^"‹›]+)"›|$\
        ~<\1 class="ext-link ext-link-\2" href="\1">~g
  t desc_easy_tags

  s~\a~&@<revive:desc> ~g
  /\a/!d
}
