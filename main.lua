Util = {}
love.graphics.setDefaultFilter("nearest", "nearest", 1)
require "Engine.Object"
require "Engine.Moveable"
require "Engine.Sprite"
require "Engine.Macros"
require "Engine.Libs.File"
require "Engine.Libs.Other"
require "Engine.G"
require "Engine.Scaling"
RegisterAtlasSimple("Border", "Assets/Images/Border.png", 640, 360)
RegisterAtlasSimple("BorderPattern", "Assets/Images/BorderPattern.png", 20, 20)
RegisterAtlasSimple("Icon", "Assets/Images/Icon.png", 16, 16)
love.filesystem.setIdentity("Defuntion")

love.load = function()
    Wall{vx = 10, vy = 5}
    SimpleScale.auto_scale()
    love.window.setTitle("Defuntion")
    love.window.setIcon(Atlases.Icon.imageData)
    love.mouse.setVisible(false)
    Sprite({
        atliKey = "Border",
        nid = "Border",
        drawOrder = 9000
    })
    Sprite({
        atliKey = "BorderPattern",
        nid = "BorderPattern",
        drawOrder = 9001,
        func = function (self, dt)
            self.pos.x = self.pos.x + 25 * dt
            self.pos.y = self.pos.y + 25 * dt
            self.pos.x = self.pos.x % Macros.TileSize
            self.pos.y = self.pos.y % Macros.TileSize
        end,
        drawTiled = true,
        maskShouldApply = true,
        maskImageFpos = "Assets/Images/BorderMask.png"
    })
end
function love.update(dt)
    G:update(dt)
end

function love.draw()
    SimpleScale.set()
    G:draw()
    SimpleScale.unSet()
end
