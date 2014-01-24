--[[

File: 		packet.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A basic "packet"-handling class for Lua.

]]--

local Packet = Class{verbosity = 0}

function Packet:init(t, data)
	if not t and data then
		self:fromData(data)
		return
	end
	self.index = 1
	self.type = t or 0
	self.data = data or ''
	self.length = string.len(self.data)
end

function Packet:fromData(data)
	self.index = 1

	self.data = data
	self.type = self:readNumber()

	self.data = string.sub(data, self.index)
	self.index = 1
	self.length = string.len(self.data)
end

function Packet:toData()
	local s = int_to_bytes(self.type, "big", true)
	local sl = string.len(s)
	local ba = 1 + sl -- Bytes Added (+1 for length of bytes)
	s = string.char(sl) .. s
	return s .. self.data
end

function Packet:addNumber(x)
	local s = int_to_bytes(x, "big", true)
	local sl = string.len(s)
	local ba = 1 + sl -- Bytes Added (+1 for length of bytes)
	s = string.char(sl) .. s
	self.data = string.insert(self.data, s, self.index)
	self.index = self.index + ba
	self.length = string.len(self.data)
	return ba
end

function Packet:addString(s)
	local s = tostring(s)
	local sl = string.len(s)
	self:addNumber(sl)
	local ba = sl -- Bytes Added
	self.data = string.insert(self.data, s, self.index)
	self.index = self.index + ba
	self.length = string.len(self.data)
	return ba
end

function Packet:readNumber()
	local sl = string.byte(self.data, self.index)
	local s = string.sub(self.data, self.index + 1, self.index + sl)
	local n = bytes_to_int(s, "big")
	self.index = self.index + sl + 1
	return n
end

function Packet:readString()
	local sl = self:readNumber()
	local s = string.sub(self.data, self.index, self.index + sl - 1)
	self.index = self.index + sl
	return s
end

function Packet:__tostring()
	local s = "{Packet [" .. tostring(self.type) .. "] " .. " (" .. tostring(self.index) .. "/" .. self.length .. ")}"	
	if Packet.verbosity > 100 then
		s = s .. "\nData: " .. string_bytes(self.data), "client"
	end
	return s
end

return Packet