window.App ||= {}

App.scrollBottom = ->
  setTimeout ->
    height = $('.messages').height()
    $('.messages-wrapper').animate({scrollTop: height})
  , 10

window.hereNow = ->
  PUBNUB_demo.here_now
   channel: 'demo_chat'
   callback: (m) ->
      console.log "Knock knock", m
