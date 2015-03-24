@MessageForm = React.createClass
  setAuthor: ->
    userActions.setAuthor(React.findDOMNode(this).elements.author.value)

  onChangeText: (e) ->
    @setAuthor()
    userActions.typing()

  onSubmit: (e) ->
    userActions.stopTyping()
    e.preventDefault()
    form = e.target

    data =
      text: form.elements.text.value
      author: form.elements.author.value

    # trigger the action
    userActions.sendMessage data

    # clear out the input
    form.elements.text.value = ''

  render: ->
    `<form onSubmit={this.onSubmit}>
      Author:<input name="author" onChange={this.onChangeAuthor} />
      <br />
      Message:<input name="text" onChange={this.onChangeText} />
      <button>Send message</button>
    </form>`
