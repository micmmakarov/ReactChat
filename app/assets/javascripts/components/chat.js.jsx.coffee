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
    sent: React.PropTypes.bool

  render: ->
    `<div>
    <strong><span>{this.props.author}</span><span>{this.props.sent}</span></strong>:
    <span>{this.props.text}</span>
    </div>
    `

MessageForm = React.createClass
  typingChange: (user) ->
    console.log "stateChange"
    typing_users = @state.typing_users
    typing_users[user.name] = Date.now()
    @setState typing_users: typing_users
    _this = @
    # Just in case user machine will restart
    # 5 seconds timeout
    if App.refreshTimer
      clearTimeout App.refreshTimer
    App.refreshTimer = setTimeout ->
      typing_users = _this.state.typing_users
      typing_users_copy = (->
        _this.state.typing_users
      )()
      $.each typing_users_copy, (key, value) ->
        if Date.now() - value > 5000
          delete typing_users[key]
      _this.setState typing_users: typing_users
      _this.setTypingUsers()
    , 5000

    @setTypingUsers()

  setTypingUsers: ->
    if Object.keys(@state.typing_users).length > 0
      typing = Object.keys(@state.typing_users).join(", ") + " are typing at the moment"
    else
      typing = ''
    @setState whosTyping: typing
  getInitialState: ->
    App.typingChange = @typingChange
    {text: '', author: '', whosTyping: '', typing_users: {}}
  onChange: (fieldName, e) ->
    data = {}
    data[fieldName] = e.target.value
    @setState data
    if fieldName == "text"
      name = @state.author
      PUBNUB_demo.state
        channel: "demo_chat",
        uuid: userID,
        state:
          name: name
          typing: true
          action: 'typing'
      App.myLastType = Date.now()
      if App.myLastTypeTimer
        clearTimeout App.myLastTypeTimer
      App.myLastTypeTimer = setTimeout ->
        if Date.now() - App.myLastType > 3000
          PUBNUB_demo.state
            channel: "demo_chat",
            uuid: userID,
            state:
              name: name
              typing: true
              action: 'stopped-typing'
      , 3000

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
      <div>
        {this.state.whosTyping}
      </div>
      Author:<input name="author" onChange={this.onChange.bind(this, 'author')} />
      <br />
      Message:<input name="text" onChange={this.onChange.bind(this, 'text')} />
      <button>Send message</button>
    </form>`

MessageList = React.createClass
  propTypes:
    messages: React.PropTypes.array.isRequired

  render: ->
    list = @props.messages.map (message) ->
      `<Message text={message.text} author={message.author} sent={message.sent}/>`

    `<div className="messages-wrapper">
      <div className="messages">
        {list}
      </div>
    </div>`

window.Chat = React.createClass
  mixins: [ Reflux.connect(messageStore) ]

  render: ->
    `<div>
      <MessageList messages={this.state.messages} />
      <MessageForm />
    </div>`
