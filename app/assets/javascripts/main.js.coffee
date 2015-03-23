$ ->
  PUBNUB_demo.subscribe
    channel: 'demo_chat'
    message: (m) ->
      message = JSON.parse(m)
      unless App.authorName == message.author
        App.addMessage message
