--[[

File: 		client.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A basic Lua networking client for LOVE2D games.

]]--

local socket = require("socket")
local Packet = require("lib.net.packet")
local Client = Class{}

function Client:init()
	self.printPacketInfo = 0
	self.sock = socket.udp()
	self.connected = false
	self.packetHandler = {}
end

function Client:connect(addr, port)
	local addr = addr or 'localhost'
	local port = port or 8888
	self.sock:settimeout(0)
	if (self.sock:setpeername(addr, port)) then
		print(string.format("Client: Connecting to %s:%i...", addr, port))
		self.connected = true
	else
		print(string.format("Client: Failed to connect to %s:%i", addr, port))
	end
end

function Client:sendPacket(p)
	if self.printPacketInfo > 0 then
		print("Client: Send Packet: " .. tostring(p))
	end

	self.sock:send(p:toData())
end

function Client:handlePacket(data)
	local p = Packet(nil, data)

	if self.printPacketInfo > 0 then
		print("Client: Recieved Packet: " .. tostring(p))
	end

	if self.packetHandler[p.type] then
		self.packetHandler[p.type](self, p)
	else
		if self.printPacketInfo > 0 then
			print(string.format("Client: Found packet of type %i without handler", p.type))
		end
	end
end

function Client:update()
	if not self.connected then
		return
	end

	repeat
		data, msg = self.sock:receive()
		if data then
			self:handlePacket(data)
		elseif msg ~= 'timeout' then
            print("Client: Network error: " .. tostring(msg))
		end
	until not data
end

return Client
