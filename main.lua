--[[

File: 		main.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

Game entry point.

]]--

Gamestate = require("lib.hump.gamestate")
Class = require("lib.hump.class")

assetManager = require("lib.assetmanager")()
hooks = require("lib.hooks")
defaultFont = love.graphics.newFont(9)
console = require("lib.console")(defaultFont, 10)
old_print = print
print = function(msg, from)
	console:add(msg, from)
end

function love.load(args)
	if not release then
		print("Args: " .. table.concat(args, "\n"))
	end

	dofile(assetManager:createScriptPath("init"))
	Gamestate.registerEvents()
	Gamestate.switch(require("src.scenes.game"))
	console:toggle()
	hooks.registerLoveCallbacks()

	love.keyboard.setTextInput(true)
	love.keyboard.setKeyRepeat(true)
end

function love.textinput(t)
	console:textinput(t)
end

function love.keypressed(k)
	console:keypressed(k)
end

function love.update(dt)
	console:update(dt)
end
