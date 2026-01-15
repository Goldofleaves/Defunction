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
love.filesystem.setIdentity("Defuntion")

love.load = function()
    Wall()
    Player()
    SimpleScale.auto_scale()
    love.window.setTitle("Defuntion")
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
