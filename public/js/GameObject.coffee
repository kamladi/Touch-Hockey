###
GAMEOBJECT is a base class which both server-side and 
	client-side game entities inherit from
###
class GameObject
	constructor: () ->
		@dx = 0
		@dy = 0
		@lastUpdate = Date.now()
		@goalSize= 100
	
	#general function for applying multipl properties
	#simultaneously, i.e. x/y, name, width, height, ...
	set: (data) ->
		this[key] = val for key, val of data
	
	#update the position of the obj,
		#ONLY if it is a more recent update
	updatePos: (data) ->
		if data.lastUpdate > @lastUpdate
			@set data
	
	#increment the coords of the obj
	move: () ->
		@x += @dx
		@y += @dy
		@lastUpdate = Date.now()
		@
	
	#return this object's position as an object
	coords: () ->
		x: @x
		y: @y
		dx: @dx
		dy: @dy
		lastUpdate: @lastUpdate

	#distance btwn this object and another object
	distanceFrom: (object) ->
		dx = object.x - @x
		dy = object.y - @y
		Math.sqrt (dx*dx) + (dy * dy)

	#angle/direction at which this object is moving
	getAngle: ->
		Math.atan2 @dy, @dx
	
	#magnitude of velocity vector
	getMagnitude: ->
		Math.sqrt (@dx*@dx) + (@dy*@dy)

if typeof window is 'undefined'
	module.exports = GameObject
else
	window.GameObject = GameObject