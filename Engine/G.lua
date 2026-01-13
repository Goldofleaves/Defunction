---@class Game: Object

--boilerplate
Game = Object:extend()

function Game:new()
    self.Language = "english"
    self.Localization = {}
    self.Settings = {
        ScalingFactor = 2,
        Fullscreen = false,
        ShowGrid = true
    }
    self.I = {
        SPRITES = {}
    }
    self.Timer = 0
    self.State = "Overworld"
    G = self
end
function Game:update(dt)
    for k, v in pairs(self.I) do
        for kk, vv in ipairs(v) do
            vv:update(dt)
        end
    end
    self.Timer = self.Timer + dt
end

function Game:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(Util.Other.Hex("#4a3052"))
    love.graphics.rectangle("fill", 0, 0, Macros.BaseResolution.w, Macros.BaseResolution.h)
    love.graphics.setColor { r, g, b, a }
    local iTable = {}
    for _, v in pairs(self.I.SPRITES) do
        table.insert(iTable, v)
    end
    table.sort(iTable, function(a, b)
        return (a.drawOrder < b.drawOrder)
    end)
    for _, v in ipairs(iTable) do
        v:draw()
    end
    if self.Settings.ShowGrid then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(Util.Other.Hex("#a32858"))
        local amtx, amty = (Macros.BaseResolution.w - Macros.TileSize * 2) / Macros.TileSize, (Macros.BaseResolution.h - Macros.TileSize * 2) / Macros.TileSize
        for i = 1, amtx - 1 do
            love.graphics.rectangle("fill", (1 + i) * Macros.TileSize, Macros.TileSize, 1, Macros.BaseResolution.h - Macros.TileSize * 2)
        end
        for i = 1, amty - 1 do
            love.graphics.rectangle("fill", Macros.TileSize, (1 + i) * Macros.TileSize, Macros.BaseResolution.w - Macros.TileSize * 2, 1)
        end
        love.graphics.setColor { r, g, b, a }
    end
end

Game()
