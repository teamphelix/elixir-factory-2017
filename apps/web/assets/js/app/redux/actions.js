import * as types from './actionTypes'

export const socketConnect = () => dispatch => {
  dispatch({
    type: types.SOCKET_CONNECT
  });

  const socket = new WebSocket(`ws://localhost:4001/ws`)
  socket.onopen = () => {
    socket.send('ping')
  }

  socket.addEventListener('message', (data) => {
    console.log('socket connected and got pong', data)
  })

  dispatch({
    type: types.SOCKET_CONNECTED,
    socket,
  })
}