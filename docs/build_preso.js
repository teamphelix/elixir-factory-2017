#!/usr/bin/env node

const remark = require('remark').default
const md2remark = require('md2remark');
const fs = require('fs')

const contents = fs.readFileSync(__dirname + "/elixabot.md");
const markdown = contents.toString();

const slideshow = remark.create();

md2remark(markdown).then(function(slidesMarkdown) {
  console.log(slidesMarkdown);
});