{spawn} = require 'child_process'

AppFiles = [
	'./server.coffee'
	'./Bag.coffee'
	'./public/app.coffee'
]

task 'watch', 'Watch and build coffeescript files in current directory and in /public', ->
	#build server side Coffeescript
	for file in AppFiles
		cmd = spawn 'coffee', ['-cw', file]
		cmd.stderr.on 'data', (data) ->
			process.stderr.write data.toString()
		cmd.stdout.on 'data', (data) ->
			console.log data.toString().trim()


task 'restart', 'Restart Node server', ->
	cmd = spawn 'nodemon', ['./server.coffee']
	cmd.stderr.on 'data', (data) ->
		process.stderr.write data.toString()
	cmd.stdout.on 'data', (data) ->
		console.log data.toString().trim()


task 'dev', 'Dev Mode: watching for cahanges and restarting Node server', ->
 	invoke 'watch'
 	invoke 'restart'