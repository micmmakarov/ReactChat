window.App ||= {}

App.scrollBottom = ->
  setTimeout ->
    height = $('.messages').height()
    $('.messages-wrapper').animate({scrollTop: height})
  , 10

Message = React.createClass
  propTypes:
    author: React.PropTypes.string.isRequired
    text: React.PropTypes.string.isRequired
    me: React.PropTypes.bool
    sent: React.PropTypes.bool

  render: ->
    classes = 'unsent' if @props.me && !@props.sent
    `<div className={classes}>
    <strong><span>{this.props.author}</span><span>{this.props.sent}</span></strong>:
    <span>{this.props.text}</span>
    </div>
    `

MessageForm = React.createClass
  setAuthor: ->
    userActions.setAuthor(React.findDOMNode(this).elements.author.value)

  onChangeText: (e) ->
    @setAuthor()
    userActions.typing()

  onSubmit: (e) ->
    clearTimeout App.myLastTypeTimer
    e.preventDefault()
    form = e.target

    data =
      text: form.elements.text.value
      author: form.elements.author.value

    # trigger the action
    userActions.sendMessage data

    # clear out the input
    form.elements.text.value = ''

  render: ->
    `<form onSubmit={this.onSubmit}>
      Author:<input name="author" onChange={this.onChangeAuthor} />
      <br />
      Message:<input name="text" onChange={this.onChangeText} />
      <button>Send message</button>
    </form>`

MessageList = React.createClass
  propTypes:
    messages: React.PropTypes.array.isRequired

  componentDidUpdate: ->
    App.scrollBottom()

  render: ->
    list = @props.messages.map (message, i) ->
      message.id = "new-#{i}" if typeof message.id == 'undefined'
      `<Message key={message.id} text={message.text} author={message.author} me={message.me} sent={message.sent} />`

    `<div className="messages-wrapper">
      <div className="messages">
        {list}
      </div>
    </div>`

TypingIndicator = React.createClass
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

window.Chat = React.createClass
  mixins: [
    Reflux.connect(messageStore, 'messages')
    Reflux.connect(presenceStore, 'presence')
  ]

  render: ->
    `<div>
      <MessageList messages={this.state.messages.messages} />
      <TypingIndicator typingUsers={Object.keys(this.state.presence.typing_users)} />
      <MessageForm />
    </div>`
