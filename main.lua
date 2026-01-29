Util = {}
love.graphics.setDefaultFilter("nearest", "nearest", 1)

-- Misc

local printref = print
function print(...)
    local function log(l)
        local printtext = {}
        local function j(a, spaces, f, ins)
            spaces = spaces or 0
            ins = ins or 0
            if type(a) == "table" then
                table.insert(printtext, string.rep(" ", spaces) .. (f and f .. ": " or "") .. "Table:")
                spaces = spaces + 1
                for k, v in pairs(a) do
                    if type(v) == "table" then
                        j(v, spaces + 1, k, ins + 1)
                    else
                        table.insert(printtext, string.rep(" ", spaces + 1) .. tostring(k) .. ": " .. tostring(v))
                    end
                end
            else
                table.insert(printtext, string.rep(" ", spaces) .. tostring(a))
            end
        end
        j(l)
        for k, v in pairs(printtext) do
            printref(v)
        end
    end
    for k, v in pairs({...}) do
        log(v)
    end
end

local utf8 = require "utf8"

local function error_printer(msg, layer)
    print((debug.traceback("ERROR: " .. tostring(msg), 1 + (layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
    local function hex(hex)
        if string.sub(hex, 1, 1) == "#" then
            hex = string.sub(hex, 2, string.len(hex))
        end
        if #hex <= 6 then hex = hex .. "FF" end
        local _, _, r, g, b, a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
        local color = { tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255 or 255 }
        return color
    end

    msg = tostring(msg)

    error_printer(msg, 2)

    if not love.window or not love.graphics or not love.event then
        return
    end

    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success, status = pcall(love.window.setMode, 800, 600)
        if not success or not status then
            return
        end
    end

    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
        if love.mouse.isCursorSupported() then
            love.mouse.setCursor()
        end
    end
    if love.joystick then
        -- Stop all joystick vibrations.
        for i, v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    if love.audio then love.audio.stop() end

    love.graphics.reset()

    love.graphics.setColor(1, 1, 1)

    local trace = debug.traceback()

    love.graphics.origin()

    local sanitizedmsg = {}
    for char in msg:gmatch(utf8.charpattern) do
        table.insert(sanitizedmsg, char)
    end
    local sanitizedmessage = table.concat(sanitizedmsg)

    local err = {}

    table.insert(err, "THE EARTH'S CORE HAS BLOWN UP")
    table.insert(err, "ERROR!\n")
    table.insert(err, sanitizedmessage)

    if #sanitizedmessage ~= #msg then
        table.insert(err, "Invalid UTF-8 string in error message.")
    end

    table.insert(err, "\n")

    for l in trace:gmatch("(.-)\n") do
        if not l:match("boot.lua") then
            l = l:gsub("stack traceback:", "Stack Traceback:\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = p:gsub("\t", "")
    p = p:gsub("%[string \"(.-)\"%]", "%1")
    local function draw()
        if not love.graphics.isActive() then return end
        pos = pos or 40
        love.graphics.setDefaultFilter("nearest", "nearest", 1)
        J = J or love.graphics.newImage("Assets/Images/ErrorHandler.png")
        X = X or love.graphics.newFont("Assets/Fonts/monogram-extended.ttf", 16)
        love.graphics.clear(hex("#8465ec"))
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 40 - 22, 40 - 22, love.graphics.getWidth() - 20 - 16,
        love.graphics.getHeight() - 20 - 16)
        love.graphics.setColor(hex("#a32858"))
        love.graphics.rectangle("fill", 40 - 20, 40 - 20, love.graphics.getWidth() - 20 - 20,
            love.graphics.getHeight() - 20 - 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(J, 20, 20, 0, 2, 2)
        love.graphics.setColor(hex("#4a3052"))
        love.graphics.printf(p, X, 40, pos + 4,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40 - 2, pos + 2,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40 + 2, pos + 2,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40 - 2, pos,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40 + 2, pos,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.printf(p, X, 40, pos - 2,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.setColor(hex("#8b9bb4"))
        love.graphics.printf(p, X, 40, pos + 2,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(p, X, 40, pos,
            (love.graphics.getWidth() - 80) / 2, "left", 0, 2, 2)
        love.graphics.present()
    end

    local fullErrorText = p
    local function copyToClipboard()
        if not love.system then return end
        love.system.setClipboardText(fullErrorText)
        p = p .. "\nCopied to clipboard!"
    end

    if love.system then
        p = p .. "\n\nPress Ctrl+C or tap to copy this error"
        p = p .. "\nScroll the mouse to read full traceback"
    end

    return function()
        love.event.pump()

        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return 1
            elseif e == "keypressed" and a == "escape" then
                return 1
            elseif e == "wheelmoved" then
                pos = pos + b * 4
                pos = math.min(pos, 40)
            elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
                copyToClipboard()
            elseif e == "touchpressed" then
                local name = love.window.getTitle()
                if #name == 0 or name == "Untitled" then name = "Game" end
                local buttons = { "OK", "Cancel" }
                if love.system then
                    buttons[3] = "Copy to clipboard"
                end
                local pressed = love.window.showMessageBox("Quit " .. name .. "?", "", buttons)
                if pressed == 1 then
                    return 1
                elseif pressed == 3 then
                    copyToClipboard()
                end
            end
        end

        draw()

        if love.timer then
            love.timer.sleep(0.1)
        end
    end
end
-- LIBs Loading

require "Engine.Object"
require "Engine.Event"
require "Engine.Moveable"
require "Engine.Sprite"
require "Engine.Text"
require "Engine.Macros"
require "Engine.Libs.File"
require "Engine.Libs.Math"
require "Engine.Libs.Other"
require "Engine.Libs.Audio"
require "Engine.Libs.Splines and Easing"
require "Engine.G"
require "Engine.Scaling"
registerAtlasSimple("Border", "Assets/Images/Border.png", 640, 360)
registerAtlasSimple("BorderPattern", "Assets/Images/BorderPattern.png", 20, 20)
registerAtlasSimple("Icon", "Assets/Images/Icon.png", 16, 16)
registerAtlasSimple("ArnaOverworld", "Assets/Images/ArnaOverworld.png", 20, 40)
registerAtlasSimple("ArnaDead", "Assets/Images/ArnaDead.png", 20, 40)
registerAtlasSimple("ArnaOverworldMask", "Assets/Images/ArnaOverworldMask.png", 20, 40)
registerAtlasSimple("BoomerangRing", "Assets/Images/BoomerangRing.png", 80, 80)
registerAtlasSimple("Boomerang", "Assets/Images/Boomerang.png", 20, 20)
registerAtlasSimple("BoomyDead", "Assets/Images/BoomyDead.png", 20, 20)
registerAtlasSimple("Bump", "Assets/Images/Bump.png", 20, 20)
registerAtlasSimple("TitleSelection", "Assets/Images/TitleSelection.png", 47, 11) -- x: 359 y: 228 + (i - 1) * 11 i think. Might be off by 1
registerAtlasSimple("TitleBase", "Assets/Images/TitleBase.png", 640, 360)
Util.Audio.registerSfx('Bump1', { 'Bump1' })
Util.Audio.registerSfx('BumpWeak1', { 'BumpWeak1' })
love.filesystem.setIdentity("Defunction")
Util.Other.loadLocalization()
local function LoadFirstRoomTemp()
    Wall()
    RicoChet({ x = 380, w = 80, h = 20})
    Box()
    OneWayPlatform({ x = 180, y = 60, facing = "up" })
    OneWayPlatform({ x = 180, facing = "up" })
    OneWayPlatform({ x = 220, y = 100, facing = "down" })
    OneWayPlatform({ x = 240, h = 40, y = 140, facing = "right" })
    --OneWayPlatform({ x = 420, h = 40, y = 160, facing = "left" })
    Wall({ x = 220, y = 180, w = 160})
    RicoChet({ x = 500, y = 100 })
    RicoChet({ x = 400, y = 60, h = 20, w = 80 })
    Player()
    DeathBlock()
end
love.load = function()
    SimpleScale.auto_scale()
    love.window.setTitle("Defunction")
    love.window.setIcon(Atlases.Icon.imageData)
    love.mouse.setVisible(false)
    Sprite({
        atlasKey = "Border",
        nid = "Border",
        drawOrder = 9000
    })
    Sprite({
        atlasKey = "BorderPattern",
        nid = "BorderPattern",
        drawOrder = 9001,
        updateFunc = function (self, dt)
            self.T.x = self.T.x + 25 * dt
            self.T.y = self.T.y + 25 * dt
            self.T.x = self.T.x % Macros.tileSize
            self.T.y = self.T.y % Macros.tileSize
        end,
        DrawTiled = true,
        MaskShouldApply = true,
        MaskImageFpos = "Assets/Images/BorderMask.png"
    })
    Sprite({
        atlasKey = "TitleBase",
        nid = "TitleScr",
        drawOrder = 1,
        extra = {
            SelectedOption = 1,
            Funcs = {
                function(s, dt)
                    love.event.push("quit")
                end,
                function(s, dt)
                    return
                end,
                function(s, dt)
                    s:remove()
                    local tb = getObjectByNid("TitleButtons") or { remove = function () end }
                    tb:remove()
                    LoadFirstRoomTemp()
                end
            }
        },
        updateFunc = function(s, dt)
            if G.controller.keyboard.up.pressed then
                s.extra.SelectedOption = Util.Math.clamp(1, 3, s.extra.SelectedOption - 1)
                local T = getObjectByNid("TitleButtons") or { extra = { Random = 1 } }
                T.extra.Random = 1
            end
            if G.controller.keyboard.down.pressed then
                s.extra.SelectedOption = Util.Math.clamp(1, 3, s.extra.SelectedOption + 1)
                local T = getObjectByNid("TitleButtons") or { extra = { Random = 1 } }
                T.extra.Random = 1
            end
            if G.controller.keyboard.select.pressed then
                s.extra.Funcs[s.extra.SelectedOption](s, dt)
            end
            local tickTime = 0.5
            local frame = Util.Math.div(G.timer, tickTime) % 3
            s.atlasInfo.y = frame
        end
    })
    Sprite({
        atlasKey = "TitleSelection",
        nid = "TitleButtons",
        drawOrder = 2,
        x = 359,
        y = 228,
        extra = {
            Random = 0
        },
        updateFunc = function(s, dt)
            local T = getObjectByNid("TitleScr") or {extra = {SelectedOption = 1}}
            s.T.x = 359 + (math.random() * 2 - 1) * s.extra.Random
            s.T.y = 228 + (T.extra.SelectedOption - 1) * 11 + (math.random() * 2 - 1) * s.extra.Random
            s.atlasInfo.y = T.extra.SelectedOption - 1
            s.extra.Random = Util.Math.clamp(0, 1, s.extra.Random - 1/4)
        end
    })
    --
end
function love.update(dt)
    DELTATIME = dt
    G:update(dt)
    -- print("Fps: " .. (math.floor(1 / dt)))
    -- print("X: "..(G.dispOffset.x.Shake or 0))
    -- print("Y: "..(G.dispOffset.y.Shake or 0))
    PREVIOUS_DELTATIME = dt
end

function love.draw()
    SimpleScale.set()
    G:draw()
    SimpleScale.unSet()
end
