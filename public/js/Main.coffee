window.onload = ->
	window.GAME = new Game(PLAYER)
	#prevent scrolling
	document.body.addEventListener 'touchmove', (event) ->
  		event.preventDefault();