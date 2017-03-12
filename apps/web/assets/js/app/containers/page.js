import { compose } from 'redux'

import withData from './withData'
import withLayout from './withLayout'
import withSocket from './withSocket'

export const pageWithoutLayout = compose(
  withData,
  withSocket,
)

export const pageWithLayout = compose(
  pageWithoutLayout,
  withLayout
)

export default pageWithLayout