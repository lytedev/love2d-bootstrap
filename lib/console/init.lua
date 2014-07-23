--[[

File: 		console.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A console and scripting system for LOVE2D games.

]]--

local Class = require("lib.hump.class")

local Console = Class{}

local os = require("os")

function Console:init(font, height, overwritePrint, show)
	overwritePrint = overwritePrint or true
	show = show or false
	font = font or false
	if font and not height then
		height = font:getHeight()
	elseif not height then
		height = 9
	end

	if overwritePrint then
		old_print = print
		print = function(msg, from)
			self:add(msg, from)
		end
	end

	if not font then
		font = love.graphics.newFont(height)
		self:setFont(font, height)
	else
		self:setFont(font, height)
	end

	self.shouldDraw = false
	self.stealInput = false
	self.position = {0, 0}
	self.messageSpace = 0
	self.messageNewline = false
	self.padding = {5, 5}
	self.timestampFormat = "%H:%M:%S"
	self.maxMessages = 500
	self.messages = {}
	self.scroll = 0
	self.canDisplay = 1
	self.size = {1, -15}
	self.margin = {0, 0}

	self.currentCommand = 2
	self.commands = {"", ""}
	self.commandHistory = 50
	self.inputCursor = 1
	self.input = ""
	self.commandPrefix = '/'
    love.keyboard.setKeyRepeat(0.4, 0.02)

	self.timestampColor = {255, 255, 255, 50}
	self.backgroundColor = {17, 17, 17, 255}
	self.borderColor = {34, 34, 34, 255}
	self.inputColor = {255, 255, 255, 255}
	self.inactiveInputColor = {255, 255, 255, 128}

	self.logFileTimeStampFormat = "%Y-%m-%d_%H-%M-%S"
	self.logTimeStampFormat = "%Y-%m-%d %H:%M:%S"
	love.filesystem.createDirectory("logs")
	self.logFile = love.filesystem.newFile("logs/" .. os.date(self.logFileTimeStampFormat) .. "_" .. config.identity .. ".log")
	self.logFile:open("a")

	self.typeColors = {
		["normal"]={255, 255, 255, 100},
		["n/a"]={255, 0, 255, 255},
		["server"]={120, 150, 100, 255},
		["client"]={0, 150, 150, 255},
		["game"]={0, 100, 200, 255},
		["warning"]={255, 200, 0, 255},
		["info"]={0, 150, 255, 255},
		["good"]={150, 255, 40, 255},
		["console"]={50, 255, 255, 255},
		["error"]={255, 40, 0, 255},
		["fatal"]={255, 0, 255, 255}
	}

	self.textColors = {
		normal={255, 255, 255, 100}
	}

	self.commandHandler = {}
	self.commandAliases = {}

	-- Console needs text input hooks (duh) and keyrepeat is familiar
	love.keyboard.setTextInput(true)
	love.keyboard.setKeyRepeat(true)

	if show then
		self:toggle()
	end

	if hooks == nil then
		hooks = require("lib.hooks")
		hooks.registerLoveCallbacks()
	end

	hooks:add('textinput', function(...) self:textinput(...) end)
	hooks:add('keypressed', function(...) self:keypressed(...) end)
	hooks:add('update', function(...) self:update(...) end)
	hooks:add('draw', function(...) self:draw(...) end)
	if assetManager ~= nil then
		hooks:add('load', function(...) dofile(assetManager:createScriptPath("init")) end)
	end

	print("Console: Initialized")
end

function Console:setFont(font, height)
	self.font = font
	self.lineHeight = height or self.font:getHeight()
	self.font:setLineHeight(self.lineHeight / self.font:getHeight())
	self.timestampWidth = self.lineHeight * 5
	self.fromWidth = self.lineHeight * 6.5
	self.indent = self.lineHeight
end

function Console:toggle()
	self.stealInput = not self.stealInput
	self.shouldDraw = not self.shouldDraw
end

function Console:add(text)
	local text = tostring(text) or ""
	local from = string.match(text, "^%a+: ")
	if from then
		text = string.sub(text, string.len(from))
		from = string.sub(from, 0, -3)
	end
	from = from or "N/A"
	self.logFile:write("[" .. os.date(self.logTimeStampFormat) .. "] " .. from .. ": " .. text .. "\r\n")
	local msg = {text = text, timestamp = os.date(self.timestampFormat), from = from}
	msg.from = string.lower(msg.from)
	table.insert(self.messages, msg)
	while #self.messages > self.maxMessages do
		table.remove(self.messages, 1)
	end
	if self.scroll > 1 then
		self.scroll = self.scroll + 1
	end
	return msg
end

function Console:getSize()
	local size = {unpack(self.size)}
	if size[1] <= 1 then
		size[1] = size[1] * love.graphics.getWidth() - (self.margin[1] * 2)
	end
	if size[2] <= 0 then
		size[2] = (self.lineHeight * math.abs(size[2])) + (self.padding[2] * 2) - 1
	elseif size[2] <= 1 then
		size[2] = size[2] * love.graphics.getHeight() - (self.margin[2] * 2)
	end
	return size
end

