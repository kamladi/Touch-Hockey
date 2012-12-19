###
Player class on Node Server
###
class Player
	constructor: (@x, @y, @color) ->
		@id = 0
		@dx = 0
		@dy = 0
		@goalSize = 100
	getX: ->
		@x
	getY: ->
		@y
	setX: (x) ->
		@x = x
	setY: (y) ->
		@y = y
	updatePos: (x, y) ->
		@setX x
		@setY y

exports = Player