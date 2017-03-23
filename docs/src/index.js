require('./remark-latest.min')
require('./index.css')
require('./timeline.css')

const app = document.createElement('main');
document.body.appendChild(app)

// TODO:
const appendGenStage = () => {
  const genstage_html = '<ul class="genstage"><li class="stage active">Web</li><li class="stage">DB</li><li class="stage">Twitter</li></ul>'

  const div = document.createElement('div')
  div.className = 'genstage_container'
  div.innerHTML = genstage_html
  // const slide = document.querySelector('.remark-visible')
  document.body.appendChild(div)
  // console.log(slide)
  // console.log(slides)
  // slides.forEach(ele => ele.appendChild(div))
}

let show;
const createSlideshow = (md) => {
  show = remark.create({
    source: md,
    highlightStyle: 'monokai',
    highlightLines: true,
    highlightLanguage: 'elixir',
    ratio: "16:9"
  })
  // show.on('showSlide', (slide) => {
  //   document
  //     .querySelector('.remark-slide-container')
  //     .classList = slide.properties.class
  // })
}

if (module.hot) {
  module.hot.accept('./elixabot.md', () => {
    const nextMd = require('./elixabot.md')
    createSlideshow(nextMd)
  })
}

const md = require('./elixabot.md')
createSlideshow(md)
