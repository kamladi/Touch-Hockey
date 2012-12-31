express = require 'express'
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)
Player = require './Player'
Puck = require './Puck'
Game = require './Game'

app.use express.logger()
app.use express.static(__dirname + '/public')

#Handle main route
app.get '/', (req, res) ->
	res.sendfile(__dirname + '/index.html');

GAME_STARTED = false
PLAYERCOUNT = 0
GAME = new Game 320, 480, io.sockets
###
Manage socket connections
###
io.sockets.on 'connection', (client) ->
	console.log "New Player: #{client.id} connected"

	if PLAYERCOUNT is 0
		GAME.P1 = new Player client.id
		#initial position settings
		GAME.P1.set
			x: GAME.W / 2
			y: GAME.H - GAME.P1.radius
			dx: 0
			dy: 0
			lastUpdate: Date.now()
		PLAYERCOUNT += 1
		console.log "waiting for player 2..."
	else if PLAYERCOUNT is 1
		GAME.P2 = new Player client.id
		#initial position settings
		GAME.P2.updatePos
			x: GAME.W / 2
			y: 0 + GAME.P2.radius
			dx: 0
			dy: 0
			lastUpdate: Date.now()
		PLAYERCOUNT += 1
	else
		console.log "SPECTATOR CONNECTED"
	console.log "#{PLAYERCOUNT} players currently connected"

	#when client assigns themself a nickname
	client.on 'setup', (data) ->
		name = data.name
		
		#assign name to player
		console.log "[#{client.id}] => #{name}"
		client.set 'nickname', name, ->
			#confirm nickname is set
			client.get 'nickname', (err, clientName) ->
				console.log "Client #{client.id} assigned nickname #{clientName}"
			#confirm to client that they're connected	
			client.emit 'ready',
				nickname: name
				id: client.id
				playernum: if client.id is GAME.P1.id then 1 else 2
			#save nickname to player
			GAME.getPlayer(client.id).set name: name
			#2 players, we can start the game
			if PLAYERCOUNT is 2
				console.log "second player connected. Start the game!"
				GAME_STARTED = true
				GAME.start()
				io.sockets.emit 'start game'

	#receives player input (touch/mouse movement)
	#saves new player coords, then sends coords to other player
	client.on 'player move', (data) ->
		player = GAME.getPlayer client.id
		if player is GAME.P2
			player.updatePos GAME.reverseCoords data
		else
			player.updatePos data
		#send update to other player
		client.broadcast.emit 'player move', data
	
	#when player disconnects
	client.on 'disconnect', () ->
		player = GAME.getPlayer client.id
		if player
			player = null
			console.log "Player #{client.id} disconnected"
			PLAYERCOUNT -= 1
			console.log "#{PLAYERCOUNT} players remaining"
			if PLAYERCOUNT is 0
				GAME.pause()

port = process.env.PORT or 8080
server.listen port
console.log "listening on port #{port}"
