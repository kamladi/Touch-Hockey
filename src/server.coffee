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
GAME = new Game 300, 440, io.sockets
###
Manage socket connections
###
io.sockets.on 'connection', (client) ->
	console.log "New Player: #{client.id} connected"

	if PLAYERCOUNT < 2
		GAME.addPlayer client.id
		PLAYERCOUNT += 1
		if PLAYERCOUNT is 1
			console.log "waiting for player 2..."
		else
			console.log "2 players connected. begin"
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

	#when one player pauses, mark both players as not ready
	#each player should individually confirm ready
	client.on 'pause', ->
		player = GAME.getPlayer(client.id)
		client.broadcast.emit 'pause', player.name
		GAME.pause()
	
	#clients let server know they are ready to resume playing
	client.on 'resume', ->
		GAME.getPlayer(client.id).isReady = true
		#we only resume the game if the other player is also ready
		if GAME.getOtherPlayer(client.id).isReady
			GAME.start()
	
	#when player disconnects
	client.on 'disconnect', () ->
		GAME.pause()
		player = GAME.getPlayer client.id
		if player
			name = player.name
			GAME.removePlayer client.id
			console.log "Player #{client.id} disconnected"
			PLAYERCOUNT -= 1
			console.log "#{PLAYERCOUNT} players remaining"
			
			#let other player know you disconnected
			client.broadcast.emit 'player disconnect', name

port = process.env.PORT or 8080
server.listen port
console.log "listening on port #{port}"