function Console:update(dt)
end

function Console:measureMessage(msg, x, y)
	local oy = y
	local ox = x
	x = x + self.timestampWidth
	local ef = '[' .. string.upper(msg.from) .. ']'
	x = x + self.fromWidth
	local y = oy
	local lines = 0
	local w = self:getSize()[1] - (self.padding[1] * 2) - x
	if self.messageNewline then
		y = y + self.lineHeight
		x = ox + self.indent
		lines = lines + 1
		w = w - self.indent
	end
	local rw, al = self.font:getWrap(msg.text, w)
	lines = lines + al
	return (self.lineHeight * lines) + self.messageSpace
end

function Console:drawMessage(msg, x, y)
	local oy = y
	local ox = x
	love.graphics.setColor(self.timestampColor)
	love.graphics.print(msg.timestamp, x, y)
	x = x + self.timestampWidth

	love.graphics.setColor(self.typeColors[msg.from] or self.typeColors.normal)
	local ef = '[' .. string.upper(msg.from) .. ']'
	love.graphics.print(ef, x, y)
	x = x + self.fromWidth

	local y = oy
	local lines = 0
	local w = self:getSize()[1] - (self.padding[1] * 2) - x
	if self.messageNewline then
		y = y + self.lineHeight
		x = ox + self.indent
		lines = lines + 1
		w = w - self.indent
	end
	local rw, al = self.font:getWrap(msg.text, w)
	lines = lines + al

	love.graphics.setColor(self.textColors[msg.from] or self.textColors.normal)
	love.graphics.printf(msg.text, x, y, w, "left")
	return (self.lineHeight * lines) + self.messageSpace
end

function Console:draw(dt)
	if not self.shouldDraw then
		return
	end

	local pos = self.position
	local size = self:getSize()
	love.graphics.setColor(self.backgroundColor)
	love.graphics.rectangle("fill", pos[1], pos[2], size[1], size[2])
	love.graphics.setColor(self.borderColor)
	love.graphics.rectangle("line", pos[1] - 0.5, pos[2] - 0.5, size[1] + 1, size[2] + 1)

	love.graphics.setFont(self.font)
	local room = size[2] - self.padding[2] - (self.lineHeight * 1) + self.messageSpace
	if self.scroll >= #self.messages then
		self.scroll = #self.messages - 1
	end
	if self.scroll < 0 then
		self.scroll = 0
	end
	self.canDisplay = 0
	for i = #self.messages - self.scroll, 1, -1 do
		local a = {self.messages[i], pos[1] + self.padding[1], pos[2] + room}
		room = room - self:measureMessage(unpack(a))
		local a = {self.messages[i], pos[1] + self.padding[1], pos[2] + room}
		if room > self.padding[2] - 2 then
			self:drawMessage(unpack(a))
			self.canDisplay = self.canDisplay + 1
		else
			break
		end
	end

	love.graphics.setColor(self.inputColor)
	if not self.stealInput then
		love.graphics.setColor(self.inactiveInputColor)
	end
	love.graphics.print(string.insert(self.input, '_', self.inputCursor), pos[1] + self.padding[1], pos[2] + size[2] - self.padding[2] - self.lineHeight)
end

function Console:keypressed(k, isRepeat)
	if not self.stealInput then
		return
	end

	if self.size[2] < 0 then
		--if k == "end" then
			--self.size[2] = self.size[2] - 1
			-- self.scroll = self.scroll + 5
		--end
		--if k == "home" then
			--self.size[2] = self.size[2] + 1
			-- self.scroll = self.scroll - 5
		--end
	end

	if love.keyboard.isDown("lalt", "ralt") and love.keyboard.isDown("lctrl", "rctrl") then
		if k == "up" or k == "pageup" then
			self.scroll = 1000000000
		elseif k == "down" or k == "pagedown" then
			self.scroll = 0
		end
	elseif love.keyboard.isDown("lctrl", "rctrl") then
		if k == "up" then
			self.scroll = self.scroll + 1
		elseif k == "down" then
			self.scroll = self.scroll - 1
		end
	else
		if k == "backspace" and self.inputCursor > 0 and string.len(self.input) >= 1 then
			self.input = string.sub(self.input, 0, self.inputCursor - 1) .. string.sub(self.input, self.inputCursor + 1, string.len(self.input))
			self.inputCursor = self.inputCursor - 1
		elseif k == "up" then
			self:loadCommand(self.currentCommand + 1)
		elseif k == "down" then
			self:loadCommand(self.currentCommand - 1)
		elseif k == "left" then
			self.inputCursor = self.inputCursor - 1
		elseif k == "right" then
			self.inputCursor = self.inputCursor + 1
		elseif k == "end" then
			self.inputCursor = string.len(self.input)
		elseif k == "home" then
			self.inputCursor = 0
		elseif k == "return" then
			self:handleInput()
		elseif self.size[2] < 0 then
			if k == "pageup" then
				self.scroll = self.scroll - (self.size[2] / 2)
			elseif k == "pagedown" then
				self.scroll = self.scroll + (self.size[2] / 2)
			end
		else
			if k == "pageup" then
				self.scroll = self.scroll - 5
			elseif k == "pagedown" then
				self.scroll = self.scroll + 5
			end
		end
	end
	if self.inputCursor < 0 then
		self.inputCursor = 0
	elseif self.inputCursor > string.len(self.input) then
		self.inputCursor = string.len(self.input)
	end
