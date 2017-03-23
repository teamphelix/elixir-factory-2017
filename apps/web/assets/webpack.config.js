/*
 * Modules
 **/
const path = require("path");
const webpack = require("webpack");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const autoprefixer = require("autoprefixer");
// const HtmlPlugin = require('html-webpack-plugin');

/*
 * Configuration
 **/
module.exports = (env='dev') => {
  const prod = env === 'prod'
  const publicPath = 'http://localhost:8080/'
  const hot = 'webpack-hot-middleware/client?path=' +
    publicPath + '__webpack_hmr'

  const isDev = !(env && !prod);
  const devtool = isDev ? "cheap-module-eval-source-map" : "source-map";
  const entry = {
    app: [
      "js/app.js",
      "css/app.css"
    ]
  }
  if (isDev) {
    entry.app.unshift(hot)
  }

  let plugins = [
    new CopyWebpackPlugin([{
      from: "static"
    }]),
    new webpack.optimize.OccurrenceOrderPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
    new webpack.DefinePlugin({
      __PROD: prod,
      __DEV: env === 'dev'
    })
  ]

  if (isDev) {
    plugins.push(new webpack.HotModuleReplacementPlugin())
  } else {
    plugins = plugins.concat([
      new ExtractTextPlugin({
        filename: "css/[name].css",
        allChunks: true
      }),

      new webpack.optimize.UglifyJsPlugin({ 
        sourceMap: true,
        beautify: false,
        comments: false,
        extractComments: false,
        compress: {
          warnings: false,
          drop_console: true
        },
        mangle: {
          except: ['$'],
          screw_ie8 : true,
          keep_fnames: true,
        }
      })
    ])
  }

  return {
    devtool,
    context: __dirname,
    entry,

    output: {
      path: path.resolve(__dirname, "../priv/static"),
      filename: 'js/[name].js',
      publicPath: isDev ? 'http://localhost:8080/' : '/'
    },

    module: {
      rules: [
        {
          test: /\.(jsx?)$/,
          exclude: /node_modules/,
          loader: "babel-loader",
          options: {
            presets: [
              ['es2015', {modules: false}],
              'stage-2'
            ],
            plugins: [
              "transform-class-properties"
            ]
          }
        },

        {
          test: /\.(gif|png|jpe?g|svg)$/i,
          exclude: /node_modules/,
          loaders: [
            'file-loader',
            {
              loader: 'image-webpack-loader',
              query: {
                progressive: true,
                optimizationLevel: 7,
                interlaced: false,
                pngquant: {
                  quality: '65-90',
                  speed: 4
                }
              }
            }
          ]
        },

        {
          test: /\.(ttf|woff2?|eot|svg)$/,
          exclude: /node_modules/,
          query: { name: "fonts/[hash].[ext]" },
          loader: "file-loader",
        },

        {
          test: /\.(css|styl)$/,
          exclude: /node_modules/,
          use: isDev ? [
            "style-loader",
            "css-loader",
            "postcss-loader",
          ] : ExtractTextPlugin.extract({
            fallback: "style-loader",
            use: ["css-loader", "postcss-loader"]
          })
        }
      ]
    },

    resolve: {
      modules: ["node_modules", __dirname],
      extensions: [".js", ".json", ".css"]
    },

    plugins
  };
};