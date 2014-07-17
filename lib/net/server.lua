--[[

File: 		server.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A simple Lua server for LOVE2D.

]]--

local STATUS_CONNECTING = "Connecting"
local STATUS_CONNECTED = "Connected"

local Server = Class{}

function Server:init()
	self.host = false
	self.clients = {}
end

function Server:start(address, port)
	local addr = addr or 'localhost'
	local port = port or config.defaultPort
	self.host = enet.host_create(string.format(addr..":%i", port))
end

function Server:update(dt)
	if not self.host then return end

	self:handleEvent(self.host:service())
end

function Server:send(data)
	for k, c in pairs(self.clients) do
		c.remote:send(data)
	end
end

function Server:handleEvent(e)
	if e then
		if e.type == "connect" then
			local c = {
				["remote"] = e.peer,
				["status"] = STATUS_CONNECTING
			}
			self.clients[tostring(c.remote)] = c
			print(string.format("Server: Client initiated connection from %s", c.remote))
		elseif e.type == "receive" then
			local c = self.clients[tostring(e.peer)]
			if c ~= nil then
				if c.status == STATUS_CONNECTING then
					if e.data == config.title .. "\n" .. config.identity .. "\n" .. config.titleVersion .. "\n" .. config.version then
						c.status = STATUS_CONNECTED
						print(string.format("Server: Client completed connection from %s", c.remote))
					end
				else
					print(string.format("Server: Received from %s: %s", e.peer, e.data))
					self:send(tostring(e.peer) .. ": " .. e.data)
				end
			end
		end
	end
end

return Server
