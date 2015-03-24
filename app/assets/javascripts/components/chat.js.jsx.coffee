@Chat = React.createClass
  mixins: [
    Reflux.connect(messageStore, 'messages')
    Reflux.connect(presenceStore, 'typingUsers')
  ]

  render: ->
    `<div>
      <MessageList messages={this.state.messages.messages} />
      <TypingIndicator typingUsers={Object.keys(this.state.typingUsers)} />
      <MessageForm />
    </div>`
