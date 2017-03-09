#!/usr/bin/env node
const express = require('express')
const webpack = require('webpack')
const makeConfig = require('./webpack.config')
const config = makeConfig(process.env.MIX_ENV)

const compiler = webpack(config)
const app = express()
app.use(require('cors')())

app.use(require('webpack-dev-middleware')(compiler, {
  noInfo: true,
  publicPath: config.output.publicPath
}))

app.use(require('webpack-hot-middleware')(compiler, {
  log: console.log
}))

app.listen(8080, 'localhost', function (err) {
  if (err) return console.error(err)
  console.log('dev server running on localhost:8080')
})

// Exit on end of STDIN
process.stdin.resume()
process.stdin.on('end', function () {
  process.exit(0)
})