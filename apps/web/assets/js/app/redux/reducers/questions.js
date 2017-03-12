import * as types from '../actionTypes'

const questions = [
  { id: 1, text: 'What is your favorite color?', votes: 0 },
]

export const initialState = {
  list: questions,
}

export const reducer = (state = initialState, action) => {

  switch (action.type) {
    default:
      return state
  }
}