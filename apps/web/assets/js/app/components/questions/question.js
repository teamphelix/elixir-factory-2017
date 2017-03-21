import React from 'react'

export const Question = ({question, onVote}) => {
  return (
    <div
      onClick={onVote.bind(this, question)}
      className='question'>
      <span className="votes">
        {question.votes}
      </span>
      <span className="text">
        {question.text}
      </span>
    </div>
  )
}

export default Question