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
  getInitialState: ->
    {text: '', author: ''}
  onChange: (fieldName, e) ->
    data = {}
    data[fieldName] = e.target.value
    @setState data
  onSubmit: ->
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


