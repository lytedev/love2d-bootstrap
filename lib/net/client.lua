--[[

File: 		client.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A basic Lua networking client for LOVE2D games.

]]--

require("enet")

local Client = Class{}

function Client:init()
	self.host = enet.host_create()
	self.server = false
	self.remote = false
	self.connected = false
	self.delay = -1
end

function Client:connect(addr, port)
	local addr = addr or 'localhost'
	local port = port or config.defaultPort
	self.server = self.host:connect(string.format(addr..":%i", port))
	self.connected = true
end

function Client:disconnect()
	local event = self.host:service(100)
	self.server:disconnect_later()
	self.host:flush()
end

function Client:update()
	if not self.connected then return end

	self:handleEvent(self.host:service())

	self.server:ping()
	self.delay = self.server:round_trip_time()
	if self.delay >= 5000 then
		self.server = false
		self.connected = false
	end
	-- old_print(string.format("Client Ping: %ims", self.delay))
end

function Client:send(data)
	if not self.remote then return false end
	self.remote:send(data)
end

function Client:handleEvent(e)
	--[[

	e.type
	e.peer
	e.data

	]]--

	if e then
		if e.type == "connect" then
			self.remote = e.peer
			print(string.format("Client: Connected to %s", self.remote))
			self:send(config.title .. "\n" .. config.identity .. "\n" .. config.titleVersion .. "\n" .. config.version)
		elseif e.type == "receive" then
			print(string.format("Client: Received from server: %s", e.data))
			-- self:send(tostring(e.peer) .. ": " .. e.data)
		end
	end
end

return Client
