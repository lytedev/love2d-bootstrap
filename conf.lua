--[[

File: 		conf.lua
Author: 	Daniel "lytedev" Flanagan
Website:	http://dmf.me

Sets the default configuration values for the LOVE2D framework
Defines the main loop of our LOVE application
Contains various helper functions

-- TODO: Global helper functions are a silly idea. Should consider putting them
-- at least in some kind of "namespace" or object somewhere.

]]--

function love.conf(t)
    --
    io.stdout:setvbuf("no")

    -- Create a global variable "config" for direct access to these variables
	config = t

    -- Change these to fit your game
	t.title = "LOVE2D Boilerplate"
	t.author = "Author Name"
	t.url = "http://lytedev.com/love2d-boilerplate"
	t.identity = "love2d_boilerplate"

	-- Unrelated to this boilerplate's in-game console - see conf.lua documentation
    t.console = false

    -- Game Version
	t.titleVersion = "0.2.0"

    -- Required LOVE Version
	t.version = "0.9.1"

    -- http://semver.org

    -- Graphics and display settings
    t.window.title = t.title .. " " .. t.titleVersion
    t.window.icon = nil
    t.window.width = 640
    t.window.height = 360
    t.window.borderless = false
    t.window.resizable = false
    t.window.minwidth = 320
    t.window.minheight = 180
    t.window.fullscreen = false
    t.window.fullscreentype = "normal"
    t.window.vsync = true
    t.window.fsaa = 0
    t.window.display = 1

    -- LOVE modules
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true
    t.modules.thread = true

    -- Network updates per second
	t.networkUPS = 10

    -- To hold custom settings
	t.settings = {}
end

-- Our main loop
function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.event then
        love.event.pump()
    end

    if love.load then love.load(arg) end

    if love.timer then love.timer.step() end

    local dt = 0

    while true do
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        if love.update then love.update(dt) end

        if love.window and love.graphics and love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

-- Helper functions

-- Credit for the next two functions:
-- http://stackoverflow.com/questions/5241799/lua-dealing-with-non-ascii-byte-streams-byteorder-change/5244306#5244306
function bytes_to_int(str, endian, signed)
    local t = {str:byte(1, -1)}
    if endian == "big" then --reverse bytes
        local tt = {}
        for k = 1, #t do
            tt[#t - k + 1] = t[k]
        end
        t = tt
    end
    local n = 0
    for k = 1, #t do
        n = n + t[k] * 2 ^ ((k - 1) * 8)
    end
    if signed then
        n = (n > 2 ^ (#t - 1) -1) and (n - 2 ^ #t) or n -- if last bit set, negative.
    end
    return n
end

function int_to_bytes(num, endian, signed)
    if num < 0 and not signed then num = -num end
    local res = {}
    local n = math.ceil(select(2, math.frexp(num)) / 8)
    if signed and num < 0 then
        num = num + 2 ^ n
    end
    for k = n, 1, -1 do -- 256 = 2^8 bits per char.
        local mul = 2 ^ (8 * (k - 1))
        res[k] = math.floor(num / mul)
        num = num - res[k] * mul
    end
    assert(num == 0)
    if endian == "big" then
        local t = {}
        for k = 1, n do
            t[k] = res[n - k + 1]
        end
        res = t
    end
    return string.char(unpack(res))
end

function string.trim(str)
    return string.match(str, '^%s*(.-)%s*$') or ''
end

function string.insert(str, s2, i)
	local i = i or string.len(str)
	local s = string.sub(str, 1, i) .. tostring(s2) .. string.sub(str, i + 1, string.len(str))
	return s
end

function string_bytes(str, sep)
    local sep = sep or " "
	local dstr = {string.byte(str, 1, string.len(str))}
	s = ""
	for i = 1, #dstr, 1 do
		s = s .. tostring(dstr[i]) .. sep
	end
	return s
end

-- For running files or strings through the interpreter/console
function dofile(file, name)
	local ok, chunk = pcall(love.filesystem.load, file)
	if not ok then
		print("Error: " .. tostring(chunk))
	else
		local result
		ok, result = pcall(chunk)
		if not ok then
			print("Error: " .. tostring(result))
		else
			-- print("Console: " .. tostring(result))
			-- Scripts do not have a result printed
		end
	end
end

function dostring(str)
	local ok, f, e = pcall(loadstring, str)
	if not ok then
		print("Error: " .. tostring(f))
	else
		local result
		ok, result = pcall(f)
		if not ok then
			print("Error: " .. tostring(result))
		else
			print("Console: " .. tostring(result))
		end
	end
end
