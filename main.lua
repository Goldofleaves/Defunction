Util = {}
love.graphics.setDefaultFilter("nearest", "nearest", 1)

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
                    getObjectByNid("TitleButtons"):remove()
                    LoadFirstRoomTemp()
                end
            }
        },
        updateFunc = function(s, dt)
            if G.controller.keyboard.up.pressed then
                s.extra.SelectedOption = Util.Math.clamp(1, 3, s.extra.SelectedOption - 1)
                local T = getObjectByNid("TitleButtons")
                T.extra.Random = 1
            end
            if G.controller.keyboard.down.pressed then
                s.extra.SelectedOption = Util.Math.clamp(1, 3, s.extra.SelectedOption + 1)
                local T = getObjectByNid("TitleButtons")
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
            local T = getObjectByNid("TitleScr")
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
    print("Fps: " .. (math.floor(1 / dt)))
    print("X: "..(G.dispOffset.x.Shake or 0))
    print("Y: "..(G.dispOffset.y.Shake or 0))
    PREVIOUS_DELTATIME = dt
end

function love.draw()
    SimpleScale.set()
    G:draw()
    SimpleScale.unSet()
end
