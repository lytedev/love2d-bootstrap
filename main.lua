-- Put your code here!

-- Maybe you just want the scripting hooks?
hooks = require('lib.hooks')
hooks.registerLoveCallbacks()
-- This should be global and named "hooks"

-- Want the console?
font = love.graphics.newFont()
lineHeight = 12
replacePrint = true
showInitially = true
local console = require('lib.console')(font, lineHeight, replacePrint, showInitially)
-- Console automatically loads in in-game scripting hooks (if they weren't already)
-- You may realistically want this to be global

function exampleHook(arg) 
	print("example: " .. tostring(arg))
end
hooks:add('load', function() exampleHook("Hello, Hook!") end)