---@class Moveable: Object

Moveable = Object:extend()

function Moveable:new(args)
    args = args or {}
    self.T = {
        x = 0,
        y = 0,
        w = 0,
        h = 0,
        Last = {
            x = 0,
            y = 0
        }
    }
    self.TMod = {
        x = { base = args.x or 0 },
        y = { base = args.y or 0 },
        w = { base = args.w or 0 },
        h = { base = args.h or 0 }
    }
    self.UpdateFunc = args.UpdateFunc or function(s, dt) return end
    self.DrawFunc = args.DrawFunc or function(s) return end
    self.V = {
        x = { base = args.vx or 0 },
        y = { base = args.vy or 0 },
    }
    self.Properties = args.Properties or {}
    self.Extra = args.Extra or {}
    table.insert(G.I.MOVEABLES, self)
    return self
end
function Moveable:GetTotalOffset(Component)
    local RetTable = { x = 0, y = 0, w = 0, h = 0 }
    for k, v in pairs(self.TMod) do
        if not Component then
            for kk, vv in pairs(v) do
                RetTable[k] = RetTable[k] + vv
            end
        else
            RetTable[k] = RetTable[k] + v[Component]
        end
    end
    return RetTable
end
function Moveable:GetTotalVelocity(Component)
    local RetTable = { x = 0, y = 0 }
    for k, v in pairs(self.V) do
        if not Component then
            for kk, vv in pairs(v) do
                RetTable[k] = RetTable[k] + vv
            end
        else
            RetTable[k] = RetTable[k] + v[Component]
        end
    end
    return RetTable
end
function Moveable:update(dt)
    
    self.T.Last.x = self.T.x
    self.T.Last.y = self.T.y
    self.UpdateFunc(self, dt)
    for k, v in pairs(self.TMod) do
        for kk, vv in pairs(v) do
            if k == "x" or k == "y" then
                v[kk] = vv + self:GetTotalVelocity(kk)[k] * dt
            end
        end
    end
    for k, v in pairs(self.T) do
        if type(v) == "number" then
            self.T[k] = math.floor(self:GetTotalOffset()[k])
        end
    end
    end
function Moveable:draw()
    self.DrawFunc(self)
end

-- Taken from Sheepolution's collision stuff because im so fucking lazyyy

function Moveable:WasVerticallyAligned(e)
    return self.T.Last.y < e.T.Last.y + e.T.h and self.T.Last.y + self.T.h > e.T.Last.y
end

function Moveable:WasHorizontallyAligned(e)
    return self.T.Last.x < e.T.Last.x + e.T.w and self.T.Last.x + self.T.w > e.T.Last.x
end
function Moveable:CheckCollision(e)
    return self.T.x + self.T.w > e.T.x
        and self.T.x < e.T.x + e.T.w
        and self.T.y + self.T.h > e.T.y
        and self.T.y < e.T.y + e.T.h
end
function Moveable:ResolveCollision(e)
    if self.Properties.Wall then
        return e:ResolveCollision(self)
    end
    if self:CheckCollision(e) then
        if not self.Properties.Check then
            if self:WasVerticallyAligned(e) then
                if self.T.x + self.T.w / 2 < e.T.x + e.T.w / 2 then
                    local pushback = self.T.x + self.T.w - e.T.x
                    self.TMod.x.base = self.TMod.x.base - pushback
                    self.T.x = self.T.x - pushback
                else
                    local pushback = e.T.x + e.T.w - self.T.x
                    self.TMod.x.base = self.TMod.x.base + pushback
                    self.T.x = self.T.x + pushback
                end
            elseif self:WasHorizontallyAligned(e) then
                if self.T.y + self.T.h / 2 < e.T.y + e.T.h / 2 then
                    local pushback = self.T.y + self.T.h - e.T.y
                    self.TMod.y.base = self.TMod.y.base - pushback
                    self.T.y = self.T.y - pushback
                else
                    local pushback = e.T.y + e.T.h - self.T.y
                    self.TMod.y.base = self.TMod.y.base + pushback
                    self.T.y = self.T.y + pushback
                end
            end
            return true
        else
            return true
        end
    end
    return false
end
---@class Wall: Moveable

Wall = Moveable:extend()
function Wall:new(args)
    args = args or {}
    args.Properties = args.Properties or {}
    args.Properties.Wall = true
    args.x = args.x or 100
    args.y = args.y or 100
    args.w = args.w or 20
    args.h = args.h or 20
    args.DrawFunc = function (s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#FF0000"))
            love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor{r, g, b, a}
        end
    end
    return Moveable.new(self, args)
end

---@class Player: Moveable

Player = Moveable:extend()
function Player:new(args)
    args = args or {}
    args.Properties = args.Properties or {}
    args.Properties.Player = true
    args.x = args.x or 150
    args.y = args.y or 150
    args.w = args.w or 20
    args.h = args.h or 40
    args.UpdateFunc = function(self, dt)
        if love.keyboard.isDown("left") then
            self.V.x.base = -100
        elseif love.keyboard.isDown("right") then
            self.V.x.base = 100
        else
            self.V.x.base = 0
        end
        for k, v in ipairs(G.I.MOVEABLES) do
            if self.T.y + self.T.h <= 1 then
                
            end
        end
        self.TMod.x.Gravity = self.TMod.x.Gravity or 0
        self.V.x.Gravity = self.V.x.Gravity or 0
        self.TMod.y.Gravity = self.TMod.y.Gravity or 0
        self.V.y.Gravity = self.V.y.Gravity or 0
        self.V.y.Gravity = self.V.y.Gravity + Macros.Gravity
        if love.keyboard.isDown("up") then
            if not self.Extra.LastUp then
                self.V.y.Gravity = -150
            end
            self.Extra.LastUp = true
        else
            self.Extra.LastUp = false
        end
        --[[for k, v in pairs(self.T) do
            self.Extra.Check[k] = v
        end
        self.Extra.Check.T.x = self.Extra.Check.T.x + 80]]
        print(self.Extra.Grounded)
    end
    args.DrawFunc = function(s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#00FF15"))
            love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    --[[args.Extra = args.Extra or {}
    args.Extra.Check = Moveable({
        DrawFunc = function(s)
            if G.Debug then
                local r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(Util.Other.Hex("#2F00FF"))
                love.graphics.rectangle("fill", s.T.x, s.T.y, s.T.w, s.T.h)
                love.graphics.setColor { r, g, b, a }
            end
        end
    })]]
    Moveable.new(self, args)
    return self
end
