window.userActions = Reflux.createActions [
  'sendMessage',
  'typing',
  'stopTyping',
  'setAuthor',
]

window.remoteActions = Reflux.createActions [
  'message',
  'presence',
]
