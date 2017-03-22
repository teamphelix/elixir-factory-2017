require('./remark-latest.min')
require('./index.css')

import React from 'react'
import ReactDOM from 'react-dom'
const app = document.createElement('main');
document.body.appendChild(app)

// import {
//   Markdown,
// } from 'spectacle';

const md = require('./elixabot.md')

const show = remark.create({
  source: md,
  highlightStyle: 'monokai',
  highlightLines: true,
  highlightLanguage: 'elixir'
})

// import { join } from 'path'
// import { readFileSync } from 'fs'
// import { createServer } from 'http';
// import md2remark from 'md2remark';

// const md = require('./elixabot.md')

// const getMarkdown = (file=join(__dirname, '..', 'elixabot.md')) => {

//   const contents = readFileSync(__dirname + "/elixabot.md");
//   const markdown = contents.toString();

//   return md2remark(markdown)
// }

// const port = process.env.PORT || 3000;

// createServer(async (req, res) => {
//   const md = await getMarkdown()
//   console.log('Request!', md);
//   res.end(md);
// })
// .listen(port, () => console.log(`Server running on port ${port}`));