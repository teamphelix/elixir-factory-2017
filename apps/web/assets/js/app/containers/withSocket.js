import React, { Component } from 'react'
import { connect } from 'react-redux'

import { socketConnect } from '../redux/actions'

export const withSocket = Wrapped => {
  class WithSocket extends Component {
    componentDidMount() {
      console.log(this.props)
      this.props.connectSocket()
    }

    render() {
      return (
        <div className='wrapper'>
          <Wrapped {...this.props} />
        </div>
      )
    }
  }

  const mapStateToProps = null
  const mapDispatchToProps = dispatch => ({
    connectSocket: () => dispatch(socketConnect())
  })

  return connect(
    mapStateToProps,
    mapDispatchToProps
  )(WithSocket)
}
export default withSocket