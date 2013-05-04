###
Player class (server side)
###
GameObject = require './public/js/GameObject'

class Player extends GameObject
	constructor: (@id) ->
		super()
		@radius = 30
		@goalSize = 100
		@score = 0

module.exports = Player