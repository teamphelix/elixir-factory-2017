import * as types from './actionTypes'

export const socketConnect = () => dispatch => {
  dispatch({
    type: types.SOCKET_CONNECT
  });

  const socket = new WebSocket(`ws://localhost:4001/ws`)
  socket.onopen = () => {
    socket.send('ping')
  }

  socket.addEventListener('message', ({ data }) => {
    try {
      if (data === "pong") {
        dispatch({type: types.PONG})
      } else {
        dispatch({
          type: types.RECEIVED_QUESTIONS,
          payload: JSON.parse(data)
        })
      }
    } catch (e) {
      console.log('error ->', e, data);
    }
  })

  dispatch({
    type: types.SOCKET_CONNECTED,
    socket,
  })
}