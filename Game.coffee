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
		@game = setInterval @gameLoop, 30
	
	pause: () ->
		clearTimeout @game
	
	gameLoop: () =>
		#increment puck coords
		console.log @PUCK
		@PUCK.move()

		#bounce puck off wall if appropriate
		if @PUCK.checkWallBounce @W, @H
			console.log "PUCK BOUNCED OFF WALL"

		#collide puck with paddle if appropriate
		dist1 = @distance @PUCK, @P1
		dist2 = @distance @PUCK, @P2
		@collideObjects @PUCK, @P1 if dist1 <= (@P1.radius + @PUCK.radius)
		@collideObjects @PUCK, @P2 if dist2 <= (@P2.radius + @PUCK.radius)

		#decelerate puck
		@PUCK.dx -= (1/15) if @PUCK.dx > 1
		@PUCK.dy -= (1/15) if @PUCK.dy > 1

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

	#given which player the given socket client id
		#is referring to
	getPlayer: (id) ->
		return @P1 if @P1.id is id
		return @P2 if @P2.id is id
		false
	#reverse coordinates to place object on OTHER side of table
	reverseCoords: (coords) ->
		x: @W - coords.x
		y: @H - coords.y
		dx: -(coords.dx)
		dy: -(coords.dy)
		lastUpdate: coords.lastUpdate
module.exports = Game
