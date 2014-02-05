--[[

File:       src/animation/set.lua
Author:     Daniel "lytedev" Flanagan
Website:    http://dmf.me

Contains functions for managing a set of Frames.

]]--

local Set = Class{}

function Set:init(frames, loopStart, loopEnd, bounce)
    self.frames = frames or {}

    if not loopEnd and not loopStart then
        -- loopStart = #self.frames - 1
    end

    if not loopEnd and loopStart then
        loopStart = 0
        loopEnd = loopStart
    end

    self.loopStart = loopStart or 0
    self.loopEnd = loopEnd or 0

    self.bounce = bounce or false
end

function Set:getFrame(fid)
    return self.frames[fid]
end

function Set:removeFrame(fid)
    if fid < 1 or fid > #self.frames then return end
    self.frames:remove(fid)
end

function Set:insertFrame(fid, frame)
    if fid < 1 or fid > #self.frames + 1 then return end
    self.frames[fid] = frame
end

function Set:addFrame(frame)
    self.frames[#self.frames + 1] = frame
end

return Set
