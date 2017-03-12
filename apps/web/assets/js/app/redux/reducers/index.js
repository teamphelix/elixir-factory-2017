import { combineReducers } from 'redux'

import * as questions from './questions'
import * as socket from './socket'

export const initialState = {
  questions: questions.initialState,
  socket: socket.initialState,
}

export const getRootReducer = () => {
  return combineReducers({
    questions: questions.reducer,
    socket: socket.reducer,
  })
}