class Dialog
	constructor: ->
		@$container = $ '#dialog-container'
		@$dialog = @$container.find '#dialog'
	
	show: (msg, callback) ->
		@$dialog.html msg
		@$container.one 'click', (e) =>
			e.stopPropagation()
			@hide callback
		@$container.fadeIn 'fast'
	
	hide: (callback) ->
		@$dialog.html ""
		@$container.fadeOut 'fast', callback

window.Dialog = Dialog
