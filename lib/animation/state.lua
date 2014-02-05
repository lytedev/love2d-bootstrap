--[[

File:       src/animation/state.lua
Author:     Daniel "lytedev" Flanagan
Website:    http://dmf.me

A manager for an animation Group and for drawing the current state.

]]--

local Frame = require("lib.animation.frame")

local State = Class{}

function State:init(image, group, size, initialKey)
    self:reset()
    self.image = image
    self.group = group
    self.key = "default"
    if self.group then
        self.key = group.initialKey
    end
    if initialKey then
        self.key = initialKey
    end
    self.size = size or Vector(self.image:getWidth(), self.image:getHeight())
    self.overlay = {255, 255, 255, 255}
    self.offset = Vector(0, 0)

    self.quad = love.graphics.newQuad(0, 0, self.size.x, self.size.y, self.image:getWidth(), self.image:getHeight())
end

function State:reset()
    self.currentFrameID = 1

    self.currentTime = 0
    self.currentFrames = 0

    self.started = false
    self.ended = true
    self.looping = false
    self.bouncing = false
end

function State:setKey(key)
    self.key = key
    self:reset()
end

function State:getSet()
    if self.group then
        return self.group:getSet(self.key)
    else
        return nil
    end
end

function State:getFrame()
    local a = self:getSet()
    if a then
        return a:getFrame(self.currentFrameID)
    else
        cprint("Animation: Tried to fetch Frame with no Set - returning image dimension frame")
        return Frame(Vector(0, 0), Vector(self.image:getWidth(), self.image:getHeight()))
    end
end

function State:update(dt)
    self.currentTime = self.currentTime + dt
    self.currentFrames = self.currentFrames + 1

    local a = self:getSet()
    if not a then
        return
    end
    if self.currentFrameID > #a.frames then
        self:reset()
    end
    if #a.frames >= 1 and self.currentFrameID >= 1 then
        local f = self:getFrame()
        if f.frames then
            if self.currentFrames >= f.frames then
                self:nextFrame(f, a)
            end
        end
        if self.currentTime >= f.time then
            self:nextFrame(f, a)
        end
        self.quad:setViewport(f.source.x, f.source.y, f.size.x, f.size.y)
        self.offset = f.offset
    end
end

function State:nextFrame(currentFrame, currentSet)
    self.currentTime = 0
    self.currentFrames = 0
    if not self.bouncing then
        self.currentFrameID = self.currentFrameID + 1
    else
        if self.currentFrameID > 1 then
            self.currentFrameID = self.currentFrameID - 1
        else
            self.bouncing = false
            self.currentFrameID = self.currentFrameID + 1
        end
    end
    local innerLoopExists = currentSet.loopStart > 1 and currentSet.loopEnd < #currentSet.frames and currentSet.loopEnd >= currentSet.loopStart;

    if not self.started then
        if self.bouncing then
            if self.currentFrameID <= 1 then
                self.bouncing = false
                -- self.currentFrameID = self.currentFrameID + 1
            end
        else
            self.looping = innerLoopExists and self.currentFrameID >= currentSet.loopEnd
            if self.currentFrameID > #currentSet.frames or self.looping then
                self.started = true
                self.bouncing = self.bounce
                if not self.bounce and innerLoopExists then
                    self.currentFrameID = currentSet.loopStart
                elseif not self.bounce then
                    self.started = false
                    self.currentFrameID = 1
                end
            end
        end
    elseif self.looping and innerLoopExists then
        self.bouncing = not (self.currentFrameID <= currentSet.loopStart and self.bouncing)
        if self.currentFrameID >= currentSet.loopEnd and not self.bounce then
            self.currentFrameID = currentSet.loopStart
        end
    else
        if #currentSet.frames >= 1 then
            if self.currentFrameID >= #currentSet.frames then
                self.ended = true
                self.started = false
                self.looping = false
                self.bouncing = self.bounce
                if not self.bounce then
                    self.currentFrameID = 1
                end
            end
        end
    end
end

function State:draw(position)
    love.graphics.setColor(self.overlay)
    love.graphics.drawq(self.image, self.quad, (position.x + self.offset.x), (position.y + self.offset.y))
end

return State
