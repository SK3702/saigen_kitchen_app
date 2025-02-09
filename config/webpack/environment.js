const { environment } = require('@rails/webpacker')

const sassLoader = environment.loaders.get('sass')
const sassLoaderConfig = sassLoader.use.find(item => item.loader === 'sass-loader')

sassLoaderConfig.options = Object.assign({}, sassLoaderConfig.options, {
  implementation: require('sass'),
  sassOptions: {
    outputStyle: 'expanded'
  }
})

module.exports = environment
