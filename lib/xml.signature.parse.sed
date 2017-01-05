#!/bin/sed -nurf
# -*- coding: UTF-8, tab-width: 2 -*-

: copy
  p;n
  /^  ‹signature›$/{b begin_signature}
b copy


: begin_signature
  N
  s~^  ‹signature›\s*‹added›([0-9.]+)‹/added›|$\
    ~  <section class="doc-funcsig" data-since-version="\1"><header>\
    <h3>\&$funcName;(<ol class="doc-funcargs">\
      </ol><!--/.doc-funcargs-->)</h3>\
    <p class="since-version">\1</p>\n  </header><dl class="doc-funcargs">\n~
  /^  </!{s~^~\a@<signature:begin> unexpected intro ~;b copy}

: in_signature
  \~‹/signature›~{
    s~^( *)‹/signature›$~\1</dl></section><!--/.doc-funcargs/.doc-funcsig-->~
    /\a/{s~\a~&@<signature:bell at end of signature> ~}
    b copy
  }

  /^ *‹argument [^‹›]+›$/b funcsig_arg_start

  p;n
b in_signature


################################################################################

: funcsig_arg_start
  s~‹argument( [^‹›<>]+)›~<dt class="doc-funcarg"\a\1>\a\1</dt>\
    <dd class="doc-funcarg">~g
  s~(<([a-z]+) class="doc-funcarg)("[^<>]*) (optional)="true"($\
     ^1^2                          ^3        ^4     \
     v5                                             \
    |[^<>]*>[^<>]*)</\2>~\1 doc-\4-funcarg\3\5</\2>~g

  : funcsig_arg_parse
    s~>(\a[^<>]*) (type)="([A-Za-z]+)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (name)="([A-Za-z]+)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (optional)="(true)"~><arg-\2=\3\a>\1~g
    s~"\a ([a-z]+="[^<>"\a]+")~" data-\1\a~g
  t funcsig_arg_parse

  s~"\a\s*>~">~g
  s~<arg-type=([A-Za-z]+)\a><arg-name=([A-Za-z]+)\a>\s*~<a\
      class="doc-link doc-type-link argtype" href="Types.html#\1"\
      >\1</a><span class="arg-type-space">\
      </span><span class="argname">\2</span>~g
  s~><arg-([a-z-]+)=([^<>\a]+)\a>~\
      ><span class="arghint arg-\1"\
        ><span class="arghint-key">\1</span\
        ><span class="arghint-sep"> </span\
        ><span class="arghint-value">\2</span\
      ></span><!--/.arghint-->~g
  s~\a(\s*</(dt)[ >])~\1~g

  /\a/s~^~\a@<funcsig_arg_start:before_content> unexpected bell\n~

: funcsig_arg_content
  \~‹/signature›~{s~\a~&@<signature:ends in funcsig_arg?!> ~;b copy}

  \~‹/argument›~{
    s~(\n *|)‹/argument›~\1</dd><!--/.doc-funcarg-->\n~g
    s~(<dd class="doc-funcarg)("></dd>)~\1 doc-no-descr\2~g
    p;n
    b in_signature
  }

  /^ *‹property [^‹›]+›$/b funcsig_argprop_start

  p;n
b funcsig_arg_content


################################################################################

: funcsig_argprop_start
  s~‹property( [^‹›<>]+)›~<dt class="doc-funcargprop"\a\1>\a\1</dt>\
      <dd class="doc-funcargprop">~g
  s~(<([a-z]+) class="doc-funcargprop)("[^<>]*) (optional)="true"($\
     ^1^2                          ^3        ^4     \
     v5                                             \
    |[^<>]*>[^<>]*)</\2>~\1 doc-\4-funcargprop\3\5</\2>~g

  : funcsig_argprop_parse
    s~>(\a[^<>]*) (type)="([A-Za-z]+)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (name)="([A-Za-z]+)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (optional)="(true)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (default)="([A-Za-z0-9 ]+)"~><arg-\2=\3\a>\1~g
    s~"\a ([a-z]+="[^<>"\a]+")~" data-\1\a~g
  t funcsig_argprop_parse

  s~"\a\s*>~">~g
  s~<arg-type=([A-Za-z]+)\a><arg-name=([A-Za-z]+)\a>\s*~<a\
        class="doc-link doc-type-link argtype" href="Types.html#\1"\
        >\1</a><span class="arg-type-space">\
        </span><span class="argname">\2</span>~g
  s~><arg-([a-z-]+)=([^<>\a]+)\a>~\
        ><span class="arghint arg-\1"\
          ><span class="arghint-key">\1</span\
          ><span class="arghint-sep"> </span\
          ><span class="arghint-value">\2</span\
        ></span><!--/.arghint-->~g
  s~\a(\s*</(dt)[ >])~\1~g

  /\a/s~^~\a@<funcsig_argprop_start:before_content> unexpected bell\n~

: funcsig_argprop_content
  \~‹/signature›~{s~\a~&@<signature:ends in funcsig_argprop?!> ~;b copy}

  \~‹/property›~{
    s~(\n *|)‹/property›~\1</dd><!--/.doc-funcargprop-->\n~g
    s~(<dd class="doc-funcargprop)("></dd>)~\1 doc-no-descr\2~g
    p;n
    b funcsig_arg_content
  }

  /^ *‹argument [^‹›]+›$/b funcsig_argproparg_start

  p;n
b funcsig_argprop_content


################################################################################

: funcsig_argproparg_start
  s~‹argument( [^‹›<>]+)›~<dt class="doc-funcargproparg"\a\1>\a\1</dt>\
    <dd class="doc-funcargproparg">~g
  s~(<([a-z]+) class="doc-funcargproparg)("[^<>]*) (optional)="true"($\
     ^1^2                          ^3        ^4     \
     v5                                             \
    |[^<>]*>[^<>]*)</\2>~\1 doc-\4-funcargproparg\3\5</\2>~g

  : funcsig_argproparg_parse
    s~>(\a[^<>]*) (type)="([A-Za-z]+)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (name)="([A-Za-z]+)"~><arg-\2=\3\a>\1~g
    s~>(\a[^<>]*) (optional)="(true)"~><arg-\2=\3\a>\1~g
    s~"\a ([a-z]+="[^<>"\a]+")~" data-\1\a~g
  t funcsig_argproparg_parse

  s~"\a\s*>~">~g
  s~<arg-type=([A-Za-z]+)\a><arg-name=([A-Za-z]+)\a>\s*~<a\
      class="doc-link doc-type-link argtype" href="Types.html#\1"\
      >\1</a><span class="arg-type-space">\
      </span><span class="argname">\2</span>~g
  s~><arg-([a-z-]+)=([^<>\a]+)\a>~\
      ><span class="arghint arg-\1"\
        ><span class="arghint-key">\1</span\
        ><span class="arghint-sep"> </span\
        ><span class="arghint-value">\2</span\
      ></span><!--/.arghint-->~g
  s~\a(\s*</(dt)[ >])~\1~g

  /\a/s~^~\a@<funcsig_arg_start:before_content> unexpected bell\n~

: funcsig_arg_content











#
