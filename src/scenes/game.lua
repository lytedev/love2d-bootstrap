--[[

File: 		game.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

Game scene.

]]--

local Game = Gamestate.new()

local Client = require("lib.net.client")
local Server = require("lib.net.server")

settings = {}

function Game:init()
	self.netTimer = 0
	self.netUpdateTime = (1 / config.networkUPS)

	self.server = false
	self.client = Client()

	-- pprint(self.client.host)

	-- self:startSingleplayer()
end

function Game:update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	self.netTimer = self.netTimer + dt
	if self.netTimer > self.netUpdateTime or true then
		self:netUpdate(dt)
		self.netTimer = self.netTimer - ((math.floor(self.netTimer / self.netUpdateTime)) * self.netUpdateTime)
	end
end

function Game:netUpdate(dt)
	if self.server then
		self.server:update(dt)
	end
	if self.client then
		self.client:update(dt)
	end
end

function Game:startSingleplayer()
	self.server = Server()
	self.server:start()
	self.client:connect()
end

function Game:hostServer(addr, port)
	addr = addr or "localhost"
	port = port or config.defaultPort
	self.server = Server()
	self.server:start(addr, port)
	self.client:connect(addr, port)
end

function Game:joinServer(addr, port)
	addr = addr or "localhost"
	port = port or config.defaultPort
	self.client:connect(addr, port)
end

function Game:keypressed(k, u)
end

function Game:draw()
	local lh = love.graphics.getFont():getHeight() + 5
	local y = love.graphics.getHeight() - lh
	love.graphics.setColor(255, 255, 255, 128)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, y)
	if self.client.remote then
		love.graphics.print("Ping: " .. tostring(self.client.delay), 5, y - lh)
	end
	console:draw()
end

return Game
