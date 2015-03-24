@TypingIndicator = React.createClass
  propTypes:
    typingUsers: React.PropTypes.array.isRequired

  render: ->
    if @props.typingUsers.length > 1
      typing = @props.typingUsers.join(", ") + " are typing at the moment"
    else if @props.typingUsers.length > 0
      typing = @props.typingUsers[0] + " is typing at the moment"

    `<div>
      {typing}
    </div>`
