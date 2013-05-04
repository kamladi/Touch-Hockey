{exec} = require 'child_process'

task 'build', 'One-time build of coffeescript files in current directory and in /public', ->
	#watch server-side Coffeescript
	exec 'coffee --compile --output . src/', (err, stdout, stderr) ->
    	throw err if err
    	console.log stdout + stderr
	#watch client-side Coffeescript
	exec 'coffee --compile --output public/js/ public/src/', (err, stdout, stderr) ->
    	throw err if err
    	console.log stdout + stderr

task 'watch', 'Watch and build coffeescript files in current directory and in /public', ->
	#watch server-side Coffeescript
	exec 'coffee --watch --compile --output . src/', (err, stdout, stderr) ->
    	throw err if err
    	console.log stdout + stderr
	#watch client-side Coffeescript
	exec 'coffee --watch --compile --output public/js/ public/src/', (err, stdout, stderr) ->
    	throw err if err
    	console.log stdout + stderr


task 'restart', 'Restart Node server', ->
	exec 'nodemon ./server.js', (err, stdout, stderr) ->
		throw err if err
		console.log stdout + stderr


task 'dev', 'Dev Mode: watching for cahanges and restarting Node server', ->
 	invoke 'watch'
 	invoke 'restart'
