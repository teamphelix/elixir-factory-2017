import React from 'react'
import { render } from 'react-dom'
import Routes from './app/routes'

const renderApp = (C) => {
  const MOUNT = document.querySelector('#root')
  render((<C />), MOUNT)
}

renderApp(Routes)

if (module.hot) {
  module.hot.accept('./app/routes', () => {
    const nextRoutes = require('./app/routes').default
    renderApp(nextRoutes)
  })
}