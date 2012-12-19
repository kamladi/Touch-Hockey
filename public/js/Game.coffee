class Game
	constructor: ->
		@canvas = document.getElementById 'game'
		@ctx = @canvas.getContext '2d'
		@W = @canvas.width
		@H = @canvas.height

		#connect to socket server
		@initSockets()

		#init puck, 2 players
		#p1 is always the current client
		#p2 is the OTHER player
		@PUCK = new Puck(@socket)
		p1_radius = p2_radius = 25
		@P1 = new Player @W/2, @H - p1_radius, p1_radius, 'red'
		@P2 = new Player @W/2, 0 + p2_radius, p2_radius, 'blue'

		#add ref to socket in player1 and puck
		@P1.socket = @socket
		@PUCK.socket = @socket

		@initEventHandlers()

		#60fps timer
		timer = setinterval @gameLoop, 15

	initSockets = ->
		@socket = io.connect 'http://localhost:3000'
		@socket.on 'connect', =>
			console.log "connected to server"
			name = prompt("Welcome! Enter a nickname")
			if name is ""
				console.log "no name entered"
				return false
			console.log "entered " + name
			@socket.emit 'set nickname', name
		@socket.on 'ready', (data) ->
			console.log "connected as #{data.nickname}"
		@socket.on 'player move', @onPlayerMove
		###
		...other game events
		###

	initEventHandlers: ->
		@canvas.on 'mousemove', @onMouseMove
		@canvas.on 'touchmove', @onTouchMove

	#simply convert mouse evt to touch evt
	onMouseMove: (e) =>
		e.touches = [{clientX: e.clientX, clientY: e.clientY}]
		@onTouchMove e

	onTouchMove: (e) =>
		console.log e
		x = e.touches[0].clientX
		y = e.touches[0].clientY
		console.log "x: #{x}, y: #{y}"
		radius = @P1.radius

		#check left wall
		if (x - radius) < 0
			x = radius
		#check right wall
		if @canvas.width < (x + radius)
			x = @canvas.width - radius
		#check bottom
		if @canvas.height < (y + radius)
			y = @canvas.height - radius
		#paddle can't go into upper half of table
		if (y +radius) < (@canvas.height / 2)
			y = (@canvas.height / 2) + @p1.radius
		
		#save new dx, dy
		dx = x - @P1.getX()
		dy = y - @P1.getY()
		
		#update position
		@P1.updatePos x, y, dx, dy
		@socket.emit 'player move', {
			x: x
			y: y
			dx: dx
			dy: dy
		}

	#NOTE: we receive coords for player 2 paddle
	#BUT: we need to flip the coords to place the puck on
		#the OTHER side of the table
	onPlayerMove: (data) =>
		@P2.x = @W - data.x
		@P2.y = @H - data.y

	gameLoop: ->
		drawGame()

		#update positions
		@PUCK.x += @PUCK.dx
		@PUCK.y += @PUCK.dy

		#check puck collision with wall
		x = @PUCK.x
		y = @PUCK.y
		radius = @PUCK.radius
		#check left wall
		if (x - radius) < 0
			x = radius
		#check right wall
		if @canvas.width < (x + radius)
			x = @canvas.width - radius
		#check bottom
		if @canvas.height < (y + radius)
			y = @canvas.height - radius
		#check top
		if (y + radius) < 0
			y = radius

		# check puck collision with paddle
		dist = @distance x1, y1, x2, y2
		if dist < (@P1.radius + @PUCK.radius)
			#...collision magic happens
			@PUCK.dy = -@PUCK.dx
			@PUCK.dx = -@PUCK.dy
			#determine angle of puck after collision
			paddle_angle = @P1.getAngle()
			puck_angle = @PUCK.getAngle()
			diff = puck_angle - paddle_angle
			new_angle = paddle_angle - diff
			#add velocity components of paddle 
				#to veloctiy components of puck
			@PUCK.dx += @P1.dx * Math.cos(new_angle)
			@PUCK.dy += @P1.dy * Math.sin(new_angle)


	###
	DRAW FUNCTIONS
	###
	drawGame: ->
		#reset board
		@ctx.fillStyle = "white"
		@ctx.fillRect 0, 0, @W, @H

		#draw player 1 piece
		@P1.drawPiece @ctx
		@P1.drawPiece @ctx

		#draw puck
		@PUCK.draw @ctx

	#draw design for air hockey table
	drawTable: () ->
		@ctx


	###
	UTIL FUNCTIONS
	###

	#determine if P1 has been scored on
	isScore: ->
		goalSize = @P1.goalSize
		if (@P1.getY() + @P1.radius) is @H
			
	#return distance between two (x,y) coords
	distance: (x1, y1, x2, y2) ->
		dx = x2 - x1
		dy = y2 - y1
		Math.sqrt (dx*dx) + (dy*dy)
