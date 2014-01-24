--[[

File:       lib/assetmanager/init.lua
Author:     Daniel "lytedev" Flanagan
Website:    http://dmf.me

Defines a current animation state. Effectively the IDrawable interface for a sprite.

]]--

local AssetManager = Class{function(self)
    local imgData = love.image.newImageData(1, 1)
    imgData:setPixel(0, 0, 0, 0, 0, 0)
    self.blankImage = love.graphics.newImage(imgData)

    self.assetRoot = "assets/"
    self.imageFolder = "img/"
    self.fontFolder = "font/"
    self.scriptsFolder = "scripts/"

    self.images = {}
    self.fonts = {}
end}

function AssetManager:createAssetPath(file, suffix)
    return (self.assetRoot .. string.gsub(file, "[\\.]", "/") .. suffix or '') 
end

function AssetManager:createScriptPath(file)
    return self:createAssetPath(self.scriptsFolder .. file, ".lua")
end

function AssetManager:createImagePath(file)
    return self:createAssetPath(self.imageFolder .. file, ".png")
end

function AssetManager:createFontPath(file)
    return self:createAssetPath(self.fontFolder .. file, ".ttf")
end

function AssetManager:getImage(file, key)
    local key = key or file
    if not self.images[key] then
        self.images[key] = love.graphics.newImage(self:createImagePath(file))
        if self.images[key] == nil then
            print("AssetManager: Could not load image \"" .. file .. "\" - using blank image")
            self.images[key] = self.blankImage
        end
    end
    return self.images[key]
end

function AssetManager:getFont(file, size, key)
    local key = key or file
    file = string.gsub(file, "\\.", "/")
    if not self.fonts[key] then
        self.fonts[key] = love.graphics.newFont(self:createFontPath(file), size)
    end
    return self.fonts[key]
end

function AssetManager:clearCache()
    self:clearImages()
    self:clearFonts()
    self:clearAnimationSets()
end

function AssetManager:clearImages()
    self.image = {}
end

function AssetManager:clearFonts()
    self.fonts = {}
end

return AssetManager