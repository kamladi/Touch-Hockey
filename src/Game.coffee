###
GAME class (server side)
###
Puck = require './Puck'
Player = require './Player'
{EventEmitter} = require 'events'
class Game extends EventEmitter
	constructor: (@W, @H, @sockets) ->
		@PUCK = new Puck @W/2, @H/2
	
	start: () ->
		@game = setInterval @gameLoop, 15
	#called after every goal,

	#place the puck on the side of the loser
	reset: (loser) ->
		@pause()
		newPos = if loser is @P1 then (5*@PUCK.radius) else (-5*@PUCK.radius)
		#reset positions of puck, players
		@PUCK.updatePos
			x: @W/2
			y: @H/2 + newPos
			dx: 0
			dy: 0
			lastUpdate: Date.now()
		#send coords to players
		@sockets.emit 'puck move', @PUCK.coords()
		#update player positions
		@P1.updatePos
			x: @W/2
			y: @H - 2*@P1.radius
			dx: 0
			dy: 0
			lastUpdate: Date.now()
			isReady: false
		@P2.updatePos
				x: @W/2
				y: 0 + 2*@P2.radius
				dx: 0
				dy: 0
				lastUpdate: Date.now()
				isReady: false
	
	pause: () ->
		clearTimeout @game
		@P1.isReady = false
		@P2.isReady = false
	
	gameLoop: () =>
		#increment puck coords
		@PUCK.move()

		#bounce puck off wall if appropriate
		if @PUCK.checkWallBounce @W, @H
			console.log "PUCK BOUNCE"

		#collide puck with paddle if appropriate
		dist1 = @distance @PUCK, @P1
		dist2 = @distance @PUCK, @P2
		@collideObjects @PUCK, @P1 if dist1 < (@P1.radius + @PUCK.radius)
		@collideObjects @PUCK, @P2 if dist2 < (@P2.radius + @PUCK.radius)

		#check for goals
		if @isGoalOn @P1
			@sockets.emit 'goal', name: @P1.name
			@P1.score += 1
			@reset(@P1)
		else if @isGoalOn @P2
			@sockets.emit 'goal', name: @P2.name
			@P1.score += 1
			@reset(@P2)

		#decelerate puck
		@PUCK.dx -= (1/30) if @PUCK.dx > 1.5
		@PUCK.dy -= (1/30) if @PUCK.dy > 1.5

		#send coords to players
		@sockets.emit 'puck move', @PUCK.coords()
	#return distance between two (x,y) coords
	distance: (obj1, obj2) ->
		dx = obj2.x - obj1.x
		dy = obj2.y - obj1.y
		Math.sqrt (dx*dx) + (dy*dy)

	#mathemagically collides two objects, 
		#and sets new coords/directions
	collideObjects: (puck, paddle) ->
		@sockets.emit 'collision'
		#reset puck to outside paddle
		newdistance = paddle.radius + puck.radius
		diffx = puck.x - paddle.x
		diffy = puck.y - paddle.y
		angle = Math.atan2 diffy, diffx
		puck.x = paddle.x + newdistance * Math.cos angle
		puck.y = paddle.y + newdistance * Math.sin angle
		
		#...collision magic happens
		puck.dy = -puck.dx
		puck.dx = -puck.dy
		#determine angle of puck after collision
		#reflect puck_angle across angle
		puck_angle = puck.getAngle()
		diff = puck_angle - angle
		new_angle = angle - diff
		#add velocity components of paddle 
		#to veloctiy components of puck
		puck.dx += paddle.dx * Math.cos(new_angle)
		puck.dy += paddle.dy * Math.sin(new_angle)

		#limit the min/max speed of the puck,
			#so shit doesn't get too crazy
		@PUCK.dx = 10 if @PUCK.dx > 10
		@PUCK.dx = -10 if @PUCK.dx < -10
		@PUCK.dy = 10 if @PUCK.dy > 10
		@PUCK.dy = -10 if @PUCK.dy < -10

		@PUCK.dx = 1 if 0 <= @PUCK.dx < 1
		@PUCK.dx = -1 if -1 <= @PUCK.dx < 0
		@PUCK.dy = 1 if 0 <= @PUCK.dy < 1
		@PUCK.dy = -1 if -1 <= @PUCK.dy < 0

	#given which player the given socket client id
		#is referring to
	getPlayer: (id) ->
		return @P1 if @P1.id is id
		return @P2 if @P2.id is id
		false
	getOtherPlayer: (id) ->
		if @getPlayer(id) is @P1 then return @P1 else return @P2
	
	#add player, and setup initial coords
	#if we're adding the second player, 
		#let the server know to start the game
	addPlayer: (playerid) ->
		if not @P1?
			@P1 = new Player playerid
			@P1.set
				x: @W / 2
				y: @H - 2*@P1.radius
				dx: 0
				dy: 0
				lastUpdate: Date.now()
				isReady: true
		else if not @P2?
			@P2 = new Player playerid
			@P2.updatePos
				x: @W / 2
				y: 0 + 2*@P2.radius
				dx: 0
				dy: 0
				lastUpdate: Date.now()
				isReady: true

	removePlayer: (playerid) ->
		if playerid is @P1.id
			@P1 = null
		else
			@P2 = null
	
	#reverse coordinates to place object on OTHER side of table
	reverseCoords: (coords) ->
		x: @W - coords.x
		y: @H - coords.y
		dx: -(coords.dx)
		dy: -(coords.dy)
		lastUpdate: coords.lastUpdate
	
	#check if given player has been scored on
	isGoalOn: (player) ->
		leftBound = @W/2 - player.goalSize/2 + @PUCK.radius
		rightBound = @W/2 + player.goalSize/2 - @PUCK.radius
		if leftBound <= @PUCK.x <= rightBound
			if player is @P1
				return @PUCK.y + @PUCK.radius is @H
			else if player is @P2
				return @PUCK.y - @PUCK.radius is 0
			else
				return false
module.exports = Game
