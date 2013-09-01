{spawn} = require 'child_process'

coffee_compile = (src, dest, watch=true, callback) ->
	arg = if watch then '-w' else '-c'
	cmd = spawn "coffee", [arg, '-o', src, dest]
	cmd.stdout.on 'data', (data) -> process.stdout.write data.toString()
	cmd.stderr.on 'data', (data) -> process.stderr.write data.toString()
	cmd.on 'exit', (code) ->
		if code is 0
			console.log "successfully compiled files from #{src} -> #{dest}"
		else
			process.stderr.write "unsuccessful compilation from #{src} -> #{dest}"

task 'build', 'One-time build of coffeescript files in current directory and in /public', ->
	#compile server-side Coffeescript
	coffee_compile '.', 'src/', false
	#compile client-side Coffeescript
	coffee_compile 'public/js/', 'public/src/', false

task 'watch', 'Watch and build coffeescript files in current directory and in /public', ->
	console.log "Now watching coffeescript files for changes..."
	#watch server-side Coffeescript
	coffee_compile '.', 'src/', true
	#watch client-side Coffeescript
	coffee_compile 'public/js/', 'public/src/', true

task 'restart', 'Restart Node server', ->
	cmd = spawn 'nodemon', ['./server.js']
	cmd.stdout.on 'data', (data) -> process.stdout.write data.toString()
	cmd.stderr.on 'data', (data) -> process.stderr.write data.toString()


task 'dev', 'Dev Mode: watching for cahanges and restarting Node server', ->
 	invoke 'watch'
 	invoke 'restart'
