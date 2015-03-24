window.hereNow = ->
  PUBNUB_demo.here_now
   channel: 'demo_chat'
   callback: (m) ->
      console.log "Knock knock", m
