$ ->
  PUBNUB_demo.subscribe
    channel: 'demo_chat'
    message: (m) ->
      console.log m
