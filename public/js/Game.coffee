class Game
	constructor: ->
		@canvas = document.getElementById 'game'
		@$canvas = $(@canvas)
		@ctx = @canvas.getContext '2d'
		@W = @canvas.width
		@H = @canvas.height

		#variables for displaying scorees on DOM
		scoreDiv = document.getElementById 'score'
		names = scoreDiv.getElementsByClassName 'name'
		scores = scoreDiv.getElementsByClassName 'score'
		@scoreObj = 
			P1:
				name: names[0]
				score: scores[0]
			P2:
				name: names[1]
				score: scores[1]

		#init message dialog box
		@Dialog = new Dialog()

		#connect to socket server
		@initSockets()

		#init puck, 2 players
		#p1 is always the current client
		#p2 is the OTHER player
		
		p1_radius = 30
		@P1 = new Player @W/2, @H - p1_radius, p1_radius, 'red'

		@initEventHandlers()

	initSockets: ->
		@socket = io.connect window.location.hostname 		
		@socket.on 'connect', @setup
		@socket.on 'ready', @onReady
		@socket.on 'start game', @onStart
		@socket.on 'puck move', @onPuckMove
		@socket.on 'player move', @onPlayerMove
		@socket.on 'collision', ->
			console.log "COLLISION"
		@socket.on 'goal', @onGoal
		@socket.on 'pause', @onPause
		@socket.on 'player disconnect', (name) =>
			alert "#{name} disconnected!"
			@P2.color = "gray"
	initEventHandlers: ->
		###
		@$canvas.on 'mousemove', @onMouseMove
		@$canvas.on 'touchmove', @onTouchMove
		###
		#using custom jquery plugin for mouse/touch move events
		@$canvas.on 'move', @onMove
		$(document).keydown (e) =>
			#we are only looking for 'escape' or 'space' key
			if e.keyCode is 27 or e.keyCode is 32
				@socket.emit 'pause'
				msg = "PAUSED. Click to continue"
				@Dialog.show msg, =>
					@socket.emit 'resume'
			else
				return false
	setup: () =>
		console.log "connected to server"
		#get player nickname
		name = prompt("Welcome! Enter a nickname")
		if name is ""
			console.log "no name entered"
			return false
		console.log "entered " + name
		setupInfo = 
			name: name
			width: document.body.clientWidth
			height: document.body.clientHeight
		@socket.emit 'setup', setupInfo

	#server will send misc. configs with this event
	#playernum determines if this client is player 1/2
	onReady: (data) =>
		console.log "connected as #{data.nickname}"
		@name = data.name
		@scoreObj.P1.name = @name
		@playernum = data.playernum
		@Dialog.show "Waiting for other player...", -> @ #empty callback fn

	onStart: (data) =>
		console.log "leggo!"
		@Dialog.hide -> @ #empty callback fn
		@PUCK = new Puck @W/2, @H/2, 'black'
		p2_radius = 30
		@P2 = new Player @W/2, 0 + p2_radius, p2_radius, 'gray'
		window.requestAnimFrame @gameLoop

	onMove: (e) =>
		console.log "MOVING PADDLE"
		x = e.pageX #- @$canvas.offset().left
		y = e.pageY #- @$canvas.offset().right
		radius = @P1.radius
		maxleft = 0 + radius
		maxright = @canvas.width - radius
		maxbottom = @canvas.height - radius
		#paddle must stay in lower half
		maxtop = (@canvas.height/2) + radius

		###
		Reposition paddle if out of bounds
		###
		#check left wall
		x = maxleft if x < maxleft
		#check right wall
		x = maxright if maxright < x
		#check bottom
		y = maxbottom if maxbottom < y
		#paddle can't go into upper half of table
		y = maxtop if y < maxtop
		
		#save new dx, dy given by move event
		dx = e.deltaX ? -5
		dy = e.deltaY ? -5
		
		#update position
		@P1.updatePos 
			x: x
			y: y
			dx: dx
			dy: dy
			lastUpdate: Date.now()

		#send update to server
		@socket.emit 'player move', @P1.coords()

	#handler for updating client location of puck
	#when it collides on the other device
	#NOTE: we need to flip the coords and directions 
		#to place the puck on the OTHER side of the table
		#if we are player2
	onPuckMove: (data) =>
		if @playernum is 2
			@PUCK.updatePos @reverseCoords data
		else
			@PUCK.updatePos data

	#update coords for player 2 paddle
	#NOTE: we need to flip the coords and directions 
	#to place the P2 paddle on the OTHER side of the table
	onPlayerMove: (data) =>
		@P2.updatePos @reverseCoords data
		#show client that P2 is 'alive'
			#by changing its color
		@P2.color = "blue"
	
	#respond to a player scoring
	onGoal: (data) =>
		if data.name is @name
			data.name = "You"
			@P1.score += 1
			@scoreObj.P1.score += 1
		else
			@P2.score += 1
			@scoreObj.P2.score += 1
		#update player positions
		@P1.updatePos
			x: @W/2
			y: @H - 2*@P1.radius
			dx: 0
			dy: 0
			lastUpdate: Date.now()
		@P2.updatePos
				x: @W/2
				y: 0 + 2*@P2.radius
				dx: 0
				dy: 0
				lastUpdate: Date.now()
		#alert player to goal
		msg = "#{data.name} scored! Click to continue"
		@Dialog.show msg, =>
			@socket.emit 'resume'

	#when other player pauses the game
	onPause: (otherPlayerName) =>
		msg = "#{otherPlayerName} paused. Click to continue"
		@Dialog.show msg, =>
			@socket.emit 'resume'
	
	#Main game loop
	gameLoop: =>
		window.requestAnimFrame @gameLoop
		@drawGame()

	###
	DRAW FUNCTIONS
	###
	drawGame: =>
		@drawTable()
		@P1.draw(@ctx)
		@P2.draw(@ctx)
		@PUCK.draw(@ctx)
	
	#draw design for air hockey table
	drawTable: =>
		#reset canvas to white background
		@ctx.fillStyle = "white"
		@ctx.fillRect(0, 0, @W, @H)
		#draw outline
		@ctx.strokeStyle = "blue"
		@ctx.lineWidth = 1
		@ctx.strokeRect(0, 0, @W, @H)
		#draw middle line
		@ctx.moveTo(0, @H/2)
		@ctx.lineTo(@W, @H/2)
		@ctx.stroke()
		#draw goal for P1
		@ctx.strokeStyle = "black"
		@ctx.lineWidth = 3
		@ctx.moveTo @W/2 - @P1.goalSize/2, @H
		@ctx.lineTo @W/2 + @P1.goalSize/2, @H
		#draw goal for P2
		@ctx.moveTo @W/2 - @P2.goalSize/2, 0
		@ctx.lineTo @W/2 + @P2.goalSize/2, 0
		@ctx.stroke()

	###
	UTIL FUNCTIONS
	###
	#return distance between two (x,y) coords
	distance: (obj1, obj2) ->
		dx = obj2.x - obj1.x
		dy = obj2.y - obj1.y
		Math.sqrt (dx*dx) + (dy*dy)
	
	reverseCoords: (coords) ->
		x: @W - coords.x
		y: @H - coords.y
		dx: -(coords.dx)
		dy: -(coords.dy)
		lastUpdate: coords.lastUpdate

window.Game = Game