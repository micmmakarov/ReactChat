$ ->
  PUBNUB_demo.subscribe
    channel: 'demo_chat'
    message: (m) ->
      message = JSON.parse(m)
      unless App.authorName == message.author
        App.addMessage message
    state:
      watching: true
    presence: (m) ->
      console.log "STATE", m
      if m.action == "state-change" && m.uuid != userID
        name = m.data.name
        action = m.data.action
        if action == "typing"
          App.typingChange
            name: name
            action: action
            uuid: m.uuid



window.hereNow = ->
  PUBNUB_demo.here_now
   channel: 'demo_chat'
   callback: (m) ->
      console.log "Knock knock", m