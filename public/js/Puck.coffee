class Puck
	constructor: (@socket, @color) ->
		@x = 0
		@y = 0
		@radius = 25
		@dx = 0
		@dy = 0

		#socket events for puck
		@socket.on 'puckCollision', @onPuckCollision
	getX: ->
		@x
	getY: ->
		@y
	setX: (x) ->
		@x = x
	setY: (y) ->
		@y = y
	getAngle: ->
		Math.atan2 @dy, @dx
	getMagnitude: ->
		Math.sqrt (@dx*@dx) + (@dy*@dy)
	
	onPuckCollision: (data) ->
		@x = data.x
		@y = data.y
		@dx = data.dx
		@dy = data.dy

	draw: (ctx) ->
		ctx.beginPath()
		ctx.arc @x, @y, @radius, 0, Math.PI*2, false
		ctx.fillStyle = @color
		ctx.fill()
	
	move: (paddle_angle) ->
