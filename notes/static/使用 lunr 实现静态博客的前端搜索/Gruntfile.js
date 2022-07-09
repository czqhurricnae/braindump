var fs = require("fs");
var matter = require("gray-matter");
var S = require("string");
var conzole = require("conzole");
var lunr = require("./static/vendor/js/lunr.js");
var jsdom = require("jsdom");
var nodejieba = require("nodejieba");
const {JSDOM} = jsdom;
const {document} = (new JSDOM("<!doctype html><html><body></body></html>")).window;
const {Index} = require("flexsearch");
global.document = document;
const window = document.defaultView;
var $ = require("jquery")(window);
require("./static/vendor/js/lunr.stemmer.support")(lunr);
require("./static/vendor/js/lunr.zh")(lunr);


var CONTENT_PATH_PREFIX = ".";


module.exports = function(grunt) {

  grunt.registerTask("search-index", function() {

    grunt.log.ok("Building pages index.");

    var doIndexPages = function() {
      var pageIndexes = [];
      grunt.file.recurse(CONTENT_PATH_PREFIX, function(abspath, rootdir, subdir, filename) {
        grunt.verbose.writeln("Page file: ", abspath);
        data = processFile(abspath, filename);
        if (data !== undefined) {
          pageIndexes.push(data);
        }
      });

      return pageIndexes;
    };

    var processFile = function(abspath, filename) {
      var pageIndex;

      if (S(filename).endsWith(".html")) {
        pageIndex = processHTMLFile(abspath, filename);
      }
      else if (S(filename).endsWith(".md")) {
        pageIndex = processMDFile(abspath, filename);
        return;
      }

      return pageIndex;
    };

    var processHTMLFile = function(abspath, filename) {
      var content = grunt.file.read(abspath, filename);
      var pageName = S(filename).chompRight(".html").s;
      var href = S(abspath).chompLeft(CONTENT_PATH_PREFIX).s;

      if (href == "index.html") {
        return;
      }

      if (href.startsWith("node_modules")) {
        return;
      }

      return {
        title: pageName,
        href: href,
        content: S(content).trim().stripTags().s
      };
    };

    var processMDFile = function(abspath, filename) {
      var content = matter(grunt.file.read(abspath, filename));
      if (content.data.draft) {
        conzole.log("Draft; do not index", abspath);
        return;
      }

      return {
        title: content.data.title,
        categories: content.data.categories,
        href: content.data.slug,
        content: S(content.content).trim().stripTags().stripPunctuation().s
      };
    };

    grunt.file.write("./static/vendor/json/index.json", JSON.stringify(doIndexPages()));
    grunt.log.ok("Indexes built.");
  });

  grunt.registerTask("pre-segment", function() {
    grunt.log.ok("Pre-building segmentations.");

    var data = grunt.file.readJSON("./static/vendor/json/index.json");

    var segmentations = lunr(function () {
      this.use(lunr.zh);
      this.field("title");
      this.field("content");
      this.ref("href");

      for (var i = 0; i < data.length; ++i) {
        (this.add(data[i]));
      }
    });

    grunt.file.write("./static/vendor/json/jieba.json", JSON.stringify(segmentations));
    grunt.log.ok("Segmentations built.");
  });
};
