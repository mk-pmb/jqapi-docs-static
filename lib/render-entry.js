/*jslint indent: 2, maxlen: 80, continue: false, unparam: false, node: true */
/* -*- tab-width: 2 -*- */
'use strict';

var EX = module.exports, xmLn, fs = require('fs'),
  StringPeeksTextBuffer = require('string-peeks'),
  xmlUtil = require('./xml-util.js');


EX.runFromCLI = function () {
  fs.readFile(process.argv[2], 'utf-8', function (err, entry) {
    if (err) { return console.error(err); }
    entry = EX.parseEntry(entry);
    return entry;
  });
};


EX.parseEntry = function (xml) {
  return (new StringPeeksTextBuffer(xml)).willDrain(function (buf) {
    while (buf.peekTag(/^\?xml/)) { buf.eat(); }
    var entry = {};
    Object.assign(entry, xmlUtil.readTag(buf, 'entry', 'name return type'));
    entry.title = xmlUtil.readTag(buf, 'title', '', '/')['&text'];
    entry.signatures = xmlUtil.readSubTags(buf, '/entry', {
      signature: EX.readSignature,
    });
    console.log('entry:', entry);
    return entry;
  });
};


EX.readSignature = function (buf, tag) {
  var sig = tag.attrs;
  sig.args = xmlUtil.readSubTags(buf, tag, {
    added: xmlUtil.readTagTextSetProp.bind(sig, { prop: 'addedInVersion' }),
    argument: function (buf, argTag) {
      argTag.props = [];
      xmlUtil.readSubTags(buf, argTag, {
        desc: EX.readDesc.bind(argTag.attrs, 'desc'),
        property: EX.readProperty.bind(argTag.props),
      });
      return argTag.attrs;
    },
  });
  console.log('sig:', sig);
  return sig;
};


EX.readDesc = function (descProp, buf, tag) {
  var desc = this[descProp];
  if (desc) {
    if (!Array.isArray(desc)) { desc = [desc]; }
  } else {
    desc = [];
  }
  xmlUtil.expectNoAttrs(tag);
  if (buf.peekTag(/^desc$/)) { buf.eat(); }
  buf.eatUntilMarkOrEnd('</desc>', desc);
  if (desc.length === 1) { desc = desc[0]; }
  console.log('desc:', desc);
  this[descProp] = desc;
};


EX.readProperty = function (buf, tag) {
  xmlUtil.readTagTextSetProp.call(tag.attrs, 'innerXML', buf, tag);
  console.log('prop:', tag.attrs, [buf.peekMark(20)]);
  this.push(tag.attrs);
};























if (require.main === module) { EX.runFromCLI(); }
