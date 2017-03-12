import { Provider } from 'react-redux'

import { createStore, applyMiddleware, compose } from 'redux'
import { getRootReducer, initialState } from './reducers'
import thunkMiddleware from 'redux-thunk'

export const configureStore = (userInitialState = initialState) => {
  let store;

  const middleware = [
    thunkMiddleware
  ]

  const enhancers = global.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose

  store = createStore(
    getRootReducer(),
    initialState,
    enhancers(applyMiddleware(...middleware)),
  )

  if (module.hot) {
    module.hot.accept('./reducers', () => {
      const nextGetRootReducer = require('./reducers/index').getRootReducer
      const nextRootReducer = nextGetRootReducer()
      store.replaceReducer(nextRootReducer)
    })
  }

  return store
}

export default configureStore