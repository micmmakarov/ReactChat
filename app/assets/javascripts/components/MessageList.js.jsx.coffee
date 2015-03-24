@MessageList = React.createClass
  propTypes:
    messages: React.PropTypes.array.isRequired

  componentDidUpdate: ->
    App.scrollBottom()

  render: ->
    list = @props.messages.map (message, i) ->
      message.id = "new-#{i}" if typeof message.id == 'undefined'
      `<Message key={message.id} text={message.text} author={message.author} me={message.me} sent={message.sent} />`

    `<div className="messages-wrapper">
      <div className="messages">
        {list}
      </div>
    </div>`
