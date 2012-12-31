###
PLAYER object (client side)
###

class Player extends GameObject
	constructor: (@x, @y, @radius, @color)->
		super()

	draw: (ctx) ->
		ctx.beginPath()
		ctx.arc @x, @y, @radius, 0, Math.PI*2, false
		ctx.closePath()
		ctx.fillStyle = @color
		ctx.fill()

window.Player = Player