window.presenceStore = Reflux.createStore
  init: ->
    @state = @getInitialState()
    @listenToMany userActions
    @listenTo remoteActions.presence, 'onRemotePresence'

  getInitialState: ->
    @state = {
      typing_users: {}
    }

  typingChange: (user) ->
    @state.typing_users[user.name] = Date.now()
    @trigger @state
    # Just in case user machine will restart
    # 5 seconds timeout
    if @refreshTimer
      clearTimeout @refreshTimer
    @refreshTimer = setTimeout =>
      @state.typing_users = (user for user in @state.typing_users when Date.now() - value > 5000)
      typing_users_copy = @state.typing_users[..]
      $.each typing_users_copy, (key, value) ->
        if Date.now() - value > 5000
          delete @state.typing_users[key]
      @trigger @state
    , 5000

  onRemotePresence: (m) ->
    # console.log "STATE", m
    if m.action == "state-change" && m.uuid != userID
      name = m.data.name
      action = m.data.action
      if action == "typing"
        @typingChange
          name: name
          action: action
          uuid: m.uuid
      #if action == "stopped-typing"
      #  App.typingChange
      #    name: name
      #    action: action
      #    uuid: m.uuid

  onSetAuthor: (author) ->
    @author = author

  onTyping: ->
    # tell pubnub
    PUBNUB_demo.state
      channel: "demo_chat",
      uuid: userID,
      state:
        name: @author
        typing: true
        action: 'typing'

    # set timer to trigger 'stopped-typing'
    if @myLastTypeTimer
      clearTimeout @myLastTypeTimer
    @myLastTypeTimer = setTimeout ->
      userActions.stopTyping()
    , 3000

  onStopTyping: ->
    PUBNUB_demo.state
      channel: "demo_chat",
      uuid: userID,
      state:
        name: name
        typing: true
        action: 'stopped-typing'