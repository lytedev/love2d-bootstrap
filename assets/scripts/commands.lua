
local cmd_singleplayer = {
	command = "singleplayer",
	aliases = {"sp", "single"},
	name = "Singleplayer",
	description = "Starts a singleplayer game",
	callback = function(command)
		g = Gamestate.current()
		if g.startSingleplayer then
			g:startSingleplayer()
		end
	end
}

local cmd_host = {
	command = "host",
	name = "Host",
	description = "Host a server",
	callback = function(command)
		g = Gamestate.current()
		if g.hostServer then
			g:hostServer()
		end
	end
}

local cmd_join = {
	command = "join",
	name = "Join",
	description = "Join a server",
	callback = function(command)
		g = Gamestate.current()
		if g.joinServer then
			g:joinServer()
		end
	end
}

local cmd_message = {
	command = "message",
	name = "Message",
	description = "Send a message to the server",
	callback = function(command)
		g = Gamestate.current()
		if g.client then
			g.client:send("Hello, guys!")
		end
	end
}

console:bindCommand(cmd_singleplayer)
console:bindCommand(cmd_join)
console:bindCommand(cmd_host)
console:bindCommand(cmd_message)
