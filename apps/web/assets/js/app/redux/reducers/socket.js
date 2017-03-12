import * as types from '../actionTypes'

export const initialState = {
  connected: false,
  socket: null
}

export const reducer = (state = initialState, action) => {

  switch (action.type) {
    case types.SOCKET_CONNECT:
      return {
        ...state,
        connected: false,
      }
    case types.SOCKET_CONNECTED:
      return {
        ...state,
        connected: true,
        socket: action.payload,
      }
    default:
      return state
  }
}