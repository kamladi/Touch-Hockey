###
PUCK object (client side)
###

class Puck extends GameObject
	constructor: (@x, @y, @color) ->
		super()
		@radius = 10

	draw: (ctx) ->
		ctx.lineWidth = 0
		ctx.beginPath()
		ctx.arc @x, @y, @radius, 0, Math.PI*2, false
		ctx.closePath()
		ctx.fillStyle = @color
		ctx.fill()

	#check puck collision with wall
	# returns true if it needs to bounce, false otherwise
	checkWallBounce: (width, height) ->
		maxleft = 0 + @radius
		maxright = width - @radius
		maxbottom = height - @radius
		maxtop = 0 + @radius

		#we don't do anything if it's in bounds
		if maxleft <= @x <= maxright and maxtop <= @y <= maxbottom
			return false

		#check left wall
		if @x < maxleft
			@x = maxleft
			@dx = -@dx
			return true
		#check right wall
		if maxright < @x
			@x = maxright
			@dx = -@dx
			return true
		#check bottom
		if maxbottom < @y
			@y = maxbottom
			@dy = -@dy
			return true
		#check top
		if @y < maxtop
			@y = maxtop
			@dy = -@dy
			return true

window.Puck = Puck