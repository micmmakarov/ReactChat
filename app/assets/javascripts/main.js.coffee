window.App ||= {}

App.scrollBottom = ->
  height = $('.messages').height()
  $('.messages-wrapper').animate({scrollTop: height})

window.hereNow = ->
  PUBNUB_demo.here_now
   channel: 'demo_chat'
   callback: (m) ->
      console.log "Knock knock", m
