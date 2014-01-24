--[[

File: 		server.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A simple Lua server for LOVE2D.

]]--

local socket = require("socket")
local Packet = require("lib.net.packet")
local Server = Class{}

function Server:init(addr, port)
	self.printPacketInfo = 0
	self.address = addr or "*"
	self.port = port or 8888
	self.sock = socket.udp()
	self.hosting = false
	self.packetHandler = {}
end

function Server:host(address, port)
	self.address = address or self.address
	self.port = port or self.port

	self.sock:settimeout(0)
	self.sock:setsockname(self.address, self.port)
	self.hosting = true
	print(string.format("Server: Hosting on %s:%i", self.address, self.port))
end

function Server:sendPacket(p, ip, port)
	if self.printPacketInfo> 0 then
		print("Server: Sending Packet: " .. tostring(p))
	end

	self.sock:sendto(p:toData(), ip, port)
end

function Server:handlePacket(data, ip, port)
	local p = Packet(nil, data)

	if self.printPacketInfo > 0 then
		print("Server: Handling Packet: " .. tostring(p))
	end

	if self.packetHandler[p.type] then
		self.packetHandler[p.type](self, p, ip, port)
	else
		if self.printPacketInfo > 0 then
			print(string.format("Server: Found packet of type %i without handler", p.type))
		end
	end
end

function Server:update(dt)
	if not self.hosting then
		return
	end

	repeat
		data, msg, port = self.sock:receivefrom()
		if data then
			self:handlePacket(data, msg, port)
		elseif msg ~= 'timeout' then
            print("Server: Network error: " .. tostring(msg))
		end
	until not data
end

return Server
