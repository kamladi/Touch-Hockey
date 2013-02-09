###
PLAYER object (client side)
###

class Player extends GameObject
	constructor: (@x, @y, @radius, @color)->
		super()
		@score = 0

	draw: (ctx) ->
		ctx.fillStyle = @color
		ctx.beginPath()
		ctx.arc @x, @y, @radius, 0, Math.PI*2, false
		ctx.fill()
		ctx.closePath()

window.Player = Player