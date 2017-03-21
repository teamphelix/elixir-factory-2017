import React from 'react'

import QuestionsList from '../components/questions/questions_list'

export const Home = (props) => {
  return (
    <div className='home'>
      <header>Questions</header>
      <QuestionsList
        {...props}
      />
    </div>
  )
}

export default Home