print("Scripts: Running initialization script...")

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

require("assets.scripts.commands")

print("Scripts: Initialization complete.")
