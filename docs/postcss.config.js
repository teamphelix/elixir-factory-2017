module.exports = ctx => ({
  plugins: [
    require('postcss-import')(),
    require('postcss-inherit')(),
    require('precss')(),
    require('autoprefixer')({
      "browses": "> 5%",
    })
  ]
})
