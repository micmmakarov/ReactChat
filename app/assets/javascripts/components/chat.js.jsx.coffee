window.App ||= {}

App.scrollBottom = ->
  setTimeout ->
    height = $('.messages').height()
    $('.messages-wrapper').animate({scrollTop: height})
  , 10

window.Message = React.createClass
  getInitialState: ->
    {text: '', author: 'noname', created_at: '', failed: false}
  render: ->
    `<div>
    <strong><span>{this.props.author}</span><span>{this.props.sent}</span></strong>:
    <span>{this.props.text}</span>
    </div>
    `

window.MessageForm = React.createClass
  typingChange: (user) ->
    console.log "stateChange"
    typing_users = @state.typing_users
    typing_users[user.name] = Date.now()
    @setState typing_users: typing_users
    _this = @
    
    # Just in case user machine will restart
    # 
    if App.refreshTimer
      clearTimeout App.refreshTimer
    App.refreshTimer = setTimeout ->
      typing_users = _this.state.typing_users
      typing_users_copy = (->
        _this.state.typing_users
      )()
      $.each typing_users_copy, (key, value) ->
        if Date.now() - value > 10000
          delete typing_users[key]
      _this.setState typing_users: typing_users
      _this.setTypingUsers()
    , 10000

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

  onSubmit: ->
    clearTimeout App.myLastTypeTimer
    data = (=>
      {
        text: @state.text
        author: @state.author
      }
    )()
    App.authorName = data.author
    message = App.addMessage data
    @setState text: ''
    $.ajax
      url: "/messages"
      dataType: 'json'
      method: 'POST'
      data: {message: data}
    .done (data) =>
      message.setProps sent: true

  render: ->
    `<div>
      <div>
        {this.state.whosTyping}
      </div>
      Author:<input onChange={this.onChange.bind(this, 'author')} />
      <br />
      Message:<input value={this.state.text} onChange={this.onChange.bind(this, 'text')} />
      <button onClick={this.onSubmit}>Send message</button>
    </div>`

window.Chat = React.createClass
  fetchMessages: ->
    $.ajax
      url: "/messages"
      dataType: 'json'
      method: 'GET'
    .done (data) =>
      @setState messages: data
      @setState loaded: true
      App.scrollBottom()

  addMessage: (message) ->
    newMessages = @state.messages.concat [message]
    @setState messages: newMessages
    App.scrollBottom()
    @

  getInitialState: ->
    App.addMessage = @addMessage
    @fetchMessages()
    {loaded: false, messages: [], currentMessage: ''}

  render: ->
    messageElement = (message) ->
      `<Message text={message.text} author={message.author} sent={message.sent}/>`

    `<div>
      <div className="messages-wrapper">
        <div className="messages">
          {this.state.messages.map(messageElement)}
        </div>
      </div>
      <MessageForm />
    </div>`


