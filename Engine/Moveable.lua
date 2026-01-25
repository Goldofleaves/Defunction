---@class Moveable: Object

Moveable = Object:extend()

function Moveable:new(args)
    self.Strength = args.Strength or 1
    self.Id = G.CurrentID
    self.Nid = args.nid
    G.CurrentID = G.CurrentID + 1
    args = args or {}
    self.ObjectType = 'MOVEABLE'
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
    self.Parent = nil
    self.Children = {}
    self.Properties = args.Properties or {}
    self.Extra = args.Extra or {}
    table.insert(G.I.MOVEABLES, self)
    self.TempStrength = self.Strength
    self.DrawOrder = args.DrawOrder or 0
    return self
end

-- Functions ported from Badge of Severance

---Sets the parent of this object. Its return value will be a numeracal reference ID
---@param Obj Moveable
---@return integer
function Moveable:SetParent (Obj)
    table.insert(Obj.Children,self.Id)
    self.Parent = Obj.Id
    return self.Parent
end

---Add a children to this object.
---@param Obj Moveable
function Moveable:AddChildren (Obj) Obj:SetParent(self) end

-- Aligns objects based on their offsets

function Moveable:GetParentOffset()
    if not self.Parent then return {x=0,y=0} end
    local Parent = GetObjectById(self.Parent)
    if not Parent then return {x = 0, y = 0} end
    return {x = Parent.T.x, y = Parent.T.y}
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
            if self.V[k][Component] then
                RetTable[k] = RetTable[k] + v[Component]
            end
        end
    end
    return RetTable
end