end

function Console:textinput(t)
	self.input = string.insert(self.input, t, self.inputCursor)
	self.inputCursor = self.inputCursor + string.len(t)
end

function Console:handleInput(i)
	local i = i or self.input
	local isInput = false
	if i == self.input then
		isInput = true
	end

	dostring(i)

	if isInput then
		self.input = ''
		self.inputCursor = 0
	end
end

function Console:addCommand(input)
	if input == '' then return end
	table.insert(self.commands, 3, input)
	self.currentCommand = 2
	while #self.commands > self.commandHistory do
		table.remove(self.commands, self.commandHistory + 1)
	end
	-- self:add("Command: " .. input .. " (" .. self.currentCommand .. "/" .. #self.commands .. ") " .. table.concat(self.commands))
end

function Console:loadCommand(ci)
	if self.currentCommand ~= 1 then
		self.commands[self.currentCommand] = self.input
	end
	self.currentCommand = ci or self.currentCommand
	if self.currentCommand < 1 --[[ or (self.currentCommand < 2 and self.commands[2] == '') ]] then
		self.currentCommand = #self.commands
	elseif self.currentCommand > #self.commands then
		self.currentCommand = 1
	end
	self.input = self.commands[self.currentCommand]
	self.inputCursor = #self.input
end

function Console:processCommand(input)
	if input == nil or input == '' then
		return
	end
	local input = tostring(input)
	local command = string.match(input, "^([^%s]+)%s*")
	input = string.trim(string.sub(input, string.len(command) + 1))
	if not input then
		self:runCommand(command)
		return
	end

	local args = {}
	while true do
		local m = nil
		local cutter = nil
		local cutter = string.match(input, '^(["\'].-["\']%s*)')
		local m = string.match(input, '^["\'](.-)["\']%s*')
		if not m then
			cutter = string.match(input, 	'^([^%s]+)')
			m = string.match(input, 		'^([^%s]+)')
		end
		if m == nil or #args > 20 then
			break
		else
			table.insert(args, string.trim(m))
			input = string.trim(string.sub(input, string.len(cutter) + 1, string.len(input)))
		end
	end

	self:runCommand(command, args)
end

function Console:runCommand(cmd, args)
	local cmd = self:getAlias(cmd) or cmd
	local args = args or {}
	local f = self.commandHandler[cmd]
	if f then
		return f.callback(unpack(args))
	else
		self:add("Error: Could not find command '" .. cmd .. "'")
	end
end

function Console:handleInput(i)
	local i = i or self.input
	local isInput = false
	if string.trim(i) == '' then
		return
	end
	if i == self.input then
		isInput = true
	end
	print("Input: " .. i)

	if i == 'help' then
		i = '/help'
	end

	self:addCommand(i)
	if string.sub(i, 0, 1) == self.commandPrefix then
		self:processCommand(string.sub(i, string.len(self.commandPrefix) + 1))
	else
		dostring(i)
	end

	if isInput then
		self.input = ''
		self.inputCursor = 0
	end
end

function Console:help()
	self:add("Console: Try '/commands' to see a list of commands!\nTry '/command <command>' to see details of that command'\nExample: '/command host'")
end

function Console:createAlias(alias, command)
	self.commandAliases[alias] = command
end

function Console:getAlias(alias)
	return self.commandAliases[alias] or alias
end

function Console:bindCommand(cmd, f)
	if not cmd.command and not f then
		print("Console: Tried to add blank command")
		return
	elseif cmd and not f then

	else
		cmd = {command = cmd, callback = f}
	end

	cmd.name = cmd.name or "Anonymous Command"
	cmd.args = cmd.args or nil
	cmd.description = cmd.description or "No description."

	if cmd.aliases then
		for i, v in ipairs(cmd.aliases) do
			self:createAlias(v, cmd.command)
		end
	end

	self.commandHandler[cmd.command] = cmd
end

-- For running files or strings through the interpreter/console
function dofile(file, name)
	local ok, chunk = pcall(love.filesystem.load, file)
	if not ok then
		print("Error: " .. tostring(chunk))
	else
		local result
		ok, result = pcall(chunk)
		if not ok then
			print("Error: " .. tostring(result))
		else
			-- print("Console: " .. tostring(result))
			-- Scripts do not have a result printed
		end
	end
end

function dostring(str, tryagain)
    tryagain = tryagain or true
	local ok, f, e = pcall(loadstring, str)
	if not ok then
        if tryagain then
            return dostring("return " .. str)
        else
            print("Error: " .. tostring(f))
        end
	else
		local result
		ok, result = pcall(f)
		if not ok then
            if tryagain then
                return dostring("return " .. str)
            else
                print("Error: " .. tostring(result))
            end
		else
			print("Console: " .. tostring(result))
		end
	end
end

return Console
