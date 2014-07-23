--[[

File: 		src/hooks/init.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

A manager for scripting hooks.

]]--

local function __NULL__() end

local all_callbacks = {
	'load',
	'update',
	'draw',
	'focus',
	'textinput',
	'keypressed',
	'keyreleased',
	'mousepressed',
	'mousereleased',
	'joystickpressed',
	'joystickreleased',
	'quit'
}

local Hooks = {
	_hooks = {}
}

function Hooks.registerLoveCallbacks(callbacks)
	local registry = {}
	callbacks = callbacks or all_callbacks
	for _,f in ipairs(callbacks) do
		registry[f] = love[f] or __NULL__
		love[f] = function(...)
			registry[f](...)
			return Hooks:call(f, ...)
		end
	end
end

function Hooks:call(name, ...)
	local ipairs = ipairs
	local hook = self._hooks[name]
	if not hook then return end
	for _, f in ipairs(hook) do
		f(...)
	end
end

function Hooks:add(name, f)
	local hook = self._hooks[name]
	if not hook then
		hook = {}
		self._hooks[name] = hook
	end
	table.insert(hook, f)
end

function Hooks:clear(name)
	local hook = self._hooks[name]
	if hook then
		hook = {}
		self._hooks[name] = hook
	end
end

function Hooks:clearAll()
	self._hooks = {}
end

return Hooks
