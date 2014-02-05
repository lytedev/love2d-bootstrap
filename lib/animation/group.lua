--[[

File:       src/animation/group.lua
Author:     Daniel "lytedev" Flanagan
Website:    http://dmf.me

Contains functions for managing a group of Sets.

]]--

local Group = Class{}

function Group:init(setKeysTable)
    self.sets = {}
    self.initialKey = ""
    if setKeysTable then
        for i = 1, #setKeysTable, 1 do
            local key = setKeysTable[i].key or setKeysTable[i][1] or nil
            local set = setKeysTable[i].set or setKeysTable[i][2] or nil
            if key and set then 
                self:addSet(key, set)
            end
        end
    end
end

function Group:getFrame(key, fid)
    local a = self:getAnimation(key)
    return a:getFrame(fid)
end

function Group:getSet(key)
    return self.sets[key]
end

function Group:removeSet(key)
    self.sets[key] = nil
end

function Group:addSet(key, set)
    if self.initialKey == "" then
        self.initialKey = key
    end
    self.sets[key] = set
end

return Group
