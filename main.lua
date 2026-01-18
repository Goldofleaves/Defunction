Util = {}
love.graphics.setDefaultFilter("nearest", "nearest", 1)
require "Engine.Object"
require "Engine.Moveable"
require "Engine.Sprite"
require "Engine.Macros"
require "Engine.Libs.File"
require "Engine.Libs.Math"
require "Engine.Libs.Other"
require "Engine.G"
require "Engine.Scaling"
RegisterAtlasSimple("Border", "Assets/Images/Border.png", 640, 360)
RegisterAtlasSimple("BorderPattern", "Assets/Images/BorderPattern.png", 20, 20)
RegisterAtlasSimple("Icon", "Assets/Images/Icon.png", 16, 16)
RegisterAtlasSimple("ArnaOverworld", "Assets/Images/ArnaOverworld.png", 20, 40)
RegisterAtlasSimple("ArnaOverworldMask", "Assets/Images/ArnaOverworldMask.png", 20, 40)
RegisterAtlasSimple("BoomerangRing", "Assets/Images/BoomerangRing.png", 80, 80)
RegisterAtlasSimple("TitleSelection", "Assets/Images/TitleSelection.png", 47, 11) -- x: 359 y: 228 + (i - 1) * 11 i think. Might be off by 1
RegisterAtlasSimple("TitleBase", "Assets/Images/TitleBase.png", 640, 360)
love.filesystem.setIdentity("Defunction")

local function LoadFirstRoomTemp()
    Wall()
    Wall({ x = 380 })
    Box()
    OneWayPlatform({ x = 180, Facing = "Up" })
    OneWayPlatform({ x = 220, y = 100, Facing = "Down" })
    OneWayPlatform({ x = 240, h = 40, y = 140, Facing = "Right" })
    OneWayPlatform({ x = 420, h = 40, y = 160, Facing = "Left" })
    Wall({ x = 220, y = 180, Facing = "Left" })
    Player()
end
love.load = function()
    SimpleScale.auto_scale()
    love.window.setTitle("Defunction")
    love.window.setIcon(Atlases.Icon.imageData)
    love.mouse.setVisible(false)
    Sprite({
        AtliKey = "Border",
        Nid = "Border",
        DrawOrder = 9000
    })
    Sprite({
        AtliKey = "BorderPattern",
        Nid = "BorderPattern",
        DrawOrder = 9001,
        UpdateFunc = function (self, dt)
            self.T.x = self.T.x + 25 * dt
            self.T.y = self.T.y + 25 * dt
            self.T.x = self.T.x % Macros.TileSize
            self.T.y = self.T.y % Macros.TileSize
        end,
        DrawTiled = true,
        MaskShouldApply = true,
        MaskImageFpos = "Assets/Images/BorderMask.png"
    })
    Sprite({
        AtliKey = "TitleBase",
        Nid = "TitleScr",
        DrawOrder = 1,
        Extra = {
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
                    GetObjectByNid("TitleButtons"):remove()
                    LoadFirstRoomTemp()
                end
            }
        },
        UpdateFunc = function(s, dt)
            if G.Controller.Keyboard.up.Pressed then
                s.Extra.SelectedOption = Util.Math.Clamp(1, 3, s.Extra.SelectedOption - 1)
                local T = GetObjectByNid("TitleButtons")
                T.Extra.Random = 1
            end
            if G.Controller.Keyboard.down.Pressed then
                s.Extra.SelectedOption = Util.Math.Clamp(1, 3, s.Extra.SelectedOption + 1)
                local T = GetObjectByNid("TitleButtons")
                T.Extra.Random = 1
            end
            if G.Controller.Keyboard.select.Pressed then
                s.Extra.Funcs[s.Extra.SelectedOption](s, dt)
            end
            local TickTime = 0.5
            local frame = Util.Math.Div(G.Timer, TickTime) % 3
            s.AtliInfo.y = frame
        end
    })
    Sprite({
        AtliKey = "TitleSelection",
        Nid = "TitleButtons",
        DrawOrder = 2,
        x = 359,
        y = 228,
        Extra = {
            Random = 0
        },
        UpdateFunc = function(s, dt)
            local T = GetObjectByNid("TitleScr")
            s.T.x = 359 + (math.random() * 2 - 1) * s.Extra.Random
            s.T.y = 228 + (T.Extra.SelectedOption - 1) * 11 + (math.random() * 2 - 1) * s.Extra.Random
            s.AtliInfo.y = T.Extra.SelectedOption - 1
            s.Extra.Random = Util.Math.Clamp(0, 1, s.Extra.Random - 1/4)
        end
    })
    --
end
function love.update(dt)
    DELTATIME = dt
    G:update(dt)
end

function love.draw()
    SimpleScale.set()
    G:draw()
    SimpleScale.unSet()
end
