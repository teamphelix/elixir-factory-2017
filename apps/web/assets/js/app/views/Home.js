import React from 'react'

import QuestionsList from '../components/questions/questions_list'

export const Home = (props) => {
  return (
    <div className='home'>
      <QuestionsList
        {...props}
      />
    </div>
  )
}

export default Home