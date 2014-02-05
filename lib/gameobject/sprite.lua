--[[

File: 		conf.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A gameobject with an animation state.

]]--

local Gameobject = require("lib.gameobject")
local AnimationState = require("lib.animation.state")

local Sprite = Class{__includes = {Gameobject, AnimationState}}

function Sprite:init(x, y, w, h, type, color, image, animationGroup)
    Gameobject.init(self, x, y, w, h, type, color)
    AnimationState.init(self, image, animationGroup, self.size)
end

function Sprite:update(dt)
    Gameobject.update(self, dt)
    AnimationState.update(self, dt)
end

function Sprite:draw()
    Gameobject.draw(self)
    AnimationState.draw(self, self.position)
end

return Sprite
