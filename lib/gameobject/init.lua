--[[

File: 		conf.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

Represents an object in the game.

]]--

local Gameobject = Class{}

OBJECT_COLLISION_PADDING = 0.01

OBJECT_STATIC = 0
OBJECT_DYNAMIC = 1

Gameobject.world = {};
Gameobject.dead = {};
function Gameobject.addGameobject(g)
	local id = #Gameobject.world + 1
	g.id = id
	table.insert(Gameobject.world, id, g)
end

function Gameobject.removeDeadGameobjects()
	for key, val in pairs(Gameobject.dead) do
		local id = val
		local g = Gameobject.world[id]
		if g then
			g.destroyed = true
			g.body:destroy()
		end
		Gameobject.world[id] = nil
	end
	Gameobject.dead = {}
end

function Gameobject:destroy()
	table.insert(Gameobject.dead, self.id)
	self.dead = true
end

function Gameobject:init(x, y, w, h, type, color)
	self.position = Vector(x or 0, y or 0)
	self.size = Vector(w or 8, h or 8)
	self.velocity = Vector()
	self.acceleration = Vector()
	self.dampening = .7
	self.mass = (self.size.x * self.size.y)
	self.type = type or OBJECT_DYNAMIC
	self.color = color or {
	math.floor(math.random(0, 100)), 
	math.floor(math.random(0, 100)), 
	math.floor(math.random(0, 100)), 
	255
}
self.addGameobject(self)
end

function Gameobject:update(dt)
	self.position = self.position + (self.velocity * dt)
	self.velocity = self.velocity + (self.acceleration * dt)
	self.velocity = self.velocity * self.dampening
end

function Gameobject:draw()
	--love.graphics.setColor(self.color)
	--love.graphics.rectangle("line", self.position.x, self.position.y, self.size.x, self.size.y)
end

function Gameobject:getAABB()
	return self.position, self.size
end

function Gameobject:getCenter()
	return self.position + (self.size / 2)
end

function Gameobject:getVelocityAABB(dv)
	if self.type == OBJECT_STATIC then return self:getAABB() end

	local dv = dv or self.velocity:clone()
	local pos = self.position:clone()
	local size = self.size:clone()
	if self.velocity.x < 0 then
		pos.x = pos.x + dv.x
		size.x = size.x - dv.x
	else
		size.x = size.x + dv.x
	end
	if self.velocity.y < 0 then
		pos.y = pos.y + dv.y
		size.y = size.y - dv.y
	else
		size.y = size.y + dv.y
	end
	return pos, size
end

function Gameobject:collide(pos, size, dt)
	local spos, ssize = self:getVelocityAABB(self.velocity * dt)
	local mtd = minimumTranslation(spos, ssize, pos, size)
	self.position = self.position + mtd
	if mtd.y >= OBJECT_COLLISION_PADDING or mtd.y < -OBJECT_COLLISION_PADDING then
		self.velocity.y = 0
	elseif mtd.x >= OBJECT_COLLISION_PADDING or mtd.x < -OBJECT_COLLISION_PADDING then
		self.velocity.x = 0
	end
end

function Gameobject:collideWithObject(g, dt)
	local spos, ssize = self:getVelocityAABB(self.velocity * dt)
	local gpos, gsize = g:getAABB(g.velocity * dt)
	local mtd = minimumTranslation(spos, ssize, gpos, gsize)
	if mtd:len() > OBJECT_COLLISION_PADDING then
		g.color = {255, 0, 0, 255}
		self.color = {255, 0, 0, 255}
		if (self.type == OBJECT_DYNAMIC and g.type == OBJECT_DYNAMIC)
			or (self.type == OBJECT_STATIC and g.type == OBJECT_STATIC) then
			self.position = self.position + mtd
		elseif self.type == OBJECT_DYNAMIC then
			self.position = self.position + mtd
		elseif g.type == OBJECT_DYNAMIC then
			g.position = g.position + mtd
		end
		if mtd.y >= OBJECT_COLLISION_PADDING or mtd.y < -OBJECT_COLLISION_PADDING then
			self.velocity.y = 0
			g.velocity.y = 0
		elseif mtd.x >= OBJECT_COLLISION_PADDING or mtd.x < -OBJECT_COLLISION_PADDING then
			self.velocity.x = 0
			g.velocity.x = 0
		end
	end
end

return Gameobject