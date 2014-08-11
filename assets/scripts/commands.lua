
local cmd_commands = {
	command = "commands",
	aliases = {"command", "cmd"},
	name = "Commands",
	description = "Prints a list of available commands or details for a given command",
	args = {
		{
			name = "command",
			data = "text",
			description = "The command you would like detailed information about.",
			default = nil
		}
	},
	callback = function(command)
		local pairs = pairs
		local ipairs = ipairs
		if command then
			commandStr = console:getAlias(command) or command
			command = console.commandHandler[commandStr]
			if not command then
				console:add("Error: Could not find command '" .. commandStr .. "'")
				return
			end
			local a = "No arguments."
			if command.args then
				a = "\n"
				for k, v in ipairs(command.args) do
					a = a .. string.format("|--- %s (%s | Default: %s)\n|----- %s\n", v.name, v.data, tostring(v.default or "None"), v.description)
				end
			end
			local aliases = command.command
			if command.aliases then
				for k, v in pairs(command.aliases) do
					aliases = aliases .. ", " .. v
				end
			end
			console:add(string.format("Console: %s: %s\n|- %s\n|- Arguments%s", command.name, aliases, command.description, a))
		else
			local s = "Console: == Commands ==\n"
			local i = 1
			for k, v in pairs(console.commandHandler) do
				s = s .. tostring(i) .. ". " .. v.command .. "\n"
				i = i + 1
			end
			console:add(s)
		end
	end
}

local cmd_help = {
	command = "help",
	aliases = {"h", "?", "halp"},
	name = "Help",
	description = "Prints the help menu to the console.",
	callback = function()
		console:help()
	end
}

console:bindCommand(cmd_commands)
console:bindCommand(cmd_help)

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
