import React from 'react'
import {
  Switch, 
  BrowserRouter as Router,
  Route
} from 'react-router-dom'

import Page from './containers/page'

import Home from './views/Home'

export const Routes = (props) => (
  <Router>
    <Switch className='routes'>
      <Route
        render={(renderProps) => (
          <Home {...renderProps} {...props} />
        )} />
    </Switch>
  </Router>
)

export default Page(Routes)
