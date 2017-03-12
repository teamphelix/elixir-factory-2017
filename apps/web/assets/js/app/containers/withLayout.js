import React from 'react'

export const withLayout = Wrapped => props => (
  <div className='wrapper'>
    <Wrapped {...props} />
  </div>
)

export default withLayout