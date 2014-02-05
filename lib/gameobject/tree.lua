--[[

File: 		lib/gameobject/tree.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

The tree class.

]]--

local Sprite = require("lib.gameobject.sprite")

local Tree = Class{__includes = {Gameobject, AnimationState}}

function Tree:init(x, y, w, h, type, color, image, animationGroup)
	Sprite.init(self, x, y, w, h, type, color, animationGroup)
	self.growthTime = 1
end

function Tree:update(dt)
	Sprite:update(dt)
	self.growthTime = self.growthTime - dt
	if self.growthTime < 0 then
		self.level = self.level + 1
		self.growthTime = self.level
	end
end

function Tree:draw()
	Sprite:draw()
end

return Tree
