/*jslint indent: 2, maxlen: 80, node: true */
/* -*- tab-width: 2 -*- */
'use strict';

var fs = require('fs'),
  xmlJs = require('xml-js');

// Could we actually use jQuery to parse its own docs?
// Not in node: "Error: jQuery requires a window with a document"

fs.readFile(process.argv[2] || 0, 'utf-8', function (readErr, xml) {
  if (readErr) { return console.error(readErr); }
  var data = xmlJs.xml2js(xml, { compact: false });
  data = data.x || data.elements[0].elements[7].elements;
  if (data instanceof Array) {
    data = data.map(function (e, i) { return Object.assign({ '#': i }, e); });
  }
  console.dir(data);
});
