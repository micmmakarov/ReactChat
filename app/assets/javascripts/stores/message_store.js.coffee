window.messageStore = Reflux.createStore
  init: ->
    @listenToMany(userActions)
    @state = @getInitialState()
    @fetchMessages()

  getInitialState: ->
    @state =
      messages: []
      loaded: false

  fetchMessages: ->
    $.ajax
      url: "/messages"
      dataType: 'json'
      method: 'GET'
    .done (data) =>
      @state.messages = data
      @state.loaded = true
      @trigger @state

  onSendMessage: (message) ->
    App.authorName = message.author
    message.sent = false
    @state.messages.push message
    @trigger @state
    $.ajax
      url: "/messages"
      dataType: 'json'
      method: 'POST'
      data: {message: message}
    .done (data) =>
      message.sent = true
      @trigger @state
