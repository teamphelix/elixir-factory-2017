import React, { Component } from 'react'
import { connect } from 'react-redux'
import Question from './question'

import './questions.css'

export class QuestionList extends Component {

  handleVote = e => {
    console.log('voting...', e)
  }

  render() {
    const { questions } = this.props
    return (
      <div className='questions_list'>
        {questions.map(question => (
          <Question
            key={question.id}
            question={question}
            onVote={this.handleVote}
            className='question' />
        ))}
      </div>
    )
  }
}

const mapStateToProps = state => {
  return {
    questions: state.questions.list,
  }
}
const mapDispatchToProps = null

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(QuestionList)