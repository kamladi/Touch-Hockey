window.onload = ->
	window.scrollTo(0, 1);
	window.GAME = new Game()

#alert user when user rotates device
window.onorientationchange = ->
	if orientation is 90 or orientation is -90
		alert "Game must be played in portrait mode only."