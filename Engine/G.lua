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
    self.CurrentID = 0
    self.I = {
        SPRITES = {},
        MOVEABLES = {},
    }
    self.debug = true
    self.Timer = 0
    self.State = "Overworld"
    self.Controller = {
        Keyboard = {
            up = { Keybind = {"w", "space", "up", {"lctrl", "lshift"}}, Pressed = false, Held = false, Released = false },
            down = { Keybind = {"s", "down"}, Pressed = false, Held = false, Released = false },
            left = { Keybind = {"a", "left"}, Pressed = false, Held = false, Released = false },
            right = { Keybind = { "d", "right" }, Pressed = false, Held = false, Released = false },
            select = { Keybind = { "z", "return" }, Pressed = false, Held = false, Released = false },
        },
        Mouse = {
            Primary = { Keybind = {1}, Pressed = false, Held = false, Released = false }, -- Primary (left)
            Secondary = { Keybind = {2}, Pressed = false, Held = false, Released = false },     -- Secondary (right)
            Middle = { Keybind = {3}, Pressed = false, Held = false, Released = false },     -- Middle Click
        }
    }
    self.MousePos = {
        x = 0, y = 0
    }
    self.DispOffset = {
        x = {
            base = 0
        },
        y = {
            base = 0
        }
    }
    self.Flags = {}
    self.Events = {}
    G = self
end
function Game:GetTotalOffset()
    local retTable = {x = 0, y = 0}
    for k, v in pairs(self.DispOffset) do
        for kk, vv in pairs(v) do
            retTable[k] = retTable[k] + vv
        end
    end
    return retTable
end
function Game:update(dt)
    self.MousePos = {
        x = love.mouse.getX() / G.Settings.ScalingFactor,
        y = love.mouse.getY() / G.Settings.ScalingFactor
    }
    -- Handling Events
    for k, v in ipairs(self.Events) do
        local event = v
        event.CurTime = event.CurTime or 0
        if event.EaseFunc then
            event.EaseFunc(event.CurTime / event.Duration, event)
        end
        event.Completed = event.Completed == nil and false or event.Completed
        if not event.Completed and event.Func then
            event.Func(event)
            event.Completed = true
        end
        event.CurTime = event.CurTime + dt
        if event.CurTime > event.Duration then
            if event.EndFunc then event.EndFunc(event) end
            self.Events[k] = nil
        end
    end
    self.Events = Util.Other.RemoveNils(self.Events)
    for k, v in pairs(self.Controller.Keyboard) do
        if (function ()
                for kk, vv in pairs(v.Keybind) do
                    if type(vv) ~= "table" then
                        if love.keyboard.isDown(vv) then
                            return true
                        end
                    else
                        local bool = true
                        for kkk, vvv in pairs(vv) do
                            if not love.keyboard.isDown(vvv) then
                                bool = false
                            end
                        end
                        if bool then
                            return true
                        end
                    end
                end
                return false
            end)() then
            v.Held = true
            if not v.PressTemp then
                v.Pressed = true
                v.PressTemp = true
            else
                v.Pressed = false
            end
        else
            if v.Held then
                v.Released = true
            else
                v.Released = false
            end
            v.Held = false
            v.Pressed = false
            v.PressTemp = false
        end
    end

    for k, v in pairs(self.Controller.Mouse) do
        if (function()
                for kk, vv in pairs(v.Keybind) do
                    if type(vv) ~= "table" then
                        if love.mouse.isDown(vv) then
                            return true
                        end
                    else
                        local bool = true
                        for kkk, vvv in pairs(vv) do
                            if not love.mouse.isDown(vvv) then
                                bool = false
                            end
                        end
                        if bool then
                            return true
                        end
                    end
                end
                return false
            end)() then
            v.Held = true
            if not v.PressTemp then
                v.Pressed = true
                v.PressTemp = true
            else
                v.Pressed = false
            end
        else
            if v.Held then
                v.Released = true
            else
                v.Released = false
            end
            v.Held = false
            v.Pressed = false
            v.PressTemp = false
        end
    end
    
    local function HandleCollisions()
        local loop = true
        local limit = 0

        while loop do
            loop = false
            limit = limit + 1
            if limit > 1 then
                break
            end
            for i = 1, #self.I.MOVEABLES - 1 do
                for j = i + 1, #self.I.MOVEABLES do
                    --print("i = "..i..", j = "..j)
                    local collision = self.I.MOVEABLES[i]:ResolveCollision(self.I.MOVEABLES[j])
                    --print(collision)
                    if collision then
                        loop = true
                    end
                end
            end
        end
    end
    HandleCollisions()
    for k, v in pairs(self.I.MOVEABLES) do
        if not v.properties.CollisionCheck then
            v:update(dt)
            HandleCollisions()
            if self.State == "DestroyedObj" then
                self.State = self.OldState
                self.OldState = nil
                break
            end
        end
    end
    for k, v in pairs(self.I.MOVEABLES) do
        if v.properties.CollisionCheck then
            v:update(dt)
            HandleCollisions()
            if self.State == "DestroyedObj" then
                self.State = self.OldState
                self.OldState = nil
                break
            end
        end
    end
    for k, v in pairs(self.I.SPRITES) do
        v:update(dt)
        if self.State == "DestroyedObj" then
            self.State = self.OldState
            self.OldState = nil
            break
        end
    end
    for k, v in pairs(self.I.MOVEABLES) do
        if v.properties.CollisionCheck then
            v.extra.ticked = {}
        end
    end
    HandleCollisions()
    self.Timer = self.Timer + dt
end

function Game:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(Util.Other.Hex("#4a3052"))
    love.graphics.rectangle("fill", 0, 0, Macros.BaseResolution.w, Macros.BaseResolution.h)
    love.graphics.setColor { r, g, b, a }
    if self.Settings.ShowGrid then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(Util.Other.Hex("#a32858"))
        local amtx, amty = (Macros.BaseResolution.w - Macros.TileSize * 2) / Macros.TileSize,
            (Macros.BaseResolution.h - Macros.TileSize * 2) / Macros.TileSize
        for i = 1, amtx - 1 do
            love.graphics.rectangle("fill", (1 + i) * Macros.TileSize, Macros.TileSize, 1,
                Macros.BaseResolution.h - Macros.TileSize * 2)
        end
        for i = 1, amty - 1 do
            love.graphics.rectangle("fill", Macros.TileSize, (1 + i) * Macros.TileSize,
                Macros.BaseResolution.w - Macros.TileSize * 2, 1)
        end
        love.graphics.setColor { r, g, b, a }
    end
    local jTable = {}
    for _, v in pairs(self.I.MOVEABLES) do
        table.insert(jTable, v)
    end
    table.sort(jTable, function(a, b)
        return (a.drawOrder < b.drawOrder)
    end)
    for _, v in ipairs(jTable) do
        v:draw()
    end
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
end

Game()
