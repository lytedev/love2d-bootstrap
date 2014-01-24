--[[

File: 		server.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A simple Lua server.

]]--

local libServer = require("lib.net.server")
local Packet = require("lib.net.packet")
local Server = Class{__includes=libServer}

function Server:init(addr, port)
	libServer.init(self)
	self.printPacketInfo = 0
	if not config.release then
		self.printPacketInfo = 1000
	end

	self.initialHandshake = config.title .. "\n" .. config.identity .. "\n" .. config.titleVersion .. "\n" .. config.version

	self.packetHandler[1] = function(self, packet, ip, port) 
		-- Client connection request
		local s = packet:readString()
		if s == self.initialHandshake then
			local p = Packet(2)
			self:sendPacket(p, ip, port)
		end
	end
end

return Server