function Moveable:update(dt)
    self.TMod.x.parent = self:GetParentOffset().x
    self.TMod.y.parent = self:GetParentOffset().y
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
    self.UpdateFunc(self, dt)
    self.TempStrength = self.Strength
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
    if self.Properties.NoCollision or e.Properties.NoCollision then
        return false
    end
    if self.TempStrength > e.TempStrength then
        return e:ResolveCollision(self)
    end
    -- self is strictly a less strong moveable than e
    if self:CheckCollision(e) then
        self.TempStrength = e.TempStrength - 1
        if not self.Properties.CollisionCheck and not e.Properties.CollisionCheck then
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
            if self.Properties.CollisionCheck then
                table.insert(self.Extra.Ticked, e.Id)
            end
            if e.Properties.CollisionCheck then
                table.insert(e.Extra.Ticked, self.Id)
            end
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
    args.x = args.x or 140
    args.y = args.y or 200
    args.w = args.w or 80
    args.h = args.h or 20
    args.Strength = 1000
    args.DrawFunc = function (s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#FF0000"))
            love.graphics.rectangle("fill", s.T.x + G:GetTotalOffset().x, s.T.y + G:GetTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor{r, g, b, a}
        end
    end
    return Moveable.new(self, args)
end

RicoChet = Moveable:extend()
function RicoChet:new(args)
    args = args or {}
    args.Properties = args.Properties or {}
    args.Properties.RicoChet = true
    args.x = args.x or 140
    args.y = args.y or 200
    args.w = args.w or 20
    args.h = args.h or 80
    args.Strength = 1000
    args.DrawFunc = function(s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#9900FF"))
            love.graphics.rectangle("fill", s.T.x + G:GetTotalOffset().x, s.T.y + G:GetTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    return Moveable.new(self, args)
end
require "Engine.Player"
require "Engine.Boomerang"

Box = Moveable:extend()
function Box:new(args)
    args = args or {}
    args.Strength = 200
    args.Properties = args.Properties or {}
    args.x = args.x or 160
    args.y = args.y or 140
    args.w = args.w or 20
    args.h = args.h or 20
    args.Extra = {
        OnGround = true
    }
    args.UpdateFunc = function(self, dt)
        self.TMod.x.Gravity = self.TMod.x.Gravity or 0
        self.V.x.Gravity = self.V.x.Gravity or 0
        self.TMod.y.Gravity = self.TMod.y.Gravity or 0
        self.V.y.Gravity = self.V.y.Gravity or 0
        self.V.y.Gravity = self.V.y.Gravity + Macros.Gravity
        self.Extra.OnGround = self.Extra.DownCheck.Extra.Ticked
        if next(self.Extra.OnGround) and not CollisionContainsProperty(self.Extra.OnGround, "NoCollision") then
            self.V.y.Gravity = 0
        end
        self.Strength = 200
        for k, v in pairs(G.I.MOVEABLES) do
            if v.Properties.Player then
                if v.T.y + v.T.h <= self.T.y then
                    self.Strength = 1000
                end
            end
        end
    end
    args.DrawFunc = function(s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#83591B"))
            love.graphics.rectangle("fill", s.T.x + G:GetTotalOffset().x, s.T.y + G:GetTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor { r, g, b, a }
        end
    end
    Moveable.new(self, args)
    self.Extra.DownCheck = Moveable {
        Properties = {
            CollisionCheck = true
        },
        w = args.w,
        h = 1
    }
    self.Extra.DownCheck.TMod.x.offset = 0
    self.Extra.DownCheck.TMod.y.offset = args.h
    self.Extra.DownCheck:SetParent(self)
    return self
end
OneWayPlatform = Moveable:extend()
function OneWayPlatform:new(args)
    args.Strength = 1000
    args = args or {}
    args.Properties = args.Properties or {}
    args.x = args.x or 160
    args.y = args.y or 120
    args.w = args.w or 20
    args.h = args.h or 20
    args.Extra = {
        OnGround = true,
        Facing = args.Facing or "Up"
    }
    args.UpdateFunc = function(self, dt)
        self.Properties.NoCollision = true
        for k, v in pairs(G.I.MOVEABLES) do
            if v.Properties.Player then
                if v.T.y + v.T.h <= self.T.y and self.Extra.Facing == "Up" then
                    self.Properties.NoCollision = false
                end
                if v.T.y >= self.T.h + self.T.y and self.Extra.Facing == "Down" then
                    self.Properties.NoCollision = false
                end
                if v.T.x + v.T.w <= self.T.x and self.Extra.Facing == "Left" then
                    self.Properties.NoCollision = false
                end
                if v.T.x >= self.T.w + self.T.x and self.Extra.Facing == "Right" then
                    self.Properties.NoCollision = false
                end
            end
        end
    end
    args.DrawFunc = function(s)
        if G.Debug then
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(Util.Other.Hex("#ADA9C5")[1], Util.Other.Hex("#ADA9C5")[2], Util.Other.Hex("#ADA9C5")[3], 1/3)
            love.graphics.rectangle("fill", s.T.x + G:GetTotalOffset().x, s.T.y + G:GetTotalOffset().y, s.T.w, s.T.h)
            love.graphics.setColor(Util.Other.Hex("#0EDB0E"))
            if self.Extra.Facing == "Up" then
                love.graphics.rectangle("fill", s.T.x + G:GetTotalOffset().x, s.T.y + G:GetTotalOffset().y, s.T.w, 2)
            elseif self.Extra.Facing == "Down" then
                love.graphics.rectangle("fill", s.T.x + G:GetTotalOffset().x, s.T.y + s.T.h - 2 + G:GetTotalOffset().y, s.T.w, 2)
            elseif self.Extra.Facing == "Left" then
                love.graphics.rectangle("fill", s.T.x + G:GetTotalOffset().x, s.T.y + G:GetTotalOffset().y, 2, s.T.h)
            elseif self.Extra.Facing == "Right" then
                love.graphics.rectangle("fill", s.T.x + s.T.w - 2 + G:GetTotalOffset().x, s.T.y + G:GetTotalOffset().y, 2,
                s.T.h)
            end
            love.graphics.setColor { r, g, b, a }
        end
    end
    Moveable.new(self, args)
    return self
end

-- UTILITY FUNCTIONS
function CollisionContainsId(Ticked, Id)
    for k, v in ipairs(Ticked) do
        if v == Id then
            return true
        end
    end
    return false
end
function CollisionContainsProperty(Ticked, P)
    for k, v in ipairs(Ticked) do
        local obj = GetObjectById(v)
        if obj.Properties[P] then
            return obj.Properties[P]
        end
    end
    return false
end
function CollisionContainsExtra(Ticked, P)
    for k, v in ipairs(Ticked) do
        local obj = GetObjectById(v)
        if obj.Extra[P] then
            return obj.Extra[P]
        end
    end
    return false
end
function GetAllCollisionProperty(Ticked, P)
    local PTab = {}
    for k, v in ipairs(Ticked) do
        local obj = GetObjectById(v)
        if obj.Properties[P] then
            table.insert(PTab, obj.Properties[P])
        end
    end
    return PTab
end

function GetAllCollisionPropertyIds(Ticked, P)
    local PTab = {}
    for k, v in ipairs(Ticked) do
        local obj = GetObjectById(v)
        if obj.Properties[P] then
            table.insert(PTab, v)
        end
    end
    return PTab
end
function GetAllCollisionExtra(Ticked, P)
    local PTab = {}
    for k, v in ipairs(Ticked) do
        local obj = GetObjectById(v)
        if obj.Extra[P] then
            table.insert(PTab, obj.Extra[P])
        end
    end
    return PTab
end
function Moveable:Remove()
    for k, v in ipairs(G.I.MOVEABLES) do
        if v.Id == self.Id then
            table.remove(G.I.MOVEABLES, k)
            G.OldState = G.State
            G.State = "DestroyedObj"
        end
    end
    self = nil
end
