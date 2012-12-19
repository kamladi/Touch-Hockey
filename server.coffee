express = require 'express'
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

app.use express.logger()
app.use express.static(__dirname + '/public')

port = process.env.PORT || 3000
server.listen(port)
console.log "listening on port #{port}"

#Handle main route
app.get '/', (req, res) ->
	res.sendfile(__dirname + '/index.html');

PLAYERS = []
GAME_STARTED = false

#manage socket connections
io.sockets.on 'connection', (client) ->
	PLAYERS.push(client)
	console.log "New Player: #{client.id} connected"
	console.log "#{PLAYERS.length} players currently connected"

	#when client assigns themself a nickname
	client.on 'set nickname', (name) ->
		console.log "[#{client.id}] => #{name}"
		client.set 'nickname', name, ->
			#confirm nickname is set
			client.get 'nickname', (err, clientName) ->
				console.log "Client #{client.id} assigned nickname #{clientName}"
				client.emit('ready', nickname: clientName)
		if PLAYERS.length == 2
			GAME_STARTED = true
			PLAYERS[0].emit 'start game'

	#respond to changes in player movement
	#send move coords to other player
	client.on 'player move', (data) ->
		client.broadcast.emit 'player move', data

	#when player disconnects
	client.on 'disconnect', () ->
		#remove player from PLAYERS
		console.log "Player #{client.id} disconnected"
		index = PLAYERS.indexOf client
		if index > -1
			PLAYERS.splice index, 1