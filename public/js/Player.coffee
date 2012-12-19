class Player
	constructor: (@x, @y, @radius, @color)->
		@dx=0
		@dy=0
	
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

	onPosChange: (data) ->
		@x = data.x
		@y = data.y
		@dx = data.dx
		@dy = data.dy

	drawPaddle: (ctx) ->
		ctx.beginPath()
		ctx.arc @x, @y, @radius, 0, Math.PI*2, false
		ctx.fillStyle = @color
		ctx.fill()

	updatePos: (x, y, dx, dy) ->
		@setX x
		@setY y