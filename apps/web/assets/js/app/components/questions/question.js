import React from 'react'

export const Question = ({question, onVote}) => {
  return (
    <div
      onClick={onVote.bind(this, question)}
      className='question'>
      {question.votes} {question.text}
    </div>
  )
}

export default Question