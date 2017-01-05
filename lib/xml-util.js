/*jslint indent: 2, maxlen: 80, continue: false, unparam: false, node: true */
/* -*- tab-width: 2 -*- */
'use strict';

var EX = module.exports,
  xmlAttrDict = require('xmlattrdict'),
  XmlAttrDictTag = require('xmlattrdict/xmltag');


EX.readTag = function (buf, expTagName, expAttrs, expEndTag) {
  if (expEndTag === '/') { expEndTag += expTagName; }
  if ((typeof expTagName) === 'string') {
    expTagName = new RegExp('^' + expTagName + '(\\s|/?$)', '');
  }
  var tag = XmlAttrDictTag.peekTag(buf, expTagName, '||err'),
    gotAttrs = Object.keys(tag.attrs).sort().join(' ');
  buf.eat();
  if ((gotAttrs !== expAttrs) && (expAttrs !== '*')) {
    throw tag.err('Expected attributes "' + expAttrs + '" but got "'
      + gotAttrs + '"');
  }
  if (expEndTag) {
    tag.attrs['&text'] = tag.try(EX.readXmlText, [buf, expEndTag]);
  }
  return tag.attrs;
};


EX.readXmlText = function (buf, expEndTag) {
  var text = '', nxTag;
  while (buf.peekMark({ mark: '<', inc: false })) {
    text += xmlAttrDict.xmldec(buf.eat());
    nxTag = buf.peekTag();
    if (nxTag === expEndTag) {
      buf.eat();
      break;
    }
    if (nxTag) { throw 'unexpected tag: <' + nxTag + '>'; }
  }
  return text;
};


EX.readSubTags = function (buf, endTag, subTagHandlers) {
  var tags = [], tag, hnd;
  if (endTag.tagName) { endTag = '/' + endTag.tagName; }
  while (true) {
    tag = XmlAttrDictTag.peekTag(buf, /^/);
    if (!tag) {
      tag = Object.create(XmlAttrDictTag);
      tag.tagName = '&text';
      tag.srcPos = buf.calcPosLnChar();
    }
    if (tag.tagName === endTag) { return tags; }
    hnd = subTagHandlers[tag.tagName];
    if (hnd === undefined) {
      throw tag.err('no handler configured; handlers: ['
        + Object.keys(subTagHandlers).join(', ') + '], endTag: ' + endTag);
    }
    console.log('readSubTags:', tag.tagName, '>>');
    buf.eat();
    switch (hnd && typeof hnd) {
    case 'function':
      hnd = hnd(buf, tag);
      if (hnd !== undefined) { tags.push(hnd); }
      break;
    }
    hnd = buf.peekTag(/^\//);
    if (hnd) {
      if (hnd.after === tag.tagName) {
        hnd.eaten = buf.eat();
        console.log('readSubTags:', tag.tagName, '/?', hnd.eaten);
      }
    }
    console.log('readSubTags:', tag.tagName, '<<', [buf.peekMark(20)]);
  }
};


EX.readTagTextSetProp = function (opts, buf, tag) {
  var destProp = opts.prop, text;
  switch (destProp) {
  case undefined:
    destProp = tag.tagName;
    break;
  }
  text = tag.try(EX.readXmlText, [buf, '/' + tag.tagName]);
  if ((typeof opts.raw) === 'string') { this[opts.raw] = text; }
  if (opts.raw !== true) { text = xmlAttrDict.xmldec(text); }
  this[destProp] = text;
};


EX.expectNoAttrs = function (tag) {
  var attrNames = Object.keys(tag.attrs);
  if (attrNames.length === 0) { return; }
  throw tag.err('Unexpected attributes: ' + attrNames.join(' '));
};
















/*scroll*/
