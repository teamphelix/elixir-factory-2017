module.exports = neutrino => {
  neutrino.config.module
    .rule('compile')
    .test(/\.md$/)
    .loader('markdown', 'raw-loader')

  neutrino.config.module
    .rule('css')
    .test(/\.css$/)
    .loader('postcss', 'postcss-loader')

  console.log(neutrino.config.module.rule('css'));
}