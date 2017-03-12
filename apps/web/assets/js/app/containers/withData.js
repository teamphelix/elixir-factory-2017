import React from 'react'
import { Provider } from 'react-redux'
import configureStore from '../redux/configureStore'

const store = configureStore({})
export const withData = Wrapped => props => {
  return (
    <Provider store={store}>
      <Wrapped {...props} />
    </Provider>
  )
}

export default withData