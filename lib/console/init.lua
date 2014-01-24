--[[

File: 		console.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A console system for LOVE2D games.

]]--

local Console = Class{}

local os = require("os")

function Console:init(font, height)
	self:setFont(font, height)

	self.shouldDraw = false
	self.stealInput = false
	self.position = {0, 0}
	self.messageSpace = 0
	self.messageNewline = false
	self.padding = {5, 5}
	self.timestampFormat = "%H:%M:%S"
	self.messages = {}
	self.scroll = 0
	self.canDisplay = 1
	self.size = {1, -10}
	self.margin = {0, 0}

	self.commands = {}
	self.commandHistory = 50
	self.inputCursor = 1
	self.input = ""

	self.timestampColor = {255, 255, 255, 50}
	self.backgroundColor = {17, 17, 17, 255}
	self.borderColor = {34, 34, 34, 255}
	self.inputColor = {255, 255, 255, 255}
	self.inactiveInputColor = {255, 255, 255, 128}

	self.typeColors = {
		normal={255, 255, 255, 100},
		["n/a"]={255, 255, 255, 255},
		server={120, 150, 100, 255},
		client={0, 150, 150, 255},
		game={0, 100, 200, 255},
		warning={255, 200, 0, 255},
		info={0, 150, 255, 255},
		good={150, 255, 40, 255},
		console={50, 255, 255, 255},
		error={255, 40, 0, 255},
		fatal={255, 0, 255, 255}
	}

	self.textColors = {
		normal={255, 255, 255, 100}
	}
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
	local msg = {text = text, timestamp = os.date(self.timestampFormat), from = from or "N/A"}
	msg.from = string.lower(msg.from)
	table.insert(self.messages, msg)
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

	if love.keyboard.isDown("lctrl", "rctrl") then
		if k == "up" then
			self.scroll = self.scroll + 1
		elseif k == "down" then
			self.scroll = self.scroll - 1
		end
	else
		if k == "backspace" and self.inputCursor > 0 and string.len(self.input) >= 1 then
			self.input = string.sub(self.input, 0, self.inputCursor - 1) .. string.sub(self.input, self.inputCursor + 1, string.len(self.input))
			self.inputCursor = self.inputCursor - 1
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

	dostring(self.input)

	if isInput then
		self.input = ''
		self.inputCursor = 0
	end
end

return Console
