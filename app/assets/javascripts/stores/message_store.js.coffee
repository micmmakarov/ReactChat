window.messageStore = Reflux.createStore
  init: ->
    @listenToMany(userActions)
    @listenTo remoteActions.message, 'onReceiveMessage'
    @state = @getInitialState()
    @fetchMessages()
    @listenForMessages()

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

  listenForMessages: ->
    # TODO: Maybe this belongs somewhere else, since it deals with presence also
    PUBNUB_demo.subscribe
      channel: 'demo_chat'
      message: (m) ->
        remoteActions.message(JSON.parse(m))
      state:
        watching: true
      presence: (m) ->
        remoteActions.presence(m)

  onReceiveMessage: (message) ->
    unless @authorName == message.author
      @state.messages.push message
      @trigger @state

  onSendMessage: (message) ->
    @authorName = message.author
    message.me = true
    message.sent = false
    @state.messages.push message
    @trigger @state

    # actually send the message
    $.ajax
      url: "/messages"
      dataType: 'json'
      method: 'POST'
      data: {message: message}
    .done (data) =>
      message.sent = true
      message.id = data.id
      @trigger @state
