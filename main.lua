Util = {}
love.graphics.setDefaultFilter("nearest", "nearest", 1)
require "Engine.Object"
require "Engine.Event"
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
RegisterAtlasSimple("Boomerang", "Assets/Images/Boomerang.png", 20, 20)
RegisterAtlasSimple("Bump", "Assets/Images/Bump.png", 20, 20)
RegisterAtlasSimple("TitleSelection", "Assets/Images/TitleSelection.png", 47, 11) -- x: 359 y: 228 + (i - 1) * 11 i think. Might be off by 1
RegisterAtlasSimple("TitleBase", "Assets/Images/TitleBase.png", 640, 360)
love.filesystem.setIdentity("Defunction")

local function LoadFirstRoomTemp()
    Wall()
    RicoChet({ x = 380, w = 80, h = 20})
    Box()
    OneWayPlatform({ x = 180, y = 60, Facing = "up" })
    OneWayPlatform({ x = 180, Facing = "up" })
    OneWayPlatform({ x = 220, y = 100, Facing = "down" })
    OneWayPlatform({ x = 240, h = 40, y = 140, Facing = "right" })
    --OneWayPlatform({ x = 420, h = 40, y = 160, Facing = "left" })
    Wall({ x = 220, y = 180, w = 160})
    RicoChet({ x = 500, y = 100 })
    RicoChet({ x = 400, y = 60, h = 20, w = 80 })
    Player()
end
love.load = function()
    SimpleScale.auto_scale()
    love.window.setTitle("Defunction")
    love.window.setIcon(Atlases.Icon.imageData)
    love.mouse.setVisible(false)
    Sprite({
        atlasKey = "Border",
        Nid = "Border",
        drawOrder = 9000
    })
    Sprite({
        atlasKey = "BorderPattern",
        Nid = "BorderPattern",
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
        Nid = "TitleScr",
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
                s.extra.SelectedOption = Util.Math.Clamp(1, 3, s.extra.SelectedOption - 1)
                local T = getObjectByNid("TitleButtons")
                T.extra.Random = 1
            end
            if G.controller.keyboard.down.pressed then
                s.extra.SelectedOption = Util.Math.Clamp(1, 3, s.extra.SelectedOption + 1)
                local T = getObjectByNid("TitleButtons")
                T.extra.Random = 1
            end
            if G.controller.keyboard.select.pressed then
                s.extra.Funcs[s.extra.SelectedOption](s, dt)
            end
            local tickTime = 0.5
            local frame = Util.Math.Div(G.timer, tickTime) % 3
            s.atlasInfo.y = frame
        end
    })
    Sprite({
        atlasKey = "TitleSelection",
        Nid = "TitleButtons",
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
            s.extra.Random = Util.Math.Clamp(0, 1, s.extra.Random - 1/4)
        end
    })
    --
end
function love.update(dt)
    DELTATIME = dt
    G:update(dt)
    print(#G.I.SPRITES)
    PREVIOUS_DELTATIME = dt
end

function love.draw()
    SimpleScale.set()
    G:draw()
    SimpleScale.unSet()
end
