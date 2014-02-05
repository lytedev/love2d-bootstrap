--[[

File:       src/animation/frame.lua
Author:     Daniel "lytedev" Flanagan
Website:    http://dmf.me

Contains the data to specify a piece of a texture over a period of time.

]]--

local Frame = Class{}

function Frame.generate(w, h, imgw, imgh, num, time, frames, offset, start)
	local start = start or 0
	local tw = math.floor(imgw / w)
	local th = math.floor(imgh / h)
	local num = num or (tw * th)
	local framesArray = {}
	for i = start, num - 1, 1 do
		-- To change left-to-right-down, modify xid and yid calcs
		local xid = i % tw 
		local yid = math.floor(i / tw)

		local frame = Frame(Vector(xid * w, yid * h), Vector(w, h), time, frames, offset)
		table.insert(framesArray, frame)
	end
	return framesArray
end

function Frame:init(source, size, time, frames, offset)
    self.source = source or Vector(0, 0)
    self.size = size or Vector(16, 16)
    self.offset = offset or Vector(0, 0)
    self.time = time or 0.2
    self.frames = frames or nil
end

function Frame:__tostring()
	return string.format("Source: (%s), Size: (%s), Time: %ds, Frames: %i, Offset: (%s)", tostring(self.source), tostring(self.size), self.time, self.frames or 0, tostring(self.offset))
end

return Frame
