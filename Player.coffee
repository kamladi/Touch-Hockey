###
Player class (server side)
###
GameObject = require './public/js/GameObject'

class Player extends GameObject
	constructor: (@id) ->
		super()
		@radius = 25
		@goalSize = 100

module.exports = Player